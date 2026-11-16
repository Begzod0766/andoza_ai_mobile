import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/studio_freshness.dart';

const _html = '''
<!doctype html><html><head>
<script>window.__cfg = {}</script>
<script type="module" crossorigin src="/assets/index-B7xQ2.js"></script>
<link rel="stylesheet" href="/assets/index-C1.css">
</head><body><div id="root"></div></body></html>
''';

void main() {
  test('finds the module entry script, not inline or classic scripts', () {
    expect(studioEntryScript(_html), '/assets/index-B7xQ2.js');
    expect(studioEntryScript('<script src="/a.js"></script>'), isNull);
    expect(studioEntryScript('<p>no scripts</p>'), isNull);
  });

  test('attribute order and quotes do not matter', () {
    expect(studioEntryScript("<script src='/assets/x.js' type='module'></script>"), '/assets/x.js');
  });

  test('same build is fresh, also when the bridge returns a full or quoted url', () {
    expect(studioIsStale(loaded: '/assets/index-B7xQ2.js', serverHtml: _html), isFalse);
    expect(studioIsStale(loaded: '"/assets/index-B7xQ2.js"', serverHtml: _html), isFalse);
    expect(studioIsStale(loaded: 'https://andozaai.uz/assets/index-B7xQ2.js', serverHtml: _html), isFalse);
  });

  test('a page on an older build is stale', () {
    expect(studioIsStale(loaded: '/assets/index-OLD.js', serverHtml: _html), isTrue);
  });

  test('unknown on either side never triggers a reload', () {
    expect(studioIsStale(loaded: null, serverHtml: _html), isFalse);
    expect(studioIsStale(loaded: '', serverHtml: _html), isFalse);
    expect(studioIsStale(loaded: '/assets/index-OLD.js', serverHtml: null), isFalse);
    expect(studioIsStale(loaded: '/assets/index-OLD.js', serverHtml: '<html></html>'), isFalse);
  });
}
