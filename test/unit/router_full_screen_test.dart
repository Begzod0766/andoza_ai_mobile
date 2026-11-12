import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tamir_uy_mobile_flutter/config/router.dart';

GoRoute? _find(List<RouteBase> routes, String path) {
  for (final r in routes) {
    if (r is GoRoute && r.path == path) return r;
    final hit = _find(r.routes, path);
    if (hit != null) return hit;
  }
  return null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Flows the bottom bar must not cover: one tap on it abandons them.
  const fullScreen = [
    '/shop/s6',
    '/shop/s7',
    '/masters/u3',
    // The profile is pushed from U3, which sits on the root navigator: a
    // shell-navigator U4 landed underneath it and the tap did nothing.
    '/masters/u4',
    '/masters/u5',
    '/setup/dimensions',
    '/setup/wall-measurements',
    '/setup/summary',
  ];

  test('checkout, booking and room setup open on the root navigator', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    final GlobalKey<NavigatorState> root = router.configuration.navigatorKey;
    for (final path in fullScreen) {
      final route = _find(router.configuration.routes, path);
      expect(route, isNotNull, reason: path);
      expect(route!.parentNavigatorKey, same(root), reason: path);
    }
  });
}
