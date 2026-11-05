import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/studio_session.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  test('a cancelled iOS navigation (-999) is not a load failure', () {
    // WKWebView cancels the bootstrap page when the app loads the studio route.
    const err = WebResourceError(errorCode: -999, description: '', isForMainFrame: true);
    expect(isStudioLoadFailure(err), isFalse);
  });

  test('a main-frame network error is a load failure', () {
    const err = WebResourceError(
      errorCode: -1009,
      description: 'The Internet connection appears to be offline.',
      errorType: WebResourceErrorType.connect,
      isForMainFrame: true,
    );
    expect(isStudioLoadFailure(err), isTrue);
  });

  test('a sub-resource error is not a load failure', () {
    const err = WebResourceError(errorCode: -1001, description: 'timed out', isForMainFrame: false);
    expect(isStudioLoadFailure(err), isFalse);
  });

  test('an error without a frame flag counts as main-frame', () {
    const err = WebResourceError(errorCode: -6, description: 'connect failed');
    expect(isStudioLoadFailure(err), isTrue);
  });
}
