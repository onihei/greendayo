import 'dart:typed_data';

import 'package:image/image.dart' as img;

Future<img.Image> decodeUrl(String url) async {
  throw UnimplementedError();
}

Future<img.Image?> decodeBytes({required String mimeType, required Uint8List bytes}) async {
  return img.decodeImage(bytes);
}
