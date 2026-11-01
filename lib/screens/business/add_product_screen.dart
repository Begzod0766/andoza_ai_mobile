import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/business_provider.dart';
import '../../services/api_client.dart';
import '../../widgets/common/unsaved_changes_guard.dart';
import '../../utils/error_mapper.dart';
import 'style_chips.dart';

const _categories = ['divan', 'stol', 'stul', 'karavot', 'shkaf', 'lampa', 'boshqa'];
const _rooms = ['mehmonxona', 'oshxona', 'yotoqxona', 'hammom', 'balkon'];
const _placements = ['pol', 'devor', 'shift'];

/// A new product from one photo: the server builds the 3D model with Tripo
/// (1–2 minutes), then the model joins the shop and waits for an admin — the
/// same two steps the website's upload dialog does, so a shop owner needs no
/// .glb file.
class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  XFile? _photo;
  final Map<String, XFile> _extras = {}; // 'left' | 'back' | 'right'
  String _category = 'divan';
  String? _room;
  String _placement = 'pol';
  List<String> _styles = const [];
  String? _step; // null: idle; else what is in progress
  String? _error;
  bool _cancelled = false;
  // Set once the product is uploaded, so leaving no longer asks.
  bool _saved = false;

  @override
  void dispose() {
    _cancelled = true;
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final f = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 88);
    if (f != null && mounted) setState(() => _photo = f);
  }

  Future<void> _pickExtra(String view) async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.addProductCamera),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.addProductGallery),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    final f = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 88);
    if (f != null && mounted) setState(() => _extras[view] = f);
  }

  Widget _angleTile(AppLocalizations l, String view, String label, bool busy) {
    final f = _extras[view];
    return Expanded(
      child: Column(children: [
        AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onTap: busy ? null : () => _pickExtra(view),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              child: Stack(fit: StackFit.expand, children: [
                ColoredBox(
                  color: DesignTokens.white,
                  child: f == null
                      ? const Icon(Icons.add_a_photo_outlined, color: DesignTokens.textMuted)
                      : Image.file(File(f.path), fit: BoxFit.cover),
                ),
                if (f != null && !busy)
                  // 22px badge, 48px hit area (Material minimum tap target):
                  // the transparent padding around it catches the tap.
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Tooltip(
                      message: l.addProductAngleRemove,
                      child: Semantics(
                        button: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _extras.remove(view)),
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: DesignTokens.body2.copyWith(color: DesignTokens.textGray)),
      ]),
    );
  }

  static ({List<int> bytes, String name, String type}) _meta(List<int> bytes, String path, String stem) {
    final png = path.toLowerCase().endsWith('.png');
    return (bytes: bytes, name: '$stem.${png ? 'png' : 'jpg'}', type: png ? 'image/png' : 'image/jpeg');
  }

  String _categoryLabel(AppLocalizations l, String v) => switch (v) {
        'divan' => l.categoryDivan,
        'stol' => l.categoryStol,
        'stul' => l.categoryStul,
        'karavot' => l.categoryKaravot,
        'shkaf' => l.categoryShkaf,
        'lampa' => l.categoryLampa,
        _ => l.categoryBoshqa,
      };

  String _roomLabel(AppLocalizations l, String v) => switch (v) {
        'mehmonxona' => l.roomMehmonxona,
        'oshxona' => l.roomOshxona,
        'yotoqxona' => l.roomYotoqxona,
        'hammom' => l.roomHammom,
        _ => l.roomBalkon,
      };

  String _placementLabel(AppLocalizations l, String v) => switch (v) {
        'pol' => l.placementPol,
        'devor' => l.placementDevor,
        _ => l.placementShift,
      };

  String _errorText(AppLocalizations l, Object e) {
    if (e is ApiException) {
      switch (e.statusCode) {
        case 503:
          return l.addProductUnavailable;
        // The model the app downloaded is not a real .glb; the server says so.
        case 415:
          return mapErrorWithServerDetail(e);
        case 429:
          return e.message.isNotEmpty && e.message.contains('Tasdiqlanmagan') ? l.addProductTooMany : l.addProductLimit;
      }
    }
    return l.addProductFailed;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_photo == null) return setState(() => _error = l10n.addProductNeedPhoto);
    if (_name.text.trim().isEmpty) return setState(() => _error = l10n.addProductNeedName);

    final repo = ref.read(businessRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() {
      _error = null;
      _step = l10n.addProductBuilding;
    });
    try {
      final bytes = await _photo!.readAsBytes();
      final isPng = _photo!.path.toLowerCase().endsWith('.png');
      final type = isPng ? 'image/png' : 'image/jpeg';
      final extraViews = <String, (List<int>, String, String)>{};
      for (final e in _extras.entries) {
        final m = _meta(await e.value.readAsBytes(), e.value.path, e.key);
        extraViews[e.key] = (m.bytes, m.name, m.type);
      }
      final jobId = await repo.startModelFromPhoto(
        bytes,
        isPng ? 'photo.png' : 'photo.jpg',
        type,
        extraViews: extraViews,
      );

      String? key;
      final deadline = DateTime.now().add(const Duration(minutes: 6));
      while (key == null) {
        await Future<void>.delayed(const Duration(seconds: 3));
        if (_cancelled) return;
        if (DateTime.now().isAfter(deadline)) throw StateError('timeout');
        final job = await repo.fetchModelJob(jobId);
        if (job.isFailed) throw StateError('build failed');
        key = job.key;
      }

      if (!mounted) return;
      setState(() => _step = l10n.addProductUploading);
      final glb = await repo.fetchBuiltModel(key);
      await repo.createProduct(
        glb: glb,
        thumbnail: bytes,
        thumbnailType: type,
        name: _name.text.trim(),
        category: _category,
        placement: _placement,
        roomType: _room,
        priceUzs: int.tryParse(_price.text.trim()),
        styles: _styles,
      );
      ref.invalidate(myProductsProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.addProductDone)));
      _saved = true;
      router.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _step = null;
        _error = _errorText(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final busy = _step != null;
    return ListenableBuilder(
      listenable: Listenable.merge([_name, _price]),
      builder: (context, _) => UnsavedChangesGuard(
        hasChanges: !_saved &&
            (_photo != null ||
                _extras.isNotEmpty ||
                _name.text.trim().isNotEmpty ||
                _price.text.trim().isNotEmpty),
        child: Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(l10n.addProductTitle, style: DesignTokens.heading3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
        children: [
          Text(l10n.addProductPhotoHint, style: DesignTokens.body2.copyWith(color: DesignTokens.textGray)),
          const SizedBox(height: DesignTokens.spacingSm),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              child: ColoredBox(
                color: DesignTokens.white,
                child: _photo == null
                    ? const Icon(Icons.chair_alt_outlined, size: 56, color: DesignTokens.textMuted)
                    : Image.file(File(_photo!.path), fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.addProductCamera),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingSm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.addProductGallery),
              ),
            ),
          ]),
          const SizedBox(height: DesignTokens.spacingMd),
          Text(l10n.addProductMoreAngles, style: DesignTokens.heading3),
          const SizedBox(height: 2),
          Text(l10n.addProductMoreAnglesHint, style: DesignTokens.body2.copyWith(color: DesignTokens.textGray)),
          const SizedBox(height: DesignTokens.spacingSm),
          Row(children: [
            _angleTile(l10n, 'left', l10n.addProductAngleLeft, busy),
            const SizedBox(width: DesignTokens.spacingSm),
            _angleTile(l10n, 'back', l10n.addProductAngleBack, busy),
            const SizedBox(width: DesignTokens.spacingSm),
            _angleTile(l10n, 'right', l10n.addProductAngleRight, busy),
          ]),
          const SizedBox(height: DesignTokens.spacingMd),
          TextField(
            controller: _name,
            enabled: !busy,
            decoration: InputDecoration(labelText: l10n.shopProductName),
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          TextField(
            controller: _price,
            enabled: !busy,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.shopProductPrice),
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: InputDecoration(labelText: l10n.addProductCategory),
            items: [for (final c in _categories) DropdownMenuItem(value: c, child: Text(_categoryLabel(l10n, c)))],
            onChanged: busy ? null : (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          DropdownButtonFormField<String?>(
            initialValue: _room,
            decoration: InputDecoration(labelText: l10n.addProductRoom),
            items: [
              DropdownMenuItem<String?>(value: null, child: Text(l10n.addProductRoomAll)),
              for (final r in _rooms) DropdownMenuItem<String?>(value: r, child: Text(_roomLabel(l10n, r))),
            ],
            onChanged: busy ? null : (v) => setState(() => _room = v),
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          DropdownButtonFormField<String>(
            initialValue: _placement,
            decoration: InputDecoration(labelText: l10n.addProductPlacement),
            items: [for (final p in _placements) DropdownMenuItem(value: p, child: Text(_placementLabel(l10n, p)))],
            onChanged: busy ? null : (v) => setState(() => _placement = v ?? _placement),
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          StyleChips(
            value: _styles,
            enabled: !busy,
            onChanged: (v) => setState(() => _styles = v),
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
              child: Text(_error!, style: DesignTokens.body2.copyWith(color: DesignTokens.errorRed)),
            ),
          if (busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: DesignTokens.spacingSm),
            Text(_step!, style: DesignTokens.body2.copyWith(color: DesignTokens.textGray)),
          ] else
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: Text(l10n.addProductSubmit),
            ),
        ],
      ),
    )));
  }
}
