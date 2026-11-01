import 'package:riverpod/riverpod.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/api_client.dart';
import '../services/push_service.dart';
import '../services/secure_storage.dart';
import 'locale_provider.dart';

// Secure Storage provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// API Client provider
// Explicit variable type: the onUnauthorized callback references
// authStateProvider, which transitively depends on this provider, so an
// explicit type is needed to break the top-level inference cycle.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(
    baseUrl: AppConfig.apiUrl,
    // Drop to /login from one place when a request 401s with no usable refresh
    // token. Read lazily (not at build time) to avoid a circular provider
    // dependency — apiClient is a transitive dependency of authStateProvider.
    // ApiClient already excludes auth-path 401s (a failed login) from this.
    onUnauthorized: () {
      ref.read(authStateProvider.notifier).handleUnauthorized();
    },
    // Persist the rotated tokens after a silent refresh so a later app restart
    // restores a still-valid refresh token (the backend rotates it each time).
    onTokensRefreshed: (accessToken, refreshToken) async {
      await storage.saveToken(accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await storage.saveRefreshToken(refreshToken);
      }
    },
    // Drop the now-dead persisted session when a refresh fails. Clears the
    // SAME keys as a full logout (token + refresh token + user id) so nothing
    // is orphaned in secure storage.
    onTokensCleared: () async {
      await storage.clear();
    },
    // Read per request, so a language change applies to the next call.
    language: () => ref.read(localeProvider).languageCode,
  );
});

// Repository provider
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(
    apiClient,
    storage,
    language: () => ref.read(localeProvider).languageCode,
  );
});

// Auth state provider
final StateNotifierProvider<AuthNotifier, AuthState> authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final notifier = AuthNotifier(repository);
  // Read lazily: pushService depends on apiClient, which depends back on this.
  notifier.beforeLogout = () => ref.read(pushServiceProvider).unregister();
  notifier.onSessionEnded =
      () => ref.read(pushServiceProvider).discardLocalToken();
  return notifier;
});

// Current user provider
final currentUserProvider = FutureProvider.autoDispose<User?>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (authState is! AuthAuthenticated) return null;
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

// Auth notifier for managing auth state
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  /// Awaited first in [logout], while the session is still valid (push token
  /// removal needs auth). Must not throw.
  Future<void> Function()? beforeLogout;

  /// Awaited when the session ended without a usable server call
  /// ([handleUnauthorized], [completeAccountDeletion]). Must not throw.
  Future<void> Function()? onSessionEnded;

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final response = await _repository.login(email, password);
      state = AuthAuthenticated(user: response.user, token: response.token);
    } catch (e) {
      // Catch Error too (not just Exception): a malformed response can throw a
      // TypeError/CastError during parsing, which would otherwise leave the
      // state stuck in AuthLoading and hang the login button forever.
      state = AuthError(
        message: e.toString(),
        statusCode: e is AuthException ? e.statusCode : null,
      );
    }
  }

  /// Flip to authenticated from an already-completed auth call (OTP verify /
  /// register / password login done directly against the repository). The
  /// repository has persisted the tokens; this just drives the router redirect.
  void setSession(AuthResponse response) {
    state = AuthAuthenticated(user: response.user, token: response.token);
  }

  /// Called from the API layer when an authenticated request comes back 401
  /// with no usable refresh token — the session is already dead. Performs a
  /// FULL local teardown (secure storage + ApiClient in-memory token + the
  /// repo's cached token) via the same clear path as [logout], WITHOUT a
  /// server-side logout call, then flips to unauthenticated so the router
  /// redirect drops the user to /login from a single place.
  ///
  /// No-op unless currently authenticated, so it can't clobber an in-flight
  /// login's AuthLoading/AuthError (a failed login must not force-clear).
  Future<void> handleUnauthorized() async {
    if (state is! AuthAuthenticated) return;
    await onSessionEnded?.call();
    await _repository.clearSession();
    state = const AuthInitial();
  }

  Future<void> logout() async {
    await beforeLogout?.call();
    await _repository.logout();
    state = const AuthInitial();
  }

  /// After the server confirmed account deletion: local teardown (tokens,
  /// secure storage) via the shared clear path, then unauthenticated so the
  /// router drops to /login. No server call — the account no longer exists.
  Future<void> completeAccountDeletion() async {
    await onSessionEnded?.call();
    await _repository.clearSession();
    state = const AuthInitial();
  }

  Future<void> checkAuth() async {
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthAuthenticated(user: user, token: _repository.token ?? '');
      } else {
        // getCurrentUser returned null → a genuine 401 (session invalid) or no
        // stored token. Either way the session is dead: clear + unauthenticate.
        await _repository.clearSession();
        state = const AuthInitial();
      }
    } catch (_) {
      // A TRANSIENT failure (offline / timeout / 5xx) — not a 401. Don't
      // discard a still-valid stored token: if we hold one, keep the session
      // optimistically authenticated (from the cached/restored user) instead
      // of bouncing to /login. A later request that truly 401s will tear the
      // session down via handleUnauthorized.
      final token = _repository.token;
      final user = _repository.cachedUser;
      if (token != null && token.isNotEmpty && user != null) {
        state = AuthAuthenticated(user: user, token: token);
      } else {
        state = const AuthInitial();
      }
    }
  }

  Future<void> restoreToken() async {
    try {
      await _repository.restoreToken();
      await checkAuth();
    } catch (_) {
      state = const AuthInitial();
    }
  }
}

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user, required this.token});

  final User user;
  final String token;
}

class AuthError extends AuthState {
  const AuthError({required this.message, this.statusCode});

  final String message;

  /// Originating HTTP status when the failure was an [AuthException]/API error,
  /// so the UI can classify (401 vs network/5xx) without string-matching.
  final int? statusCode;
}
