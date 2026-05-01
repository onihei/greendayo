# web-platform Specification

## Purpose
TBD - created by archiving change migrate-to-nextjs. Update Purpose after archive.
## Requirements
### Requirement: Next.js による単一プロセス配信

すしぺろの Web フロントエンドは Next.js 16 (App Router, TypeScript) で実装され、`pm2` で起動された 1 つの Node プロセスが UI と API Routes の両方を提供 SHALL する。Flutter Web ビルドおよび旧 `greendayo-server` プロセスは MUST 廃止される。

#### Scenario: ユーザーが susipero.com にアクセスする
- **WHEN** ブラウザが `https://susipero.com/` をリクエストする
- **THEN** nginx は `127.0.0.1:3000` の Next.js プロセスにリバースプロキシし、Next.js が React によりレンダリングされた HTML を返却する
- **AND** Flutter の CanvasKit/WASM 一式は配信されない

#### Scenario: 旧 Socket.IO エンドポイントへのアクセス
- **WHEN** クライアントが `/greendayo.io/` パスにアクセスする
- **THEN** nginx は当該 location ブロックを持たず 404 を返す
- **AND** サーバ側で Socket.IO サーバは起動していない

### Requirement: URL ファーストのルーティング

画面の選択は URL によってのみ決定 SHALL される。状態に基づいて画面スタックを再構築する旧 Navigator 2.0 reactive スタイルは MUST 採用しない。

#### Scenario: 画面と URL の対応
- **WHEN** ユーザーが以下のパスにアクセスする
- **THEN** それぞれ対応する画面が表示される
  - `/` → 掲示板 (BBS)
  - `/messenger` → 会話一覧
  - `/messenger/{sessionId}` → トーク画面
  - `/profile/{userId}` → 公開プロフィール
  - `/profile/me/edit` → 自分のプロフィール編集
  - `/games` → ゲーム一覧
  - `/games/crossword` → クロスワード

#### Scenario: ログインダイアログ
- **WHEN** 未ログイン状態でログインを促す UI を操作する
- **THEN** ログインダイアログがモーダルとして開く
- **AND** URL は変化しない

### Requirement: 未ログイン時の閲覧可能範囲

掲示板 `/` および公開プロフィール `/profile/{userId}` は未ログインでも閲覧 SHALL できる。書き込み・編集等の操作は SHALL ログインを要する。

#### Scenario: 未ログインで掲示板を開く
- **WHEN** 未ログインのユーザーが `/` にアクセスする
- **THEN** Firestore の既存記事一覧がそのまま表示される
- **AND** 投稿フォームの起動 UI は非表示または無効化される
- **AND** ヘッダーにログイン導線が表示される

#### Scenario: 未ログインでメッセンジャーを開く
- **WHEN** 未ログインのユーザーが `/messenger` にアクセスする
- **THEN** ログインを促す案内とログインボタンが表示される
- **AND** リダイレクトは行われない

### Requirement: Firestore スキーマ互換

新フロントエンドは既存の Firestore コレクション・ドキュメント構造・フィールド名を一切変更せずに読み書き SHALL する。スキーマ変更は MUST 行わない。

#### Scenario: 既存データの読み出し
- **WHEN** 新フロントエンドが既存の `articles`, `sessions`, `talks`, `profiles` コレクションを購読する
- **THEN** 旧 Flutter 版で書き込まれたドキュメントがエラーなく型変換されて表示される

#### Scenario: 新規書き込みのスキーマ
- **WHEN** 新フロントエンドからドキュメントを作成する
- **THEN** 旧 Flutter 版の `*_repository.dart` が書き込んでいたフィールド構成と同一の形で保存される

### Requirement: クライアント状態管理

サーバ状態 (Firestore) は `onSnapshot` を `useEffect` 内で直接購読 SHALL する。クライアント UI 状態 (ドロワー開閉等) は Zustand の単一ストアで保持 SHALL する。Riverpod 相当の Provider 階層は MUST 持ち込まない。

#### Scenario: Firestore 変更の反映
- **WHEN** 別クライアントから Firestore の `articles` に新規ドキュメントが追加される
- **THEN** `/` を表示中の全クライアントの画面に新記事が自動で表示される

### Requirement: 廃止対象

以下は新プラットフォームに MUST 移植されない。

- `lib/features/top/` 一式 (シェーダー、動画、ドーナツ Painter を含むランディングページ)
- `lib/shared/ui/` の Top 専用コンポーネント (`dot_image`, `flip_container`, `spiral_container`, `showy_button`, `footer`)
- `shaders/*.frag` および `flutter_shaders` 依存
- `assets/videos/` および Top 連動の画像アセット
- `flutter_native_splash` によるスプラッシュ
- Socket.IO 一式 (`socket_io_client`, `socket.io` サーバ)
- `greendayo-server/` プロセス全体

#### Scenario: 廃止コンポーネントへのアクセス
- **WHEN** リポジトリ内に上記廃止対象のディレクトリ・ファイルが残っている
- **THEN** それは Phase 5 のクリーンアップで削除されている

