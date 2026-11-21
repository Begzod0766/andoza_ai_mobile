import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// The JavaScript channel the web Studio posts a link to when it must open
/// outside the app (andoza_ai `frontend/src/lib/externalLink.ts`): the smeta's
/// «Yandex/Google Xaritalar» buttons, a shop's Telegram, a product's page.
/// Without it the link fell through to `target="_blank"` and closed the Studio
/// (mobile QA 2026-11-21, andoza_ai#358).
const externalLinkChannel = 'AndozaExternalLink';

/// The link in [message] when it is an absolute http(s) URL with a host;
/// anything else (`javascript:`, `file:`, relative paths, junk) is ignored.
Uri? externalLinkFromMessage(String message) {
  final uri = Uri.tryParse(message.trim());
  if (uri == null) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  if (uri.host.isEmpty) return null;
  return uri;
}

/// Opens the link in [message] with the system (maps app, Telegram, browser),
/// never inside the WebView that carries the user's session. Returns whether
/// it was opened; a missing app or a bad link is reported, not thrown.
Future<bool> openExternalLink(
  String message, {
  Future<bool> Function(Uri uri, LaunchMode mode)? launcher,
}) async {
  final uri = externalLinkFromMessage(message);
  if (uri == null) return false;
  final launch =
      launcher ?? (Uri u, LaunchMode m) => launchUrl(u, mode: m);
  try {
    return await launch(uri, LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('StudioWebView: could not open an external link ($e)');
    return false;
  }
}
