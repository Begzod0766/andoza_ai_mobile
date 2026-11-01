import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/screens/mebel/mebel_bridge.dart';
import 'package:tamir_uy_mobile_flutter/screens/mebel/mebel_webview_screen.dart';

void main() {
  test('a CSV message from the page is read, anything else is ignored', () {
    expect(parseMebelCsv('{"name":"Oshxona.csv","text":"﻿ID;Detal"}'),
        (name: 'Oshxona.csv', text: '﻿ID;Detal'));
    expect(parseMebelCsv('not json'), isNull);
    expect(parseMebelCsv('{"name":1,"text":"x"}'), isNull);
    expect(parseMebelCsv('[1]'), isNull);
  });

  test('the CSV keeps one byte-order mark, which the blob read drops', () {
    expect(withCsvBom('ID;Detal'), '\uFEFFID;Detal');
    expect(withCsvBom('\uFEFFID;Detal'), '\uFEFFID;Detal');
  });

  test('the CSV file name is safe and ends in .csv', () {
    expect(mebelCsvFileName('Oshxona.csv'), 'Oshxona.csv');
    expect(mebelCsvFileName('Oshxona — Fasad'), 'Oshxona — Fasad.csv');
    expect(mebelCsvFileName('a/b:c'), 'a_b_c.csv');
    expect(mebelCsvFileName('  '), 'cut-list.csv');
  });

  test('only pages outside /mebel count as leaving the workshop', () {
    expect(hasLeftMebel('https://andozaai.uz/mebel?app=1'), isFalse);
    expect(hasLeftMebel('https://andozaai.uz/mebel/p1'), isFalse);
    expect(hasLeftMebel('https://andozaai.uz/login'), isTrue);
    expect(hasLeftMebel('https://andozaai.uz/mebelx'), isTrue);
    expect(hasLeftMebel(null), isFalse);
    expect(hasLeftMebel(''), isFalse);
  });

  test('the bridge hands print and blob downloads to the app channels', () {
    expect(mebelBridgeJs, contains('window.print = function'));
    expect(mebelBridgeJs, contains('$mebelPrintChannel.postMessage'));
    expect(mebelBridgeJs, contains("indexOf('blob:') === 0"));
    expect(mebelBridgeJs, contains('$mebelDownloadChannel.postMessage'));
  });
}
