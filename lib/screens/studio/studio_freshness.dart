/// Keeping the Studio WebView on the deployed version.
///
/// The server sends `index.html` with `Cache-Control: no-cache`, so a Studio
/// opened fresh always gets the current build. A page left open across a
/// deploy, though, keeps running the build it loaded: the app can sit in the
/// background for hours with the Studio open. When the app comes back, the
/// screen compares the page's entry script with the one the server's
/// `index.html` names now and reloads the page if they differ.
library;

/// JS returning the `src` of the page's module entry script
/// (`/assets/index-<hash>.js`), or '' when there is none.
const studioLoadedEntryJs = '''
(function () {
  var s = document.querySelector('script[type="module"][src]');
  return s ? s.getAttribute('src') : '';
})()
''';

final _moduleScript = RegExp(r'<script\b[^>]*>', caseSensitive: false);
final _srcAttr = RegExp(r'''\bsrc\s*=\s*["']([^"']+)["']''', caseSensitive: false);
final _moduleType = RegExp(r'''\btype\s*=\s*["']module["']''', caseSensitive: false);

/// The `src` of the first module script in [html], or null.
String? studioEntryScript(String html) {
  for (final tag in _moduleScript.allMatches(html)) {
    final t = tag.group(0)!;
    if (!_moduleType.hasMatch(t)) continue;
    final src = _srcAttr.firstMatch(t)?.group(1);
    if (src != null && src.isNotEmpty) return src;
  }
  return null;
}

/// The path part of a script src, so `https://host/assets/a.js` and
/// `/assets/a.js` compare equal. A WebView may report either form.
String _pathOf(String src) => Uri.tryParse(src)?.path ?? src;

/// The JS bridge may hand the string back JSON-quoted (`"/assets/a.js"`).
String _unquote(String s) {
  final t = s.trim();
  if (t.length >= 2 && t.startsWith('"') && t.endsWith('"')) {
    return t.substring(1, t.length - 1);
  }
  return t;
}

/// Whether the page running [loaded] (as the JS bridge returned it) is older
/// than the build [serverHtml] points at. Unknown on either side → false:
/// never reload on a guess.
bool studioIsStale({required String? loaded, required String? serverHtml}) {
  if (loaded == null || serverHtml == null) return false;
  final current = _unquote(loaded);
  final latest = studioEntryScript(serverHtml);
  if (current.isEmpty || latest == null) return false;
  return _pathOf(current) != _pathOf(latest);
}
