# file-storage Specification

## Purpose
TBD - created by archiving change migrate-to-nextjs. Update Purpose after archive.
## Requirements
### Requirement: 永続ディレクトリへの保存

アップロードファイルは VPS 上の `/var/lib/susipero/uploads/` に保存 SHALL される。Next.js プロセスが書き込み、nginx が直接配信 SHALL する。デプロイ対象パスの外に置くことで `rsync --delete` で MUST 消去されないことを保証する。

#### Scenario: VPS 初期セットアップ
- **WHEN** VPS のセットアップを実施する
- **THEN** `/var/lib/susipero/uploads/` ディレクトリが存在する
- **AND** 所有者は Next.js を実行するユーザー (`onihei`) である

#### Scenario: 既存ファイルの移行
- **WHEN** 旧 `greendayo-server/uploads/` の内容を `/var/lib/susipero/uploads/` に `mv` する
- **THEN** Firestore に保存済みの `/storage/...` URL は書き換えなしで引き続き 200 を返す

### Requirement: アップロード API

`POST /api/upload` で multipart/form-data を受け、指定されたパスに保存 SHALL する。10MB を超えるファイルは MUST 拒否される。

#### Scenario: ファイルアップロード
- **WHEN** クライアントが `POST /api/upload` に `multipart/form-data` を送信する (フィールド: `file`, `path`)
- **THEN** ファイルは `/var/lib/susipero/uploads/{path}` に保存される
- **AND** 同じ親ディレクトリに `{ファイル名}.meta.json` が作成され、`mimetype`, `size`, `originalName`, `uploadedAt` が記録される
- **AND** レスポンス JSON は `{ "url": "/storage/{path}" }` を返す

#### Scenario: 上限超過
- **WHEN** クライアントが 10MB を超えるファイルを送信する
- **THEN** API は 413 を返し、ファイルは保存されない

### Requirement: 削除 API

`DELETE /api/upload/{path}` で指定パスのファイルとサイドカー meta を削除 SHALL する。

#### Scenario: ファイル削除
- **WHEN** クライアントが `DELETE /api/upload/users/abc/photo` を呼び出す
- **THEN** `/var/lib/susipero/uploads/users/abc/photo` と同名の `.meta.json` が削除される
- **AND** レスポンス JSON は `{ "deleted": "users/abc/photo" }` を返す

#### Scenario: 存在しないファイルの削除
- **WHEN** クライアントが存在しないパスに DELETE を発行する
- **THEN** API は 404 を返す

### Requirement: nginx による直接配信

`/storage/*` パスは nginx が `/var/lib/susipero/uploads/` から直接配信 SHALL する。Next.js プロセスを MUST 経由しない。

#### Scenario: ファイル取得
- **WHEN** クライアントが `GET /storage/users/abc/photo` を発行する
- **THEN** nginx は `/var/lib/susipero/uploads/users/abc/photo` をそのまま返す
- **AND** `Cache-Control: public, immutable` および `expires max` ヘッダが付与される
- **AND** Next.js プロセスはこのリクエストを受け取らない

#### Scenario: 存在しないファイルの取得
- **WHEN** クライアントが存在しないパスに GET を発行する
- **THEN** nginx は 404 を返す

