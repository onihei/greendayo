import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

Future<img.Image> decodeUrl(String url) async {
  html.ImageElement myImageElement = html.ImageElement(src: url);
  await myImageElement.onLoad.first;
  final width = myImageElement.width ?? 0;
  final height = myImageElement.height ?? 0;
  html.CanvasElement myCanvas =
      html.CanvasElement(width: width, height: height);
  html.CanvasRenderingContext2D ctx = myCanvas.context2D;
  ctx.drawImage(myImageElement, 0, 0);
  html.ImageData rgbaData = ctx.getImageData(0, 0, width, height);
  final data = rgbaData.data.buffer;
  return img.Image.fromBytes(
      width: width, height: height, bytes: data, numChannels: 4);
}

Future<img.Image?> decodeBytes(
    {required String mimeType, required Uint8List bytes}) async {
  String dataUri = "data:$mimeType;base64, ${base64Encode(bytes)}";
  html.ImageElement myImageElement = html.ImageElement(src: dataUri);
  await myImageElement.onLoad.first;
  final width = myImageElement.width ?? 0;
  final height = myImageElement.height ?? 0;
  html.CanvasElement myCanvas =
      html.CanvasElement(width: width, height: height);
  html.CanvasRenderingContext2D ctx = myCanvas.context2D;
  ctx.drawImage(myImageElement, 0, 0);
  html.ImageData rgbaData = ctx.getImageData(0, 0, width, height);
  final data = rgbaData.data.buffer;
  return img.Image.fromBytes(
      width: width, height: height, bytes: data, numChannels: 4);
}
