import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/webview_file_chooser.dart';

void main() {
  group('acceptsImages', () {
    test('no accept, an image type or an image extension takes images', () {
      expect(acceptsImages(const []), isTrue);
      expect(acceptsImages(const ['image/*']), isTrue);
      // The AI-design input sends the three types as one comma list.
      expect(acceptsImages(const ['image/jpeg,image/png,image/webp']), isTrue);
      expect(acceptsImages(const ['.PNG']), isTrue);
    });

    test('a non-image input is not answered with a photo', () {
      expect(acceptsImages(const ['.glb']), isFalse);
      expect(acceptsImages(const ['application/pdf']), isFalse);
    });
  });

  group('answerFileSelector', () {
    final picked = <(ImageSource, bool)>[];
    Future<List<XFile>> fakePick(ImageSource source, bool multiple) async {
      picked.add((source, multiple));
      return [XFile('/tmp/room.jpg'), if (multiple) XFile('/tmp/two.jpg')];
    }

    setUp(picked.clear);

    test('the chosen source is used and files come back as file URIs', () async {
      final uris = await answerFileSelector(
        acceptTypes: const ['image/jpeg,image/png,image/webp'],
        multiple: false,
        capture: false,
        chooseSource: () async => ImageSource.gallery,
        pick: fakePick,
      );
      expect(uris, ['file:///tmp/room.jpg']);
      expect(picked, [(ImageSource.gallery, false)]);
    });

    test('capture goes straight to the camera', () async {
      var asked = false;
      await answerFileSelector(
        acceptTypes: const ['image/*'],
        multiple: true,
        capture: true,
        chooseSource: () async {
          asked = true;
          return ImageSource.gallery;
        },
        pick: fakePick,
      );
      expect(asked, isFalse);
      // The camera takes one photo even for a multiple input.
      expect(picked, [(ImageSource.camera, false)]);
    });

    test('a dismissed sheet or a non-image input picks nothing', () async {
      expect(
        await answerFileSelector(
          acceptTypes: const ['image/*'],
          multiple: false,
          capture: false,
          chooseSource: () async => null,
          pick: fakePick,
        ),
        isEmpty,
      );
      expect(
        await answerFileSelector(
          acceptTypes: const ['.glb'],
          multiple: false,
          capture: false,
          chooseSource: () async => ImageSource.gallery,
          pick: fakePick,
        ),
        isEmpty,
      );
      expect(picked, isEmpty);
    });
  });
}
