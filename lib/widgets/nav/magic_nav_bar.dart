import 'package:flutter/material.dart';

import '../../config/design_tokens.dart';

/// One slot of [MagicNavBar]. [label] is the text shown under it and, unless
/// [semanticLabel] is given, the slot's one accessible name; [key] goes on the
/// slot (e.g. a home-tour target).
class MagicNavItem {
  const MagicNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.semanticLabel,
    this.key,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? semanticLabel;
  final Key? key;
}

/// "Magic" bottom menu: equal slots on a white bar; the selected slot's icon
/// sits in a blue circle raised above the bar, over a concave notch cut into
/// it. Changing [selectedIndex] slides circle and notch to the new slot
/// (300 ms, ease; instant when animations are disabled). A null
/// [selectedIndex] (a route that is no tab) shows a flat bar with no circle.
///
/// The widget's own box includes the strip the circle rises into, so the
/// circle stays tappable without `extendBody` on the Scaffold. That strip is
/// painted [DesignTokens.backgroundLight], or white when [raisedBackground]
/// (a white sheet sits right above the bar).
class MagicNavBar extends StatefulWidget {
  const MagicNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.raisedBackground = false,
    super.key,
  });

  final List<MagicNavItem> items;
  final int? selectedIndex;
  final ValueChanged<int> onTap;
  final bool raisedBackground;

  static const circleKey = Key('magicNavCircle');

  /// Height of the strip above the bar that the circle rises into.
  static const overhang = 22.0;
  static const barHeight = 64.0;
  static const _circleRadius = 23.0;
  static const _notchRadius = 29.0;

  @override
  State<MagicNavBar> createState() => _MagicNavBarState();
}

class _MagicNavBarState extends State<MagicNavBar> {
  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedIndex;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);
    return SizedBox(
      height: MagicNavBar.overhang + MagicNavBar.barHeight + bottomInset,
      child: LayoutBuilder(
        builder: (context, box) {
          final slot = box.maxWidth / widget.items.length;
          return TweenAnimationBuilder<double>(
            tween: Tween(end: (selected ?? 0).toDouble()),
            duration: duration,
            curve: Curves.easeInOut,
            builder: (context, pos, _) {
              final cx = (pos + 0.5) * slot;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BarPainter(
                        notchX: selected == null ? null : cx,
                        stripColor: widget.raisedBackground
                            ? DesignTokens.white
                            : DesignTokens.backgroundLight,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      children: [
                        for (var i = 0; i < widget.items.length; i++)
                          Expanded(child: _slot(context, i, i == selected)),
                      ],
                    ),
                  ),
                  if (selected != null)
                    Positioned(
                      left: cx - MagicNavBar._circleRadius,
                      top: MagicNavBar.overhang - MagicNavBar._circleRadius,
                      child: IgnorePointer(
                        child: Container(
                          key: MagicNavBar.circleKey,
                          width: MagicNavBar._circleRadius * 2,
                          height: MagicNavBar._circleRadius * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: DesignTokens.primaryBlue,
                            boxShadow: [
                              BoxShadow(
                                color: DesignTokens.primaryBlue.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.items[selected].activeIcon,
                            color: DesignTokens.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _slot(BuildContext context, int i, bool active) {
    final item = widget.items[i];
    final label = ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          // Capped so a large system font can't push it out of the bar.
          textScaler: MediaQuery.textScalerOf(context)
              .clamp(maxScaleFactor: 1.2),
          style: DesignTokens.caption.copyWith(
            fontSize: 11,
            height: 1.2,
            color: active ? DesignTokens.primaryBlue : DesignTokens.textGray,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
    return Semantics(
      key: item.key,
      button: true,
      selected: active,
      label: item.semanticLabel ?? item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onTap(i),
        child: Column(
          children: [
            const SizedBox(height: MagicNavBar.overhang + 12),
            SizedBox(
              height: 24,
              child: active
                  ? null
                  : Icon(item.icon, color: DesignTokens.textMuted, size: 22),
            ),
            const SizedBox(height: 3),
            label,
          ],
        ),
      ),
    );
  }
}

/// White bar below the overhang strip, with a circular notch at [notchX].
class _BarPainter extends CustomPainter {
  _BarPainter({required this.notchX, required this.stripColor});

  final double? notchX;
  final Color stripColor;

  @override
  void paint(Canvas canvas, Size size) {
    const top = MagicNavBar.overhang;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, top + 1),
      Paint()..color = stripColor,
    );
    var bar = Path()..addRect(Rect.fromLTRB(0, top, size.width, size.height));
    if (notchX != null) {
      bar = Path.combine(
        PathOperation.difference,
        bar,
        Path()..addOval(
          Rect.fromCircle(
            center: Offset(notchX!, top),
            radius: MagicNavBar._notchRadius,
          ),
        ),
      );
    }
    canvas.drawPath(
      bar.shift(DesignTokens.shadowNavBar.offset),
      DesignTokens.shadowNavBar.toPaint(),
    );
    canvas.drawPath(bar, Paint()..color = DesignTokens.white);
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.notchX != notchX || old.stripColor != stripColor;
}
