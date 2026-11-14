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

/// Keeps the steps whose target is mounted, laid out and fully on screen.
///
/// A scroll view lays out every child, so "laid out" is not enough: a target
/// below the fold (e.g. landscape) would put the card off screen and trap the
/// user under the blur. Rule: the target's global rect must lie inside the
/// view bounds (1px tolerance). Targets hidden behind the bottom nav bar are
/// not detected separately; nav-bar targets themselves live in that area.
List<HomeTourTarget> presentTargets(List<HomeTourTarget> steps, HomeTourKeys keys) {
  return steps.where((s) {
    final ctx = keys.of(s).currentContext;
    if (ctx == null) return false;
    final ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return false;
    final view = View.maybeOf(ctx);
    if (view == null) return true;
    final screen = view.physicalSize / view.devicePixelRatio;
    final rect = ro.localToGlobal(Offset.zero) & ro.size;
    const eps = 1.0;
    return rect.left >= -eps &&
        rect.top >= -eps &&
        rect.right <= screen.width + eps &&
        rect.bottom <= screen.height + eps;
  }).toList();
}
