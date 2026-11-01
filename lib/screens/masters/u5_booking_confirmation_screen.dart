import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/estimate_provider.dart';
import '../../providers/room_persistence_provider.dart';
import '../../providers/room_provider.dart';
import '../../providers/masters_provider.dart';
import '../../services/analytics_service.dart';
import 'master_not_found.dart';
import '../../utils/currency.dart';
import '../../utils/phone.dart';

/// U5: send-smeta sheet — "Loyihangizni [ism]ga yuborasizmi?" The
/// project-summary figure is the real [estimateProvider] total (backfilled
/// from Step 6's placeholder once Step 11's pricing layer landed).
class U5BookingConfirmationScreen extends ConsumerStatefulWidget {
  const U5BookingConfirmationScreen({this.master, super.key});

  final MockMaster? master;

  @override
  ConsumerState<U5BookingConfirmationScreen> createState() =>
      _U5BookingConfirmationScreenState();
}

class _U5BookingConfirmationScreenState
    extends ConsumerState<U5BookingConfirmationScreen> {
  final _commentController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _sending = false;
  bool _phoneInvalid = false;

  @override
  void initState() {
    super.initState();
    // The usta calls this number back: start from the account's own phone
    // when it has one (OTP accounts do, username accounts don't).
    final auth = ref.read(authStateProvider);
    final phone = auth is AuthAuthenticated ? auth.user.phone : null;
    if (phone != null) _phoneController.text = phone;
  }

  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// The server id of the room this request is about, or null when it has
  /// none. A room made in the wizard or drawn keeps a local timestamp id; its
  /// server id is the one [roomPersistenceProvider] got back when it was
  /// saved. A room opened from a project already carries its server id.
  String? _serverRoomId() {
    final active = ref.read(activeRoomProvider);
    if (active == null) return null;
    final persisted = ref.read(roomPersistenceProvider).valueOrNull;
    if (persisted != null && persisted.clientRoomId == active.id) {
      return persisted.roomId;
    }
    return _uuid.hasMatch(active.id) ? active.id : null;
  }

  /// Sends the request to the usta for real (`POST /leads`); the server adds
  /// the room's latest saved estimate. An unsaved room has no server id, so it
  /// is left out and the usta gets the request without it.
  Future<void> _send(MockMaster m) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    // The usta has to be able to call back; the API refuses a number that is
    // not Uzbek with a 422.
    final phone = normalizeUzPhone(_phoneController.text);
    if (phone == null) {
      setState(() => _phoneInvalid = true);
      return;
    }
    final roomId = _serverRoomId();
    final analytics = ref.read(analyticsProvider);
    setState(() => _sending = true);
    try {
      await ref
          .read(businessRepositoryProvider)
          .sendLead(
            m.master.id,
            roomId: roomId,
            message: _commentController.text,
            contactPhone: phone,
          );
      analytics.leadSent();
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.mastersEstimateSent)));
    } catch (_) {
      if (mounted) setState(() => _sending = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.mastersSendFailed)));
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final m = widget.master;
    if (m == null) return const MasterNotFoundScreen();
    final estimate = ref.watch(estimateProvider);

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(
                  DesignTokens.screenPaddingHorizontal,
                ),
                children: [
                  Text(
                    l10n.mastersSendConfirmTitle(
                      m.master.name.split(' ').first,
                    ),
                    style: DesignTokens.heading3,
                  ),
                  const SizedBox(height: DesignTokens.spacingLg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DesignTokens.spacingMd),
                    decoration: BoxDecoration(
                      color: DesignTokens.white,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusLg,
                      ),
                      border: Border.all(color: DesignTokens.borderGray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.mastersProjectSummaryTitle,
                          style: DesignTokens.subtitle2,
                        ),
                        const SizedBox(height: DesignTokens.spacingXs),
                        Text(
                          l10n.mastersProjectSummaryValue(
                            estimate.roomArea.toStringAsFixed(1),
                            formatSom(estimate.totalPrice.round()),
                          ),
                          style: DesignTokens.body2.copyWith(
                            color: DesignTokens.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingLg),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) {
                      if (_phoneInvalid) setState(() => _phoneInvalid = false);
                    },
                    decoration: InputDecoration(
                      labelText: l10n.mastersPhoneLabel,
                      hintText: '+998 90 123 45 67',
                      errorText: _phoneInvalid ? l10n.phoneErrorInvalid : null,
                    // The example number does not fit one line on a phone.
                    errorMaxLines: 2,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingSm),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.mastersCommentHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingSm),
                  Text(
                    l10n.mastersEstimateNote,
                    style: DesignTokens.caption.copyWith(
                      color: DesignTokens.textGray,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                DesignTokens.screenPaddingHorizontal,
              ),
              child: SizedBox(
                width: double.infinity,
                height: DesignTokens.buttonHeightLarge,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.accentOrange,
                  ),
                  onPressed: _sending ? null : () => _send(m),
                  child: Text(l10n.mastersSend),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
