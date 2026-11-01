import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Rect;

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/app_config.dart';

/// JS channel the page's `window.print()` posts the printout's HTML to.
const mebelPrintChannel = 'AndozaPrint';

/// JS channel a CSV download is posted to, as `{"name": …, "text": …}`.
const mebelDownloadChannel = 'AndozaDownload';

/// Run after every page load. A WebView does nothing on `window.print()` and
/// on a `<a download href="blob:…">` click, which is how the web mebel page
/// prints (PDF) and exports its CSV (`features/mebel/export/csv.ts`); this
/// hands both to the app instead. The blob is read at click time, before the
/// page revokes it.
const mebelBridgeJs = '''
(function () {
  if (window.__andozaBridge) return;
  window.__andozaBridge = true;
  window.print = function () {
    var doc = document.documentElement.cloneNode(true);
    doc.querySelectorAll('script').forEach(function (s) { s.remove(); });
    $mebelPrintChannel.postMessage('<!doctype html>' + doc.outerHTML);
  };
  var click = HTMLAnchorElement.prototype.click;
  HTMLAnchorElement.prototype.click = function () {
    if (this.download && this.href.indexOf('blob:') === 0) {
      var name = this.download;
      fetch(this.href).then(function (r) { return r.text(); }).then(function (text) {
        $mebelDownloadChannel.postMessage(JSON.stringify({ name: name, text: text }));
      });
      return;
    }
    return click.call(this);
  };
})();
''';

/// A CSV the page handed over: its file name and text.
typedef MebelCsv = ({String name, String text});

/// The CSV in a [mebelDownloadChannel] message, or null if it is not one.
MebelCsv? parseMebelCsv(String message) {
  try {
    final json = jsonDecode(message);
    if (json is! Map) return null;
    final name = json['name'];
    final text = json['text'];
    if (name is! String || text is! String) return null;
    return (name: name, text: text);
  } catch (_) {
    return null;
  }
}

/// [name] safe as a file name, ending in `.csv`.
String mebelCsvFileName(String name) {
  final base = name.replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_').trim();
  final safe = base.isEmpty ? 'cut-list' : base;
  return safe.toLowerCase().endsWith('.csv') ? safe : '$safe.csv';
}

/// [text] starting with a UTF-8 byte-order mark, which Excel needs to read
/// Cyrillic. The page writes one, but `Response.text()` (how the bridge reads
/// the blob) drops it.
String withCsvBom(String text) => text.startsWith('\uFEFF') ? text : '\uFEFF$text';

/// Writes the CSV to a temporary file and opens the share sheet.
/// [origin] is where the sheet points from: iOS 26 refuses to open one
/// without it ("sharePositionOrigin: argument must be set").
Future<void> shareMebelCsv(MebelCsv csv, {required Rect origin}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${mebelCsvFileName(csv.name)}');
  await file.writeAsString(withCsvBom(csv.text), encoding: utf8, flush: true);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'text/csv')],
    sharePositionOrigin: origin,
  );
}

/// Opens the system print dialog (with "Save as PDF") for the page's
/// printout. Its stylesheets load from the studio origin, so the print
/// styles apply.
///
/// The dialog starts in A4 landscape, which the page's own `@page` asks for
/// and the HTML conversion does not read: in portrait the cut list's edge
/// banding columns fell off the page. Changing the orientation in the dialog
/// lays the printout out again ([Printing.layoutPdf]'s dynamic layout).
///
/// `convertHtml` is marked deprecated but still maintained on Android and iOS
/// (5.15.1 fixed it for iOS 26); it is the one way to print a page that only
/// exists inside a WebView.
Future<void> printMebelHtml(String html) {
  return Printing.layoutPdf(
    name: 'Andoza mebel',
    format: PdfPageFormat.a4.landscape,
    // ignore: deprecated_member_use
    onLayout: (format) => Printing.convertHtml(
      html: html,
      baseUrl: AppConfig.studioBaseUrl,
      format: format,
    ),
  );
}
