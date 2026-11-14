import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/business_profile.dart';
import '../../providers/business_provider.dart';
import '../../utils/error_mapper.dart';
import '../../widgets/common/app_image.dart';
import '../../widgets/common/unsaved_changes_guard.dart';
import 'business_labels.dart';

/// Picks one image; a seam so tests need no platform channel.
typedef WallpaperImagePicker = Future<XFile?> Function(ImageSource source);

Future<XFile?> _defaultPicker(ImageSource source) =>
    ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 88);

/// Adds a wallpaper to the shop (new ones wait for an admin), or edits one
/// (`ShopWallpaper` comes in `extra`). The photo can be replaced only while the
/// wallpaper is pending or rejected.
class AddWallpaperScreen extends ConsumerStatefulWidget {
  const AddWallpaperScreen({super.key, this.wallpaper, this.pickImage = _defaultPicker});

  final ShopWallpaper? wallpaper;
  final WallpaperImagePicker pickImage;

  @override
  ConsumerState<AddWallpaperScreen> createState() => _AddWallpaperScreenState();
}

class _AddWallpaperScreenState extends ConsumerState<AddWallpaperScreen> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _width;
  late final TextEditingController _length;
  XFile? _photo;
  List<int>? _photoBytes;
  bool _busy = false;
  bool _saved = false;
  String? _error;

  ShopWallpaper? get _editing => widget.wallpaper;

  /// A photo can be (re)chosen when creating, or while pending/rejected.
  bool get _canPickPhoto => _editing == null || _editing!.status != 'approved';

  @override
  void initState() {
    super.initState();
    final w = _editing;
    _name = TextEditingController(text: w?.name ?? '');
    _price = TextEditingController(text: w?.priceUzs?.toString() ?? '');
    _width = TextEditingController(text: w?.widthCm == null ? '' : _fmt(w!.widthCm!));
    _length = TextEditingController(text: w?.totalLengthM == null ? '' : _fmt(w!.totalLengthM!));
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _width.dispose();
    _length.dispose();
    super.dispose();
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();

  static double? _num(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  int? get _priceValue => int.tryParse(_price.text.trim());
  bool get _nameOk => _name.text.trim().isNotEmpty && _name.text.trim().length <= 120;
  bool get _priceOk => (_priceValue ?? 0) > 0;
  bool get _widthOk {
    final v = _num(_width.text);
    return v != null && v >= 30 && v <= 150;
  }

  bool get _lengthOk {
    final v = _num(_length.text);
    return v != null && v >= 1 && v <= 50;
  }

  bool get _valid =>
      _nameOk && _priceOk && _widthOk && _lengthOk && (_editing != null || _photo != null);

  Future<void> _pick(ImageSource source) async {
    final f = await widget.pickImage(source);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (mounted) {
      setState(() {
        _photo = f;
        _photoBytes = bytes;
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(businessRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final name = _name.text.trim();
      final price = _priceValue!;
      final width = _num(_width.text)!;
      final length = _num(_length.text)!;
      final png = (_photo?.name ?? _photo?.path ?? '').toLowerCase().endsWith('.png');
      final type = png ? 'image/png' : 'image/jpeg';
      final fileName = png ? 'wallpaper.png' : 'wallpaper.jpg';
      final w = _editing;
      if (w == null) {
        await repo.addWallpaper(
          bytes: _photoBytes!,
          filename: fileName,
          contentType: type,
          name: name,
          priceUzs: price,
          widthCm: width,
          totalLengthM: length,
        );
      } else {
        await repo.updateWallpaper(
          w.id,
          bytes: _photoBytes,
          filename: _photoBytes == null ? null : fileName,
          contentType: _photoBytes == null ? null : type,
          name: name == w.name ? null : name,
          priceUzs: price == w.priceUzs ? null : price,
          widthCm: width == w.widthCm ? null : width,
          totalLengthM: length == w.totalLengthM ? null : length,
        );
      }
      ref.invalidate(shopWallpapersProvider);
      messenger.showSnackBar(
          SnackBar(content: Text(w == null ? l10n.wallpaperSavedPending : l10n.wallpaperUpdated)));
      _saved = true;
      router.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        // The server's own sentence for 409 / 429 (duplicate, too many pending).
        final text = mapErrorWithServerDetail(e);
        _error = text == errorGeneric ? l10n.wallpaperFailed : text;
      });
    }
  }

  Widget _preview() {
    if (_photoBytes != null) return Image.memory(Uint8List.fromList(_photoBytes!), fit: BoxFit.cover);
    final url = _editing?.url;
    if (url != null) {
      return AppImage(
        url: url,
        width: double.infinity,
        height: double.infinity,
        placeholder: const ColoredBox(color: DesignTokens.backgroundLight),
        errorWidget: const Icon(Icons.wallpaper_outlined, size: 56, color: DesignTokens.textMuted),
      );
    }
    return const Icon(Icons.wallpaper_outlined, size: 56, color: DesignTokens.textMuted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final editing = _editing != null;
    return ListenableBuilder(
      listenable: Listenable.merge([_name, _price, _width, _length]),
      builder: (context, _) => UnsavedChangesGuard(
        hasChanges: !_saved &&
            !editing &&
            (_photo != null ||
                _name.text.trim().isNotEmpty ||
                _price.text.trim().isNotEmpty ||
                _width.text.trim().isNotEmpty ||
                _length.text.trim().isNotEmpty),
        child: Scaffold(
          backgroundColor: DesignTokens.backgroundLight,
          appBar: AppBar(
            backgroundColor: DesignTokens.backgroundLight,
            elevation: 0,
            title: Text(editing ? l10n.wallpaperEditTitle : l10n.wallpaperAddTitle,
                style: DesignTokens.heading3),
          ),
          body: ListView(
            padding: const EdgeInsets.all(DesignTokens.screenPaddingHorizontal),
            children: [
              if (_canPickPhoto) ...[
                Text(l10n.wallpaperPhotoHint,
                    style: DesignTokens.body2.copyWith(color: DesignTokens.textGray)),
                const SizedBox(height: DesignTokens.spacingSm),
              ],
              AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  child: ColoredBox(color: DesignTokens.white, child: _preview()),
                ),
              ),
              if (_canPickPhoto) ...[
                const SizedBox(height: DesignTokens.spacingSm),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(l10n.addProductCamera),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingSm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.addProductGallery),
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: DesignTokens.spacingMd),
              TextField(
                controller: _name,
                enabled: !_busy,
                maxLength: 120,
                decoration: InputDecoration(labelText: l10n.shopProductName),
              ),
              const SizedBox(height: DesignTokens.spacingSm),
              TextField(
                controller: _price,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                inputFormatters: priceInputFormatters,
                decoration: InputDecoration(
                  labelText: l10n.shopProductPrice,
                  errorText: _price.text.trim().isNotEmpty && !_priceOk ? l10n.wallpaperPriceInvalid : null,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingSm),
              TextField(
                controller: _width,
                enabled: !_busy,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _decimalFormatters,
                decoration: InputDecoration(
                  labelText: l10n.wallpaperWidth,
                  errorText: _width.text.trim().isNotEmpty && !_widthOk ? l10n.wallpaperWidthInvalid : null,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingSm),
              TextField(
                controller: _length,
                enabled: !_busy,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _decimalFormatters,
                decoration: InputDecoration(
                  labelText: l10n.wallpaperLength,
                  errorText: _length.text.trim().isNotEmpty && !_lengthOk ? l10n.wallpaperLengthInvalid : null,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingMd),
              if (!editing && _photo == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
                  child: Text(l10n.wallpaperNeedPhoto,
                      style: DesignTokens.body2.copyWith(color: DesignTokens.textGray)),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
                  child: Text(_error!, style: DesignTokens.body2.copyWith(color: DesignTokens.errorText)),
                ),
              if (_busy)
                const LinearProgressIndicator()
              else
                FilledButton(
                  onPressed: _valid ? _submit : null,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: Text(l10n.shopProductSave),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final _decimalFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
  LengthLimitingTextInputFormatter(7),
];
