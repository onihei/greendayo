# タスク: Firebase Storage → 自前ファイルAPI

## サーバ側

- [x] 1. greendayo-server に multer を追加し、REST API エンドポイントを実装
  - `POST /storage/upload/*` — multipart/form-data でファイル受信、`./uploads/` に保存
  - `GET /storage/*` — ファイル配信 (Cache-Control 付き)
  - `DELETE /storage/*` — ファイル削除 (userId チェック不要、簡易方式)
  - デフォルトアバター画像を `./uploads/default_avatar.png` に配置

## Flutter 側

- [x] 2. `lib/repository/profile_repository.dart` を修正
  - `uploadMyProfilePhoto`: Firebase Storage → HTTP POST に変更
  - `_uploadPhoto`: Firebase Storage → HTTP POST に変更 (デフォルトアバターのURLもサーバに向ける)
  - `firebase_storage` import 削除

- [x] 3. `lib/repository/article_repository.dart` を修正
  - `uploadJpeg`: Firebase Storage → HTTP POST に変更、返却URLをサーバURLに変更
  - `firebase_storage` import 削除

- [x] 4. `lib/domain/model/profile.dart` を修正
  - `profilePhotoUrl`: Firebase Storage → サーバURLの組み立てに変更
  - `firebase_storage` import 削除

## クリーンアップ

- [x] 5. `pubspec.yaml` から `firebase_storage` を削除し、`http_parser` を追加、`pub get` 実行
