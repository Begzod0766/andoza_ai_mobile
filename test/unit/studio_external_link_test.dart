import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/external_link.dart';
import 'package:url_launcher/url_launcher.dart';

// Mobile QA 2026-11-21 (andoza_ai#358): the smeta's «Yandex/Google Xaritalar»
// buttons closed the Studio instead of opening the map. The web hands such
// links to the app through the `AndozaExternalLink` channel
// (andoza_ai frontend/src/lib/externalLink.ts); the app opens them with the
// system — the maps app, Telegram, the browser.
void main() {
  test('the channel name matches the web', () {
    expect(externalLinkChannel, 'AndozaExternalLink');
  });

  test('only http(s) links with a host are accepted', () {
    expect(
      externalLinkFromMessage('https://yandex.uz/maps/?pt=69.2,41.3'),
      Uri.parse('https://yandex.uz/maps/?pt=69.2,41.3'),
    );
    expect(externalLinkFromMessage('http://maps.google.com/?q=1,2'), isNotNull);
    for (final bad in [
      '',
      'javascript:alert(1)',
      'file:///etc/hosts',
      'tel:+998901234567',
      '/smeta/1',
      'https://',
      'not a url',
    ]) {
      expect(externalLinkFromMessage(bad), isNull, reason: bad);
    }
  });

  test('a good link opens outside the app, a bad one does not', () async {
    final opened = <(Uri, LaunchMode)>[];
    Future<bool> launcher(Uri uri, LaunchMode mode) async {
      opened.add((uri, mode));
      return true;
    }

    expect(
      await openExternalLink('https://t.me/andoza', launcher: launcher),
      isTrue,
    );
    expect(await openExternalLink('javascript:x', launcher: launcher), isFalse);
    expect(opened, [(Uri.parse('https://t.me/andoza'), LaunchMode.externalApplication)]);
  });

  test('a launcher failure is reported, not thrown', () async {
    Future<bool> broken(Uri uri, LaunchMode mode) async => throw Exception('no app');
    expect(await openExternalLink('https://t.me/x', launcher: broken), isFalse);
  });
}
