import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/api/api.dart';
import '../../providers/apartment_provider.dart';
import '../../services/share_intent.dart';
import '../../widgets/common/error_view.dart';
import '../studio/studio_webview_screen.dart';

/// "Share → Andoza AI": text shared from the Pinterest app lands here. The
/// AI design endpoint works on one room, so the person picks it; the studio
/// then opens its AI designer with the pin already taken (`?ai_pin=`), where
/// the plan is made and applied as in the web app (handoff §6).
class SharePinScreen extends ConsumerWidget {
  const SharePinScreen({required this.text, super.key});

  /// The shared text, e.g. "Check out this Pin! https://pin.it/AbCd12".
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pin = findPinUrl(text);
    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        // Opened by a share at launch, the screen is alone on the stack: a
        // close button leads home instead of leaving no way out.
        leading: context.canPop()
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: l10n.actionClose,
                onPressed: () => context.go('/'),
              ),
        title: Text(l10n.sharePinTitle, style: DesignTokens.heading3),
      ),
      body: SafeArea(
        child: pin == null
            ? ErrorView(
                icon: Icons.link_off,
                title: l10n.sharePinNotPin,
                message: l10n.sharePinNotPinHint,
              )
            : _RoomPicker(pin: pin),
      ),
    );
  }
}

class _RoomPicker extends ConsumerWidget {
  const _RoomPicker({required this.pin});

  final String pin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final apartments = ref.watch(apartmentsProvider);
    return apartments.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(apartmentsProvider),
      ),
      data: (list) {
        final rooms = [
          for (final apt in list)
            for (final room in apt.rooms) (apt, room),
        ];
        return ListView(
          padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
          children: [
            Text(
              pin,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DesignTokens.caption.copyWith(color: DesignTokens.textGray),
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            Text(l10n.sharePinChooseRoom, style: DesignTokens.heading3),
            const SizedBox(height: DesignTokens.spacingXs),
            Text(
              l10n.sharePinHint,
              style: DesignTokens.body2.copyWith(color: DesignTokens.textGray),
            ),
            const SizedBox(height: DesignTokens.spacingLg),
            if (rooms.isEmpty)
              Text(l10n.sharePinNoRooms, style: DesignTokens.body2)
            else
              for (final (apt, room) in rooms)
                _RoomTile(
                  apartment: apt,
                  room: room,
                  onTap: () => context.pushReplacement(
                    studioRoomPath(room.id, aiPin: pin),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.apartment,
    required this.room,
    required this.onTap,
  });

  final Apartment apartment;
  final RoomOut room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final area = room.floorArea;
    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
      color: DesignTokens.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        side: const BorderSide(color: DesignTokens.borderGray),
      ),
      child: ListTile(
        leading: const Icon(Icons.meeting_room_outlined),
        title: Text(room.name, style: DesignTokens.subtitle2),
        subtitle: Text(
          area == null
              ? apartment.name
              : '${apartment.name} · ${area.toStringAsFixed(1)} m²',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
