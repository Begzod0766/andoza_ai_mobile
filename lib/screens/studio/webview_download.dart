import 'dart:convert';
import 'dart:typed_data';

/// File downloads from the Studio WebView (the estimate's "Download PDF",
/// the furniture CSV export).
///
/// The web app saves a file the browser way: a `blob:` URL on an
/// `<a download>` that it clicks, often without adding it to the page. Neither
/// WKWebView nor Android's WebView does anything with that unless the app
/// handles downloads, so the tap did nothing at all (QA 2026-11-06, 6.6).
///
/// [webDownloadHookJs] runs in the page: it remembers the blobs behind
/// `URL.createObjectURL`, catches the click on such a link, and posts the file
/// to the [webDownloadChannel] JavaScript channel as base64. The screen then
/// writes it to a temporary file and opens the share sheet.

/// Name of the JavaScript channel the page posts files to.
const webDownloadChannel = 'AndozaDownload';

/// Page script; safe to run more than once per document.
const webDownloadHookJs = '''
(function () {
  if (window.__andozaDownloadHook) return;
  window.__andozaDownloadHook = true;
  var blobs = {};
  var create = URL.createObjectURL;
  var revoke = URL.revokeObjectURL;
  URL.createObjectURL = function (obj) {
    var url = create.call(URL, obj);
    if (obj instanceof Blob) blobs[url] = obj;
    return url;
  };
  // The page revokes right after its click; keep the blob a little longer.
  URL.revokeObjectURL = function (url) {
    setTimeout(function () { delete blobs[url]; }, 10000);
    return revoke.call(URL, url);
  };
  function send(a) {
    var blob = a && a.hasAttribute && a.hasAttribute('download') ? blobs[a.href] : null;
    if (!blob || !window.$webDownloadChannel) return false;
    var reader = new FileReader();
    reader.onload = function () {
      var s = String(reader.result);
      $webDownloadChannel.postMessage(JSON.stringify({
        name: a.getAttribute('download') || '',
        type: blob.type || '',
        data: s.slice(s.indexOf(',') + 1)
      }));
    };
    reader.readAsDataURL(blob);
    return true;
  }
  // A link the page clicks from code, usually never added to the document.
  var click = HTMLAnchorElement.prototype.click;
  HTMLAnchorElement.prototype.click = function () {
    if (send(this)) return;
    return click.call(this);
  };
  // A real tap on a download link in the page.
  document.addEventListener('click', function (e) {
    var a = e.target && e.target.closest ? e.target.closest('a[download]') : null;
    if (a && send(a)) e.preventDefault();
  }, true);
})();
''';

/// A file the page handed over.
class WebDownload {
  const WebDownload({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;
}

/// Parses a [webDownloadChannel] message, or null when it is not a file.
///
/// The name keeps only its last path segment, so a page cannot write outside
/// the temporary folder.
WebDownload? parseWebDownload(String message) {
  final Object? decoded;
  try {
    decoded = jsonDecode(message);
  } on FormatException {
    return null;
  }
  if (decoded is! Map) return null;
  final data = decoded['data'];
  if (data is! String || data.isEmpty) return null;
  final Uint8List bytes;
  try {
    bytes = base64Decode(data);
  } on FormatException {
    return null;
  }
  if (bytes.isEmpty) return null;

  final rawName = decoded['name'] is String ? decoded['name'] as String : '';
  final rawType = decoded['type'] is String ? decoded['type'] as String : '';
  var name = rawName.split(RegExp(r'[/\\]')).last.trim();
  if (name.isEmpty || name == '.' || name == '..') {
    name = 'andoza${_extensionFor(rawType)}';
  }
  final type = rawType.isNotEmpty ? rawType : _typeFor(name);
  return WebDownload(fileName: name, mimeType: type, bytes: bytes);
}

String _extensionFor(String type) => switch (type) {
  'text/csv' => '.csv',
  'image/png' => '.png',
  'image/jpeg' => '.jpg',
  _ => '.pdf',
};

String _typeFor(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.csv')) return 'text/csv';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.pdf')) return 'application/pdf';
  return 'application/octet-stream';
}
