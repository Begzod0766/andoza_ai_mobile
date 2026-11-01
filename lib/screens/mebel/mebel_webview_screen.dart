import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/app_config.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/error_view.dart';
import '../studio/studio_session.dart';
import '../studio/studio_webview_screen.dart' show studioPageUrl;
import 'mebel_bridge.dart';

/// Whether [url] is outside the web mebel workshop (`/mebel`, `/mebel/{id}`),
/// e.g. `/login` when the web session ended. Null/empty is not.
bool hasLeftMebel(String? url) {
  final path = Uri.tryParse(url ?? '')?.path ?? '';
  if (path.isEmpty) return false;
  return path != '/mebel' && !path.startsWith('/mebel/');
}

/// The web mebel workshop (`/mebel`) in a WebView, like the 3D Studio: the
/// cut lists, nesting and drawings are computed by the web page, so the app
/// does not repeat them. The session is handed over the same way
/// ([seedStudioCookies]); back steps back inside the page (project → list)
/// before closing; the page's PDF and CSV exports go to the system print
/// dialog and share sheet ([mebelBridgeJs]).
class MebelWebViewScreen extends ConsumerStatefulWidget {
  const MebelWebViewScreen({super.key});

  @override
  ConsumerState<MebelWebViewScreen> createState() => _MebelWebViewScreenState();
}

class _MebelWebViewScreenState extends ConsumerState<MebelWebViewScreen> {
  WebViewController? _controller;
  bool _seeded = false;
  // True once a /mebel page has loaded; before that the origin bounces
  // through '/' and /login while the session is seeded.
  bool _ready = false;
  bool _loading = true;
  bool _closing = false;
  // Signed out: nothing to hand to the page. Worded in build(), since
  // _init runs from initState, before localizations can be read.
  bool _signedOut = false;
  String? _error;

  String get _targetUrl => studioPageUrl(
    AppConfig.studioBaseUrl,
    '/mebel',
    language: ref.read(localeProvider).languageCode,
  );

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final auth = ref.read(authStateProvider);
    if (auth is! AuthAuthenticated) {
      _signedOut = true;
      _loading = false;
      return;
    }
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(DesignTokens.white)
      ..addJavaScriptChannel(mebelPrintChannel, onMessageReceived: (m) => _export(() => printMebelHtml(m.message)))
      ..addJavaScriptChannel(mebelDownloadChannel, onMessageReceived: (m) {
        final csv = parseMebelCsv(m.message);
        if (csv != null) _export(() => shareMebelCsv(csv, origin: _shareOrigin()));
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          // The WebView carries the user's session: never follow a main-frame
          // navigation off the studio origin.
          onNavigationRequest: (request) {
            if (request.isMainFrame && !isAllowedStudioUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            if (_ready && request.isMainFrame && hasLeftMebel(request.url)) {
              _close();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          // Client-side route changes (the session ending → /login).
          onUrlChange: (change) {
            if (_ready && hasLeftMebel(change.url)) _close();
          },
          onPageFinished: (url) async {
            if (!_seeded) {
              _seeded = true;
              await _controller!.runJavaScript(studioAuthSeedJs(auth.user));
              await _controller!.loadRequest(Uri.parse(_targetUrl));
              return;
            }
            if (hasLeftMebel(url)) return;
            _ready = true;
            await _controller!.runJavaScript(mebelBridgeJs).catchError((_) {});
            if (mounted && _loading) setState(() => _loading = false);
          },
          onWebResourceError: (err) {
            if ((err.isForMainFrame ?? true) && mounted) {
              setState(() {
                _loading = false;
                _error = AppLocalizations.of(context)!.studioLoadFailed(err.description);
              });
            }
          },
        ),
      );
    setState(() => _controller = controller);
    _bootstrap(auth, controller);
  }

  Future<void> _bootstrap(AuthAuthenticated auth, WebViewController controller) async {
    await seedStudioCookies(auth, ref.read(secureStorageProvider));
    // The origin root first, so localStorage is writable for the seed.
    await controller.loadRequest(Uri.parse(AppConfig.studioBaseUrl));
  }

  /// The screen's area, for the share sheet to point from.
  Rect _shareOrigin() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return const Rect.fromLTWH(0, 0, 1, 1);
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _export(Future<void> Function() run) async {
    try {
      await run();
    } catch (e) {
      debugPrint('Mebel export failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.mebelExportFailed)),
      );
    }
  }

  /// A project steps back to the list; the list (or an error) closes. The
  /// page saves on its own, so there is nothing to confirm.
  Future<void> _back() async {
    final controller = _controller;
    if (_error == null && !_signedOut && controller != null && await controller.canGoBack()) {
      await controller.goBack();
      return;
    }
    _close();
  }

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    Future.microtask(() {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    });
  }

  void _retry() {
    setState(() {
      _error = null;
      _signedOut = false;
      _loading = true;
      _seeded = false;
      _ready = false;
      _closing = false;
      _controller = null;
    });
    _init();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = _signedOut ? l10n.studioLoginRequired : _error;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: DesignTokens.white,
        appBar: AppBar(
          title: Text(l10n.profileMenuMebel),
          leading: BackButton(onPressed: _back),
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              if (error == null && _controller != null) WebViewWidget(controller: _controller!),
              if (_loading && error == null) const Center(child: CircularProgressIndicator()),
              if (error != null) ErrorView(message: error, onRetry: _retry, icon: Icons.chair_outlined),
            ],
          ),
        ),
      ),
    );
  }
}
