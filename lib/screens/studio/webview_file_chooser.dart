import 'package:image_picker/image_picker.dart';

/// Answers an `<input type="file">` in the Studio WebView on Android.
///
/// Android's WebView ignores a file input unless the app supplies the files,
/// so every Studio upload (AI design from an image, floor texture, furniture
/// photo) did nothing there. iOS's WKWebView brings its own picker and needs
/// none of this.
///
/// Only images are offered: every file input in the Studio takes an image. A
/// picked image is re-encoded as JPEG and scaled down by `image_picker`, which
/// keeps it under the API's 10 MB limit and in a format it accepts. Returns
/// the picked files as `file://` URIs, or an empty list (the web page then
/// sees a cancelled pick).
Future<List<String>> answerFileSelector({
  required List<String> acceptTypes,
  required bool multiple,
  required bool capture,
  required Future<ImageSource?> Function() chooseSource,
  required Future<List<XFile>> Function(ImageSource source, bool multiple) pick,
}) async {
  if (!acceptsImages(acceptTypes)) return const [];
  // `capture` on the input asks for the camera straight away.
  final source = capture ? ImageSource.camera : await chooseSource();
  if (source == null) return const [];
  final files = await pick(source, multiple && source == ImageSource.gallery);
  return [for (final f in files) Uri.file(f.path).toString()];
}

/// True when a file input with these `accept` values takes images: no
/// `accept` at all, an `image/...` type, or an image file extension.
bool acceptsImages(List<String> acceptTypes) {
  final types = [
    for (final entry in acceptTypes)
      for (final t in entry.split(','))
        if (t.trim().isNotEmpty) t.trim().toLowerCase(),
  ];
  if (types.isEmpty) return true;
  const extensions = {'.jpg', '.jpeg', '.png', '.webp', '.heic'};
  return types.any((t) => t.startsWith('image/') || extensions.contains(t));
}

/// The real picker: the camera or the gallery through `image_picker`, scaled
/// to at most 2048 px and re-encoded as JPEG.
Future<List<XFile>> pickWithImagePicker(ImageSource source, bool multiple) async {
  final picker = ImagePicker();
  if (multiple) {
    return picker.pickMultiImage(maxWidth: 2048, imageQuality: 90);
  }
  final file = await picker.pickImage(
    source: source,
    maxWidth: 2048,
    imageQuality: 90,
  );
  return file == null ? const [] : [file];
}
