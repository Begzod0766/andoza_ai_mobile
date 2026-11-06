import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/webview_download.dart';

String _msg(Map<String, Object?> m) => jsonEncode(m);

void main() {
  final pdf = utf8.encode('%PDF-1.4 test');

  test('a PDF from the Studio decodes to its bytes, name and type', () {
    final d = parseWebDownload(_msg({
      'name': 'smeta-42.pdf',
      'type': 'application/pdf',
      'data': base64Encode(pdf),
    }));
    expect(d, isNotNull);
    expect(d!.fileName, 'smeta-42.pdf');
    expect(d.mimeType, 'application/pdf');
    expect(d.bytes, pdf);
  });

  test('a path in the name cannot leave the temporary folder', () {
    final d = parseWebDownload(_msg({
      'name': '../../Library/evil.pdf',
      'type': 'application/pdf',
      'data': base64Encode(pdf),
    }));
    expect(d!.fileName, 'evil.pdf');
  });

  test('an empty or unsafe name falls back to a plain one', () {
    final d = parseWebDownload(_msg({
      'name': '..',
      'type': 'application/pdf',
      'data': base64Encode(pdf),
    }));
    expect(d!.fileName, 'andoza.pdf');
  });

  test('a missing type is guessed from the name', () {
    final d = parseWebDownload(_msg({
      'name': 'mebel.csv',
      'data': base64Encode(utf8.encode('a,b')),
    }));
    expect(d!.mimeType, 'text/csv');
  });

  test('garbage, empty data or bad base64 give nothing', () {
    expect(parseWebDownload('not json'), isNull);
    expect(parseWebDownload(_msg({'name': 'a.pdf', 'data': ''})), isNull);
    expect(parseWebDownload(_msg({'name': 'a.pdf', 'data': '%%%'})), isNull);
    expect(parseWebDownload('[1,2]'), isNull);
  });

  test('the page script hooks blob downloads and posts to the channel', () {
    expect(webDownloadHookJs, contains(webDownloadChannel));
    expect(webDownloadHookJs, contains('createObjectURL'));
    expect(webDownloadHookJs, contains('a[download]'));
  });
}
