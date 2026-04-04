# Firebase Storage を自前ファイルAPIに置き換える

## 背景

Firebase Cloud Storage の利用規約変更により、画像保存機能が使えなくなった。
既存の greendayo-server (Express + Socket.IO) を拡張し、ファイルアップロード/配信APIを追加することで対応する。

## 現状

```
Flutter App
  ├─ プロフィール写真 → Firebase Storage (users/{uid}/photo)
  ├─ BBS記事画像     → Firebase Storage (bbs/photo/{ulid})
  └─ デフォルトアバター → Firebase Storage (default_avatar.png)
```

Firebase Storage に依存しているファイル:
- `lib/repository/profile_repository.dart` — アップロード (uploadMyProfilePhoto, _uploadPhoto)
- `lib/repository/article_repository.dart` — アップロード (uploadJpeg)
- `lib/domain/model/profile.dart` — ダウンロードURL取得 (profilePhotoUrl)

## 変更後

```
Flutter App
  ├─ プロフィール写真 → greendayo-server REST API → VPSディスク
  ├─ BBS記事画像     → greendayo-server REST API → VPSディスク
  └─ デフォルトアバター → greendayo-server 静的ファイル
```

## スコープ

### やること
- greendayo-server に REST API を追加 (multer でファイル受信)
  - `POST /storage/upload/:path*` — ファイルアップロード
  - `GET /storage/:path*` — ファイル配信 (Cache-Control付き)
  - `DELETE /storage/:path*` — ファイル削除
- Flutter 側の3ファイルを書き換え、Firebase Storage → HTTP API に変更
- デフォルトアバター画像をサーバに配置
- `firebase_storage` パッケージを pubspec.yaml から削除

### やらないこと
- Firebase Auth, Firestore, Analytics の変更
- 認証の強化 (現状の userId ベースの簡易方式を維持)
- Nginx での静的ファイル配信 (将来の最適化として残す)
- 既存画像のマイグレーション (新規アップロードから適用)

## API設計

### アップロード
```
POST /storage/upload/users/{uid}/photo
Content-Type: multipart/form-data
Query: ?userId={uid}

Response: { "url": "https://susipero.com/storage/users/{uid}/photo" }
```

### 取得
```
GET /storage/users/{uid}/photo
→ 画像バイナリ (Cache-Control: public, max-age=315360000)
```

### 削除
```
DELETE /storage/bbs/photo/{ulid}?userId={uid}
```

## 認証

簡易方式: リクエストの `userId` クエリパラメータで識別。
Socket.IO 接続時と同じレベルのセキュリティ。

## ファイル保存先

```
greendayo-server/
  uploads/
    users/{uid}/photo        ← プロフィール写真
    bbs/photo/{ulid}         ← BBS記事画像
    default_avatar.png       ← デフォルトアバター
```

## リスク

- **ディスク容量**: 小さな画像のみなのでVPS 1Gプランでも問題なし
- **メモリ**: multer + Express の静的配信は数MB程度の追加
- **バックアップ**: VPSのディスクが飛ぶと画像が消える (少人数実験用途なので許容)
