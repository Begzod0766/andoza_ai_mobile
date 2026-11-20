import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/new_project/new_project_sheet_state.dart';
import 'new_project_sheet.dart';

/// Hosts [NewProjectSheet] in `AppShell`'s body, above the bottom menu (not
/// under or over it — see CLAUDE.md on `extendBody`). Follows
/// [newProjectSheetOpenProvider]: slides up from the bottom of the body over a
/// scrim, and closes on a scrim tap, a swipe down on its header, or system
/// Back. Renders nothing while closed, so it never takes a tap from the tab.
class NewProjectSheetLayer extends ConsumerStatefulWidget {
  const NewProjectSheetLayer({super.key});

  @override
  ConsumerState<NewProjectSheetLayer> createState() =>
      _NewProjectSheetLayerState();
}

class _NewProjectSheetLayerState extends ConsumerState<NewProjectSheetLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  bool _synced = false;
  double _sheetHeight = 1;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _sync(bool open) {
    if (_reduceMotion) {
      _c.value = open ? 1 : 0;
    } else if (open) {
      _c.animateTo(1, curve: Curves.easeOutCubic);
    } else {
      _c.animateBack(0, curve: Curves.easeInCubic);
    }
  }

  void _close() => ref.read(newProjectSheetOpenProvider.notifier).state = false;

  void _onDragUpdate(DragUpdateDetails d) {
    _c.value -= (d.primaryDelta ?? 0) / _sheetHeight;
    // Dragged all the way down: the header (and its drag-end) is about to
    // unmount, so close now rather than wait for an end that never comes.
    if (_c.value == 0) _close();
  }

  void _onDragEnd(DragEndDetails d) {
    if ((d.primaryVelocity ?? 0) > 700 || _c.value < 0.75) {
      _close();
    } else {
      _sync(true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_synced) {
      _synced = true;
      _sync(ref.read(newProjectSheetOpenProvider));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(newProjectSheetOpenProvider, (_, open) => _sync(open));
    final topGap = MediaQuery.paddingOf(context).top + 8;
    final sheet = NewProjectSheet(
      onHeaderDragUpdate: _onDragUpdate,
      onHeaderDragEnd: _onDragEnd,
    );
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        if (_c.value == 0) return const SizedBox.shrink();
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                child: ColoredBox(
                  color: const Color(0x801E2439)
                      .withValues(alpha: 0.5 * _c.value),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: topGap,
              bottom: 0,
              child: LayoutBuilder(
                builder: (context, box) {
                  _sheetHeight = box.maxHeight;
                  return FractionalTranslation(
                    translation: Offset(0, 1 - _c.value),
                    child: child,
                  );
                },
              ),
            ),
          ],
        );
      },
      // Always wrapped (switching wrappers would rebuild the sheet and restart
      // its cards). Back closes the sheet only while it is open and the shell
      // is the current route — not when a pushed screen covers it.
      child: BackButtonListener(
        onBackButtonPressed: () async {
          if (!ref.read(newProjectSheetOpenProvider)) return false;
          if (!(ModalRoute.isCurrentOf(context) ?? true)) return false;
          _close();
          return true;
        },
        child: sheet,
      ),
    );
  }
}
