import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/router.dart';
import '../providers/auth_provider.dart';
import 'push_router.dart';

/// True for a link the backend takes as a Pinterest pin source: https, and
/// `pin.it` or a Pinterest domain (`www.pinterest.com`, `mx.pinterest.com`,
/// `pinterest.co.uk`...). The server checks the path and the id itself.
/// Mirrors `looksLikePinUrl` in the web app's `lib/api/ai.ts`.
bool looksLikePinUrl(String text) {
  final uri = Uri.tryParse(text.trim());
  if (uri == null || uri.scheme != 'https') return false;
  var host = uri.host.toLowerCase();
  if (host.endsWith('.')) host = host.substring(0, host.length - 1);
  return host == 'pin.it' || RegExp(r'(^|\.)pinterest\.[a-z.]+$').hasMatch(host);
}

/// The pin link inside shared text, e.g. the Pinterest app's
/// "Check out this Pin! https://pin.it/AbCd12", or null when there is none.
/// Mirrors `findPinUrl` in the web app.
String? findPinUrl(String text) {
  for (final m in RegExp(r'https://\S+').allMatches(text)) {
    final candidate = m.group(0)!;
    if (looksLikePinUrl(candidate)) return candidate;
  }
  return null;
}

/// The screen a share opens: it checks the text and asks which room.
String sharePinRoute(String text) =>
    Uri(path: '/share/pin', queryParameters: {'text': text}).toString();

/// Native side: `ShareChannel.kt` (Android, the share intent) and
/// `ShareChannel.swift` (iOS, fed by the Share Extension through
/// `andozaai-share://pin?text=…`).
const shareChannel = MethodChannel('andoza/share');

/// Text shared to the app ("Share → Andoza AI") opens [sharePinRoute]: at
/// once when signed in, otherwise after sign-in (the router's pending route,
/// the same hand-off a tapped push uses).
class ShareIntentHandler {
  ShareIntentHandler(this._read, {this.navigate});

  final ProviderReader _read;

  /// Opens a route; set to the app router's `push`.
  void Function(String route)? navigate;

  void open(String text) {
    final route = sharePinRoute(text);
    final go = navigate;
    if (_read(authStateProvider) is AuthAuthenticated && go != null) {
      go(route);
    } else {
      _read(pendingPushRouteProvider.notifier).state = route;
    }
  }

  /// Listens for shares while the app runs and takes the one it was started
  /// with, if any.
  Future<void> attach(MethodChannel channel) async {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'shared' && call.arguments is String) {
        open(call.arguments as String);
      }
    });
    try {
      final initial = await channel.invokeMethod<String>('take');
      if (initial != null && initial.trim().isNotEmpty) open(initial);
    } on MissingPluginException {
      // Tests and platforms without the share channel.
    } catch (e) {
      debugPrint('Share intent setup failed: $e');
    }
  }
}

/// Keep-alive, watched by the app: wires shares to the router.
final shareIntentProvider = Provider<void>((ref) {
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }
  final handler = ShareIntentHandler(ref.read);
  handler.navigate = (route) => ref.read(routerProvider).push(route);
  handler.attach(shareChannel);
  ref.onDispose(() => shareChannel.setMethodCallHandler(null));
});
