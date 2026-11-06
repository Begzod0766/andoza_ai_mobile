import 'dart:io';
import 'dart:ui' show Rect;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Writes raw PDF [bytes] to a temporary file and opens the system share sheet
/// so the user can save/print/send the smeta. Returns the file path written.
///
/// [origin] is the area (in global coordinates) the share sheet points from —
/// usually the tapped button's `localToGlobal(Offset.zero) & size`. iOS 26
/// rejects a share without a non-zero origin inside the source view, and the
/// iPad popover anchors to it.
///
/// Kept UI-free so it can be called from any screen and unit-reasoned about;
/// the caller handles snackbars/errors.
Future<String> sharePdfBytes(
  List<int> bytes, {
  required String fileName,
  required Rect origin,
  String? shareText,
}) {
  final safeName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
  return shareFileBytes(
    bytes,
    fileName: safeName,
    mimeType: 'application/pdf',
    origin: origin,
    shareText: shareText,
  );
}

/// Like [sharePdfBytes], for any file type (e.g. a file the Studio WebView
/// downloads). [fileName] must be a bare name, without a path.
Future<String> shareFileBytes(
  List<int> bytes, {
  required String fileName,
  required String mimeType,
  required Rect origin,
  String? shareText,
}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);

  await Share.shareXFiles(
    [XFile(file.path, mimeType: mimeType)],
    text: shareText,
    sharePositionOrigin: origin,
  );
  return file.path;
}
