import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/business_profile.dart';
import '../../providers/business_provider.dart';
import '../../services/api_client.dart';
import '../../utils/phone.dart';
import 'business_labels.dart';
import '../../widgets/common/unsaved_changes_guard.dart';

/// The application a person fills in to be a shop owner or an usta. It is only
/// a request: the shop or profile waits (pending, hidden) for an admin, and the
/// person is an ordinary user in the meantime — "Keyinroq" just leaves.
class BusinessApplyScreen extends ConsumerStatefulWidget {
  const BusinessApplyScreen({required this.kind, super.key});

  final BusinessKind kind;

  @override
  ConsumerState<BusinessApplyScreen> createState() => _BusinessApplyScreenState();
}

class _BusinessApplyScreenState extends ConsumerState<BusinessApplyScreen> {
  final _name = TextEditingController();
  final _district = TextEditingController();
  final _phone = TextEditingController(text: '+998');
  final _telegram = TextEditingController();
  final _priceMin = TextEditingController();
  final _priceMax = TextEditingController();
  // What the user typed (the phone field starts pre-filled with +998).
  late final List<TextEditingController> _fields = [
    _name,
    _district,
    _telegram,
    _priceMin,
    _priceMax,
  ];
  UstaTrade _trade = UstaTrade.elektrik;
  bool _busy = false;
  String? _error;

  bool get _isUsta => widget.kind == BusinessKind.usta;

  @override
  void dispose() {
    for (final c in [_name, _district, _phone, _telegram, _priceMin, _priceMax]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _name.text.trim();
    if (name.isEmpty) return setState(() => _error = l10n.businessErrorName);
    // An usta must leave a number; a shop may leave none, but one it gives has
    // to be callable — the API refuses anything else with a 422.
    final phone = normalizeUzPhone(_phone.text);
    if (phone == null && (_isUsta || !isPhoneBlank(_phone.text))) {
      return setState(() => _error = l10n.phoneErrorInvalid);
    }
    final min = int.tryParse(_priceMin.text.trim());
    final max = int.tryParse(_priceMax.text.trim());
    if (min != null && max != null && max < min) {
      return setState(() => _error = l10n.businessErrorPrice);
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(businessRepositoryProvider);
    try {
      if (_isUsta) {
        await repo.applyUsta(
          name: name,
          trade: _trade,
          phone: phone!,
          district: _district.text,
          telegram: _telegram.text,
          priceMin: min,
          priceMax: max,
        );
      } else {
        await repo.applyShop(
          name: name,
          district: _district.text,
          phone: phone,
          telegram: _telegram.text,
        );
      }
      ref.invalidate(accountRolesProvider);
      ref.invalidate(myShopProvider);
      ref.invalidate(myUstaProvider);
      if (mounted) context.go('/business');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = (e is ApiException && e.statusCode == 409)
            ? l10n.businessErrorExists
            : l10n.businessErrorFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: Listenable.merge(_fields),
      builder: (context, _) => UnsavedChangesGuard(
        hasChanges: !_busy && _fields.any((c) => c.text.trim().isNotEmpty),
        child: Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(
          _isUsta ? l10n.businessApplyUstaTitle : l10n.businessApplyShopTitle,
          style: DesignTokens.heading3,
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => context.go('/'),
            child: Text(l10n.businessSkip),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
          children: [
            Text(l10n.businessApplyIntro,
                style: DesignTokens.body2.copyWith(color: DesignTokens.textGray)),
            const SizedBox(height: DesignTokens.spacingLg),
            _field(_name, _isUsta ? l10n.businessFieldUstaName : l10n.businessFieldShopName),
            if (_isUsta) ...[
              const SizedBox(height: DesignTokens.spacingMd),
              DropdownButtonFormField<UstaTrade>(
                initialValue: _trade,
                decoration: _decoration(l10n.businessFieldTrade),
                items: [
                  for (final t in UstaTrade.values)
                    DropdownMenuItem(value: t, child: Text(tradeLabel(l10n, t))),
                ],
                onChanged: _busy ? null : (t) => setState(() => _trade = t ?? _trade),
              ),
            ],
            const SizedBox(height: DesignTokens.spacingMd),
            _field(_district, l10n.businessFieldDistrict),
            const SizedBox(height: DesignTokens.spacingMd),
            _field(_phone, l10n.businessFieldPhone, keyboard: TextInputType.phone),
            const SizedBox(height: DesignTokens.spacingMd),
            _field(_telegram, l10n.businessFieldTelegram),
            if (_isUsta) ...[
              const SizedBox(height: DesignTokens.spacingMd),
              // A heading over two short labels: "Narx: dan (so'm)" did not
              // fit half the screen and was cut to "Narx: dan (so…".
              Text(l10n.businessFieldPriceTitle, style: DesignTokens.subtitle2),
              const SizedBox(height: DesignTokens.spacingSm),
              Row(
                children: [
                  Expanded(child: _field(_priceMin, l10n.businessFieldPriceMin, digits: true)),
                  const SizedBox(width: DesignTokens.spacingSm),
                  Expanded(child: _field(_priceMax, l10n.businessFieldPriceMax, digits: true)),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: DesignTokens.spacingMd),
              Text(_error!, style: DesignTokens.body2.copyWith(color: DesignTokens.errorRed)),
            ],
            const SizedBox(height: DesignTokens.spacingLg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: DesignTokens.white),
                      )
                    : Text(l10n.businessSubmit),
              ),
            ),
          ],
        ),
      ),
    )));
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: DesignTokens.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.primary, width: 1.6),
        ),
      );

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType? keyboard,
    bool digits = false,
  }) =>
      TextField(
        controller: c,
        enabled: !_busy,
        keyboardType: keyboard ?? (digits ? TextInputType.number : null),
        inputFormatters: digits ? priceInputFormatters : null,
        decoration: _decoration(label),
        // A message about the last submit no longer holds once a field changes.
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
      );
}
