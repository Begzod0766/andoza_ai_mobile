
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../config/app_config.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/error_view.dart';
import 'studio_session.dart';
import 'webview_file_chooser.dart';

/// Embeds a web page from the React/Three.js frontend (the 3D Studio or the
/// room-capture wizard) in a WebView, authenticated as the current mobile user.
///
/// [path] is the frontend route to open once auth is bridged, e.g.
/// `/studio/{roomId}` or `/wizard`. [title] is the app-bar label.
///
/// Auth bridge: the web app authenticates via an HttpOnly `token` cookie
/// (sent to the API with `credentials: "include"`) and gates its routes on a
/// Zustand `uy-tamir-auth` localStorage flag. This screen reproduces both from
/// the mobile session — it sets the access-token cookie for the shared host
/// (cookies ignore port, so one cookie covers both the :5173 frontend and :8000
/// API), a matching `refresh_token` cookie so the studio's api.ts can silently
/// refresh past the access-token TTL, and seeds the localStorage flag before
/// navigating to [path].
class StudioWebViewScreen extends ConsumerStatefulWidget {
  const StudioWebViewScreen({
    required this.path,
    super.key,
  });

  /// Convenience constructor for a specific room's 3D Studio.
  // ignore: prefer_const_constructors_in_immutables
  ///
  /// [focus] opens the room on its own, without the flat's other rooms around
  /// it (the web studio's `?focus=1`).
  // ignore: prefer_const_constructors_in_immutables
  /// [aiPin] opens the studio's AI designer with that Pinterest pin already
  /// taken (the web studio's `?ai_pin=`), after "Share → Andoza AI".
  /// [place] is a shop's furniture id the studio puts into the room as it
  /// opens (the web studio's `?place=`), from "Xonamga qo'yish".
  StudioWebViewScreen.studio({
    required String roomId,
    bool focus = false,
    String? aiPin,
    String? place,
    Key? key,
  }) : this(
         path: studioRoomPath(roomId, focus: focus, aiPin: aiPin, place: place),
         key: key,
       );

  /// The frontend route to open (e.g. `/wizard`, `/studio/{roomId}`).
  final String path;

  @override
  ConsumerState<StudioWebViewScreen> createState() =>
      _StudioWebViewScreenState();
}

/// The studio path for a room: `?focus=1` opens it alone, `?ai_pin=` opens
/// the AI designer with a Pinterest pin, `?place=` puts a shop's furniture in.
String studioRoomPath(
  String roomId, {
  bool focus = false,
  String? aiPin,
  String? place,
}) {
  final query = {
    if (focus) 'focus': '1',
    'ai_pin': ?aiPin,
    'place': ?place,
  };
  return Uri(
    path: '/studio/$roomId',
    queryParameters: query.isEmpty ? null : query,
  ).toString();
}

/// The web page to open for [path]. `app=1` tells the page it is inside the
/// app, so it hides its own back button — this screen draws one over the page.
/// `lang=` opens it in the app's language rather than the account's or the
/// phone's; the page then saves that language on the account.
String studioPageUrl(String base, String path, {String? language}) {
  final sep = path.contains('?') ? '&' : '?';
  final lang = language == null
      ? ''
      : '&lang=${Uri.encodeQueryComponent(language)}';
  return '$base$path${sep}app=1$lang';
}

/// The colour at the bottom of the web studio's 3D view.
const _studioFloorColor = Color(0xFF0F1B2A);

/// The first opaque background colour from the element at the page's bottom
/// middle up to the root, as CSS gives it ("rgb(237, 227, 250)").
const _bottomColorJs = '''
(function () {
  var el = document.elementFromPoint(window.innerWidth / 2, window.innerHeight - 2);
  for (; el; el = el.parentElement) {
    var c = getComputedStyle(el).backgroundColor;
    if (c && c !== 'transparent' && !/rgba\\(.*,\\s*0\\)\$/.test(c)) return c;
  }
  return '';
})()
''';

/// The colour in a CSS `rgb(r, g, b)` / `rgba(r, g, b, a)` string (quotes
/// around it allowed, as a WebView may return them), or null.
Color? parseCssRgb(String css) {
  final m = RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)').firstMatch(css);
  if (m == null) return null;
  return Color.fromARGB(
    255,
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
  );
}

class _StudioWebViewScreenState extends ConsumerState<StudioWebViewScreen> {
  // Nullable + built synchronously in _init before any await, so build() never
  // reads it uninitialised (a late field would throw LateInitializationError on
  // the first frame, before the async cookie/setup completes).
  WebViewController? _controller;
  bool _seeded = false;
  // True once the studio route itself has finished loading. Until then, any
  // bounce to /login is the expected pre-seed guard redirect and must be
  // ignored; only a /login navigation *after* this point means the web
  // session ended or the user exited, and should return us to the native app.
  bool _studioReady = false;
  // Guards against firing the return-to-app navigation more than once.
  bool _exiting = false;
  bool _loading = true;
  String? _error;
  // Whether the page shown is the 3D studio itself (`/studio/...`), not the
  // smeta (`/smeta/...`), whose title sits where the back button would.
  bool _onStudioPage = true;
  // The colour of the strip under the page, matched to the page's bottom.
  Color _bottomColor = _studioFloorColor;
  // Counts [_pageChanged] calls, so a slow one (it waits for the page to draw)
  // cannot overwrite what a later one found.
  int _pageSeq = 0;

  String get _targetUrl => studioPageUrl(
    AppConfig.studioBaseUrl,
    widget.path,
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
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)!.studioLoginRequired;
      });
      return;
    }

    // Construct the controller synchronously so build() always has one; the
    // first load is kicked off from _bootstrap once the cookie is set.
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(DesignTokens.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          // The WebView is meant to host ONLY the 3D Studio. Intercept a *hard*
          // navigation that leaves the studio (e.g. the web app's back button →
          // /projects, or `window.location = '/login'` on session end): cancel
          // it and pop back to the native app instead of stranding the user on
          // a web page inside the WebView. Studio sub-pages (the tabs, e.g.
          // /studio/{id}/mebelirovka) stay in the WebView.
          onNavigationRequest: (request) {
            // Origin containment: this WebView runs with JavaScript enabled and
            // is seeded with the user's auth cookies, so it must never follow a
            // main-frame navigation to a foreign host (e.g. an open-redirect to
            // https://evil.com/studio/x, which the old path-only check would
            // have happily kept in-WebView with the tokens attached). Anything
            // off the studio origin is blocked outright.
            if (request.isMainFrame && !isAllowedStudioUrl(request.url)) {
              debugPrint(
                'StudioWebView: blocked off-origin navigation to '
                '${request.url}',
              );
              return NavigationDecision.prevent;
            }
            if (_studioReady &&
                request.isMainFrame &&
                _hasLeftStudio(request.url)) {
              _returnToApp();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          // Client-side (SPA / React Router) navigations — the studio back
          // button (→ /projects), an in-app logout (→ /login), etc. — don't
          // fire a navigation request, they only change the URL. Catch them
          // here so leaving the studio still returns the user to the native app.
          onUrlChange: (change) {
            if (_studioReady && _hasLeftStudio(change.url)) {
              _returnToApp();
              return;
            }
            // Before the studio is up, the URL only bounces through the
            // bootstrap pages ('/', /login); the studio's own load reports it.
            if (_studioReady) _pageChanged(change.url);
          },
          onPageFinished: (url) async {
            // On the first load of the origin, seed the auth flag then navigate
            // to the studio route (now past the RequireAuth guard).
            if (!_seeded) {
              _seeded = true;
              // The field is assigned before any page load fires this callback.
              await _controller!.runJavaScript(studioAuthSeedJs(auth.user));
              await _controller!.loadRequest(Uri.parse(_targetUrl));
              return;
            }
            // Arm the leave-studio exit ONLY once an actual studio page has
            // finished loading. During bootstrap the origin root bounces
            // through '/', /projects and /login (multiple pageFinished events);
            // those must not arm the exit, or the next bounce would pop us
            // straight back out before the studio ever renders.
            if (!_hasLeftStudio(url) && !_studioReady) {
              _studioReady = true;
            }
            if (mounted && _loading) setState(() => _loading = false);
            if (_studioReady) _pageChanged(url);
          },
          onWebResourceError: (err) {
            // Ignore sub-resource errors; only surface a hard main-frame fail.
            if (err.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _loading = false;
                  _error = AppLocalizations.of(context)!
                      .studioLoadFailed(err.description);
                });
              }
            }
          },
        ),
      );
    // Android's WebView ignores <input type="file"> unless the app answers it,
    // so every Studio image upload did nothing there. iOS has its own picker.
    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setOnShowFileSelector(
        (params) => answerFileSelector(
          acceptTypes: params.acceptTypes,
          multiple: params.mode == FileSelectorMode.openMultiple,
          capture: params.isCaptureEnabled,
          chooseSource: _chooseImageSource,
          pick: pickWithImagePicker,
        ),
      );
    }
    setState(() => _controller = controller);
    _bootstrap(auth, controller);
  }

  /// Follows the page shown: the back button only over the 3D studio, and
  /// the strip under the page in that page's bottom colour.
  Future<void> _pageChanged(String? url) async {
    final path = Uri.tryParse(url ?? '')?.path;
    if (path == null || path.isEmpty) return;
    final seq = ++_pageSeq;
    final onStudio = path.startsWith('/studio');
    var color = _studioFloorColor;
    if (!onStudio) {
      // A client-side route change lands before the new page has drawn.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      color = await _pageBottomColor() ?? DesignTokens.white;
    }
    if (!mounted || seq != _pageSeq) return;
    setState(() {
      _onStudioPage = onStudio;
      _bottomColor = color;
    });
  }

  /// The background colour at the bottom middle of the page, or null.
  Future<Color?> _pageBottomColor() async {
    final controller = _controller;
    if (controller == null) return null;
    try {
      final result = await controller.runJavaScriptReturningResult(
        _bottomColorJs,
      );
      return parseCssRgb(result.toString());
    } catch (_) {
      return null;
    }
  }

  /// Camera or gallery, for an image upload in the Studio (Android).
  Future<ImageSource?> _chooseImageSource() {
    if (!mounted) return Future.value();
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.addProductCamera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.addProductGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bootstrap(
    AuthAuthenticated auth,
    WebViewController controller,
  ) async {
    await seedStudioCookies(auth, ref.read(secureStorageProvider));
    // First load: the origin root establishes the origin so localStorage is
    // writable. It may bounce to /login (not yet seeded) — that's expected.
    await controller.loadRequest(Uri.parse(AppConfig.studioBaseUrl));
  }

  /// Whether [url] is a page *outside* the 3D Studio, i.e. the web app has
  /// navigated away from it (back to `/projects`, `/login` on session end,
  /// the `/apartments/...` menu entry, …). The studio route itself and its
  /// tabs (`/studio`, `/studio/{id}`, `/studio/{id}/{tab}`) return false so
  /// in-studio navigation stays in the WebView. A null/empty URL returns
  /// false so a spurious url change never triggers an exit.
  bool _hasLeftStudio(String? url) {
    if (url == null) return false;
    final path = Uri.tryParse(url)?.path ?? '';
    if (path.isEmpty) return false;
    if (path == '/studio' || path.startsWith('/studio/')) return false;
    // The "Smeta" tab of the studio's 3D | Smeta switch is a top-level web
    // route (/smeta/{roomId}), not a /studio/... sub-page. Treating it as
    // "left the studio" popped the user back to the native app the moment they
    // tapped it.
    if (path.startsWith('/smeta/')) return false;
    return true;
  }

  /// Leave the WebView and return to the native app. Pops the studio route
  /// when it was pushed (e.g. from E1); otherwise (entered via `context.go`
  /// from the wizard) falls back to the native home. Runs at most once, and is
  /// deferred so it never mutates navigation from inside a WebView callback.
  ///
  /// Also fires the Studio's client-side room-thumbnail capture first: when
  /// the exit is a client-side SPA navigation (`onUrlChange`), the studio's
  /// own React unmount effect already captures the thumbnail on its own, so
  /// this is a harmless no-op duplicate. But when the exit instead comes from
  /// this WebView being torn down natively (app-bar back, system back
  /// gesture — see [_onWillPop]), that unmount effect never runs, so this is
  /// the only chance to grab the canvas before it's gone.
  void _returnToApp() {
    if (_exiting || !mounted) return;
    _exiting = true;
    _captureThumbnail();
    Future.microtask(() {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    });
  }

  /// Fire-and-forget: asks the Studio page to capture+upload the current
  /// room's thumbnail, if it's exposed `window.__captureRoomThumbnail` (see
  /// frontend/src/pages/studio/three-d/useCanvasCapture.ts). No-op on pages
  /// that never define it (e.g. not a 3D-view route, or JS not yet loaded).
  void _captureThumbnail() {
    _controller
        ?.runJavaScript('window.__captureRoomThumbnail?.();')
        .catchError((_) {});
  }

  /// Intercepts the back button over the page and the system back gesture — both go
  /// through the Navigator's pop, which this blocks (`canPop: false`) so the
  /// thumbnail capture can fire before the WebView is torn down. Without
  /// this, only an in-studio (web) navigation away triggers a capture (via
  /// the web app's own unmount effect); a native back exit would otherwise
  /// skip it entirely.
  void _onBackPressed() {
    if (_exiting) return;
    _exiting = true;
    _captureThumbnail();
    // Fire-and-forget capture needs a brief head start before the WebView
    // (and its canvas) is destroyed; the delay is imperceptible to the user.
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBackPressed();
      },
      // No app bar: the page gets the whole screen under the status bar
      // (the web studio has its own toolbar). Its left end is free, so the way
      // out sits there.
      child: Scaffold(
        backgroundColor: DesignTokens.white,
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    if (_error == null && _controller != null)
                      WebViewWidget(controller: _controller!),
                    if (_loading && _error == null)
                      const Center(child: CircularProgressIndicator()),
                    if (_error != null)
                      ErrorView(
                        message: _error!,
                        onRetry: _retry,
                        icon: Icons.view_in_ar_outlined,
                      ),
                    // Always offer a way out: the web page hides its own
                    // back button inside the app, and a Studio opened with
                    // `go` (e.g. from the room wizard) has nothing to pop.
                    // 40 pt, so it clears the toolbar's 3D/Smeta switch.
                    // Not over the smeta page, whose title is there; its
                    // 3D/Smeta switch leads back, and system back works.
                    if (_onStudioPage || _error != null)
                      Positioned(
                        top: DesignTokens.spacingSm,
                        left: DesignTokens.spacingXs,
                        child: Material(
                          color: DesignTokens.white,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: SizedBox.square(
                            dimension: 40,
                            child: BackButton(
                              onPressed: _onBackPressed,
                              style: IconButton.styleFrom(
                                padding: EdgeInsets.zero,
                                iconSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // The page stops above the home indicator (iOS) and the system
            // navigation bar (Android, drawn over the app edge to edge): the
            // studio's buttons sit at its bottom edge, and there a swipe went
            // home or the 3-button bar covered them. The strip is the 3D
            // view's floor colour (or the other page's bottom colour), so it
            // reads as part of the page.
            Container(
              height: MediaQuery.paddingOf(context).bottom,
              color: _bottomColor,
            ),
          ],
        ),
      ),
    );
  }

  void _retry() {
    setState(() {
      _error = null;
      _loading = true;
      _seeded = false;
      _studioReady = false;
      _exiting = false;
      _controller = null;
    });
    _init();
  }
}
