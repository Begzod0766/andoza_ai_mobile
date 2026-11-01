import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/business_profile.dart';
import '../../providers/business_provider.dart';
import 'business_labels.dart';
import '../../utils/phone.dart';

/// Edit the usta's own public profile. Rating, verified and moderation status
/// are not here — they are not the usta's to change.
class EditUstaScreen extends ConsumerStatefulWidget {
  const EditUstaScreen({super.key});

  @override
  ConsumerState<EditUstaScreen> createState() => _EditUstaScreenState();
}

class _EditUstaScreenState extends ConsumerState<EditUstaScreen> {
  final _name = TextEditingController();
  final _district = TextEditingController();
  final _phone = TextEditingController();
  final _telegram = TextEditingController();
  final _priceMin = TextEditingController();
  final _priceMax = TextEditingController();
  late final _fields = [_name, _district, _phone, _telegram, _priceMin, _priceMax];
  UstaTrade _trade = UstaTrade.elektrik;
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // A message about the last save no longer holds once a field changes.
    for (final c in _fields) {
      c.addListener(_clearError);
    }
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  @override
  void dispose() {
    for (final c in _fields) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(UstaProfile u) {
    _loaded = true;
    _name.text = u.name;
    _district.text = u.district ?? '';
    _phone.text = u.phone ?? '';
    _telegram.text = u.telegram ?? '';
    _priceMin.text = u.priceMin?.toString() ?? '';
    _priceMax.text = u.priceMax?.toString() ?? '';
    _trade = u.trade ?? _trade;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final router = GoRouter.of(context);
    // A name of spaces alone is refused by the API with a 422, and a number
    // has to be an Uzbek one; say which, here.
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.businessErrorName);
      return;
    }
    final phone = normalizeUzPhone(_phone.text);
    if (phone == null && !isPhoneBlank(_phone.text)) {
      setState(() => _error = l10n.phoneErrorInvalid);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final min = int.tryParse(_priceMin.text.trim());
    final max = int.tryParse(_priceMax.text.trim());
    if (min != null && max != null && max < min) {
      setState(() {
        _saving = false;
        _error = l10n.businessErrorPrice;
      });
      return;
    }
    try {
      await ref.read(businessRepositoryProvider).updateUsta(
            name: _name.text.trim(),
            trade: _trade,
            district: _district.text.trim(),
            phone: phone,
            telegram: _telegram.text.trim(),
            priceMin: min,
            priceMax: max,
          );
      ref.invalidate(myUstaProvider);
      router.pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = l10n.ustaEditFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usta = ref.watch(myUstaProvider);
    if (!_loaded && usta.valueOrNull != null) _fill(usta.value!);
    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(l10n.ustaEditTitle, style: DesignTokens.heading3),
      ),
      body: !_loaded
          ? Center(
              child: usta.hasError ? Text(l10n.businessLoadFailed) : const CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
              children: [
                TextField(controller: _name, decoration: InputDecoration(labelText: l10n.businessFieldUstaName)),
                const SizedBox(height: DesignTokens.spacingSm),
                DropdownButtonFormField<UstaTrade>(
                  initialValue: _trade,
                  decoration: InputDecoration(labelText: l10n.businessFieldTrade),
                  items: [
                    for (final t in UstaTrade.values)
                      DropdownMenuItem(value: t, child: Text(tradeLabel(l10n, t))),
                  ],
                  onChanged: (v) => setState(() => _trade = v ?? _trade),
                ),
                const SizedBox(height: DesignTokens.spacingSm),
                TextField(controller: _district, decoration: InputDecoration(labelText: l10n.businessFieldDistrict)),
                const SizedBox(height: DesignTokens.spacingSm),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.businessFieldPhone),
                ),
                const SizedBox(height: DesignTokens.spacingSm),
                TextField(controller: _telegram, decoration: InputDecoration(labelText: l10n.businessFieldTelegram)),
                const SizedBox(height: DesignTokens.spacingSm),
                Text(l10n.businessFieldPriceTitle, style: DesignTokens.subtitle2),
                const SizedBox(height: DesignTokens.spacingSm),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _priceMin,
                      keyboardType: TextInputType.number,
                      inputFormatters: priceInputFormatters,
                      decoration: InputDecoration(labelText: l10n.businessFieldPriceMin),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingSm),
                  Expanded(
                    child: TextField(
                      controller: _priceMax,
                      keyboardType: TextInputType.number,
                      inputFormatters: priceInputFormatters,
                      decoration: InputDecoration(labelText: l10n.businessFieldPriceMax),
                    ),
                  ),
                ]),
                const SizedBox(height: DesignTokens.spacingMd),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
                    child: Text(_error!, style: DesignTokens.body2.copyWith(color: DesignTokens.errorRed)),
                  ),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: Text(l10n.ustaEditSave),
                ),
              ],
            ),
    );
  }
}
