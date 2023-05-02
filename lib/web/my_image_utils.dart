export 'my_image_utils_others.dart' if (dart.library.html) 'my_image_utils_web.dart';

///
/// img.decodeImage(bytes) はwebで実行するとすごく遅い。
/// htmlエレメントを使用し、デコード処理をブラウザに実行させることで高速化させる。
///
