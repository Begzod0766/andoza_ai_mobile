import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/app_config.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/secure_storage.dart';

/// The web session a WebView on the studio origin needs (the 3D Studio, the
/// mebel workshop): the access and refresh token cookies, and the
/// `uy-tamir-auth` localStorage flag the web app's route guard reads.

/// Whether [host] is a local development host (loopback or private LAN) for
/// which plaintext http is acceptable. Mirrors the cleartext allow-list in
/// android/app/src/main/res/xml/network_security_config.xml.
bool isDevStudioHost(String host) {
  const explicit = {
    '10.0.2.2', // Android emulator host loopback
    'localhost',
    '127.0.0.1',
    '192.168.1.29', // CLAUDE.md dev backend
    '192.168.1.5', // CLAUDE.md dev host
  };
  if (explicit.contains(host)) return true;
  // Common private LAN ranges used for on-device development.
  return host.startsWith('192.168.') ||
      host.startsWith('10.') ||
      host.startsWith('172.16.');
}

/// Whether [url] is a navigation a studio WebView is allowed to follow: it
/// must share the studio's host, and use https (or plain http only when the
/// studio origin is itself a local dev host). This stops an open-redirect /
/// injected `window.location` to a foreign origin from staying inside a
/// JS-enabled, auth-seeded WebView.
bool isAllowedStudioUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
  final studio = Uri.parse(AppConfig.studioBaseUrl);
  if (uri.host != studio.host) return false;
  if (uri.scheme == 'https') return true;
  // Plain http is only acceptable to a local dev host.
  return uri.scheme == 'http' && isDevStudioHost(studio.host);
}

/// Sets the token cookies for the studio origin.
///
/// Never sends auth tokens as cleartext cookies over an insecure origin: a
/// plaintext http:// studio pointed at a non-loopback host would leak both
/// the access and refresh tokens on the wire. https is always safe; plain
/// http is tolerated only for local dev hosts, where there's no meaningful
/// MITM surface. Otherwise nothing is seeded and the page loads unauthenticated.
Future<void> seedStudioCookies(
  AuthAuthenticated auth,
  SecureStorageService storage,
) async {
  final studioUri = Uri.parse(AppConfig.studioBaseUrl);
  final host = studioUri.host;
  if (studioUri.scheme != 'https' && !isDevStudioHost(host)) {
    debugPrint(
      'StudioWebView: refusing to seed auth cookies to insecure origin '
      '${AppConfig.studioBaseUrl} (non-https, non-dev host); loading '
      'without auth to avoid sending tokens in cleartext.',
    );
    return;
  }

  final cookies = WebViewCookieManager();

  // Set the access-token cookie for the shared host so the frontend's
  // credentialed API calls are authenticated (cookies ignore port, so one
  // cookie covers both the frontend and the API when they share a host — the
  // default). If STUDIO_BASE_URL is pointed at a different host than the API,
  // this cookie won't reach the API and its calls will 401.
  await cookies.setCookie(
    WebViewCookie(name: 'token', value: auth.token, domain: host, path: '/'),
  );

  // Also seed the refresh-token cookie so the studio's api.ts can silently
  // refresh once the short-lived access token expires — without this the
  // WebView session dies at the access-token TTL. The web refresh path
  // (`_tryRefresh` in frontend/src/lib/api.ts) is a bare
  // `POST {API}/auth/refresh` with `credentials: "include"` and NO body: it
  // relies entirely on the backend reading the `refresh_token` cookie (see
  // backend auth.py `refresh_tokens`, a `refresh_token: Cookie()` param). The
  // backend scopes that cookie to `path=/api/v1/auth/refresh`, so we mirror it
  // exactly — same name, same path — and the WebView will send it on the
  // refresh call. The value is the refresh token the mobile app already holds
  // in secure storage; the backend rotates both cookies on each refresh, so
  // the studio session then outlives the access-token TTL on its own.
  final refreshToken = await storage.getRefreshToken();
  if (refreshToken != null && refreshToken.isNotEmpty) {
    // Derive the refresh path from the configured API base path so it stays
    // in sync with the backend's cookie scope (`/api/v1` by default).
    final apiPath = Uri.parse(AppConfig.apiUrl).path;
    final basePath =
        apiPath.endsWith('/') ? apiPath.substring(0, apiPath.length - 1) : apiPath;
    await cookies.setCookie(
      WebViewCookie(
        name: 'refresh_token',
        value: refreshToken,
        domain: host,
        path: '$basePath/auth/refresh',
      ),
    );
  }
}

/// JS that writes the Zustand `uy-tamir-auth` persisted state so the web
/// app's route guard sees an authenticated session.
String studioAuthSeedJs(User user) {
  final payload = jsonEncode({
    'state': {
      'user': {
        'id': user.id,
        'phone': user.phone,
        'username': user.username,
        'name': user.name,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
      'isAuthenticated': true,
    },
    'version': 0,
  });
  // jsonEncode again to safely embed as a JS string literal.
  return "localStorage.setItem('uy-tamir-auth', ${jsonEncode(payload)});";
}
