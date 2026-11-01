import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import 'analytics_service.dart';

/// Keeps the analytics/crashlytics user id in sync with the auth session:
/// authenticated -> user id; any other state after having been authenticated
/// -> cleared.
final sessionTelemetryProvider = Provider<void>((ref) {
  final sink = ref.read(analyticsSinkProvider);
  var wasAuthenticated = false;

  void apply(AuthState state) {
    if (state is AuthAuthenticated) {
      wasAuthenticated = true;
      sink.setUserId(state.user.id);
    } else if (wasAuthenticated) {
      wasAuthenticated = false;
      sink.setUserId(null);
    }
  }

  apply(ref.read(authStateProvider));
  ref.listen<AuthState>(authStateProvider, (_, next) => apply(next));
});
