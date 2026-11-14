import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_tour_steps.dart';

/// One [GlobalKey] per tour target. A single instance is shared between the
/// app shell (nav-bar targets) and the home screen (card targets).
class HomeTourKeys {
  HomeTourKeys()
      : keys = {for (final t in HomeTourTarget.values) t: GlobalKey(debugLabel: 'tour_${t.name}')};

  final Map<HomeTourTarget, GlobalKey> keys;

  GlobalKey of(HomeTourTarget t) => keys[t]!;
}

final homeTourKeysProvider = Provider<HomeTourKeys>((ref) => HomeTourKeys());

/// Keeps the steps whose target is currently mounted and laid out.
List<HomeTourTarget> presentTargets(List<HomeTourTarget> steps, HomeTourKeys keys) {
  return steps.where((s) {
    final ctx = keys.of(s).currentContext;
    if (ctx == null) return false;
    final ro = ctx.findRenderObject();
    return ro is RenderBox && ro.attached && ro.hasSize;
  }).toList();
}
