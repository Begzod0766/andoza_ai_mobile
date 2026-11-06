import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../common/app_image.dart';

/// Project card thumbnail: shows a real screenshot of the room's 3D Studio
/// scene ([imageUrl]) when one has been captured, otherwise falls back to a
/// stylized isometric room placeholder — small trapezoid floor + angled wall
/// + a window cutout, with a "SCAN" badge on the large variant. Also falls
/// back on a failed/loading image. Falls back to a flat gradient square when
/// [detailed] is false (too small at list-row thumbnail size for the
/// isometric detail to read).
class RoomThumbnail extends StatelessWidget {
  const RoomThumbnail({
    super.key,
    this.height = 160,
    this.borderRadius = DesignTokens.radiusLg,
    this.detailed = true,
    this.imageUrl,
  });

  final double height;
  final double borderRadius;
  final bool detailed;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFC9DCE8), Color(0xFF9FC0D4)],
          ),
        ),
        child: url != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    url: url,
                    placeholder: _placeholder(),
                    errorWidget: _placeholder(),
                  ),
                  if (detailed) _scanBadge(),
                ],
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    if (!detailed) return const SizedBox.shrink();
    return Stack(
      children: [
        // Back wall.
        Positioned(
          left: height * 0.28,
          right: height * 0.28,
          top: height * 0.14,
          bottom: height * 0.34,
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFFE7F0F6)),
          ),
        ),
        // Left wall, angled via a custom clip.
        Positioned(
          left: 0,
          width: height * 0.34,
          top: height * 0.14,
          bottom: height * 0.20,
          child: ClipPath(
            clipper: _LeftWallClipper(),
            child: Container(color: const Color(0xFFA9C4D8)),
          ),
        ),
        // Window cutout in the back wall.
        Positioned(
          left: height * 0.42,
          width: height * 0.22,
          top: height * 0.24,
          height: height * 0.3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0x26161C2E), width: 2),
            ),
          ),
        ),
        // Floor, angled via a custom clip.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: height * 0.4,
          child: ClipPath(
            clipper: _FloorClipper(),
            child: Container(color: const Color(0xFF7FA3BE)),
          ),
        ),
        _scanBadge(),
      ],
    );
  }

  Widget _scanBadge() {
    return const Positioned(
      right: 8,
      bottom: 8,
      child: _ScanBadge(),
    );
  }
}

class _ScanBadge extends StatelessWidget {
  const _ScanBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x8C16232E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.crop_free, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.roomThumbnailScanBadge,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftWallClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.4, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _FloorClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.3)
      ..lineTo(size.width * 0.82, size.height)
      ..lineTo(size.width * 0.18, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
