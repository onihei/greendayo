# Flutter Web → Next.js への全面リライト

## 背景

現行 `すしぺろ (susipero.com)` は Flutter Web で構築されている。CanvasKit/WASM の初期化コストにより初回表示が遅く、SEO もほぼ効かない。さらに以下の負債が積み重なっている。

- `features/top/` (シェーダー、動画、CustomPaint を多用したランディングページ) はもはや未使用
- `shared/ui/{dot_image, flip_container, spiral_container, showy_button, footer}` は Top 専用
- `flutter_native_splash`, `flutter_shaders`, `video_player`, `assets/videos/` も Top 連動でしか使われていない
- `greendayo-server` (Node + Socket.IO) は実質「ファイル保管」と「Claude API プロキシ」の2用途しかなく、Socket.IO は `generateProfileText` の1イベントだけに使われている (メッセンジャーのリアルタイムは Firestore `onSnapshot`)

「初回表示を速くしたい」という目的に対して Flutter Web のままでは限界があり、構成も冗長。Next.js に作り替えて構成自体をシンプルにする。

## 現状

```
Flutter Web (lib/ ~80 dart)
  ├─ features/{auth, bbs, messenger, profile, games, home}  ← 移植対象
  ├─ features/top                                           ← 廃止
  ├─ shared/ui/{Top専用部品}                                ← 廃止
  └─ shaders/*.frag                                         ← 廃止

greendayo-server (Node)
  ├─ /storage/* (multer + ディスク)                         ← Next.js API に統合
  └─ Socket.IO `generateProfileText`                        ← REST化して統合 (Socket全廃)

ホスティング: さくらVPS / nginx 直配信 (rsync deploy)
```

## 変更後

```
Next.js 16 (App Router) 単一プロセス
  ├─ app/                       UI (Reactコンポーネント)
  ├─ app/api/upload             ファイルアップロード (旧 /storage/upload/*)
  ├─ app/api/upload/[...path]   ファイル削除 (旧 DELETE /storage/*)
  └─ app/api/profile-text       Claude API 呼び出し (旧 Socket.IO)

ファイル配信: nginx が /var/lib/susipero/uploads/ から直接配信 (Node を経由しない)
ホスティング: さくらVPS / pm2 で `next start` / nginx リバースプロキシ
データ:       Firebase Auth + Cloud Firestore (スキーマそのまま)
```

## スコープ

### やること
- `nextjs/` サブディレクトリに Next.js 16 アプリを新規作成 (TypeScript / Tailwind CSS)
- 既存機能の移植: `bbs / messenger / profile / games / auth / home`
- 状態管理は Zustand (UI状態) + Firestore `onSnapshot` 直叩き (サーバ状態)。Riverpod は使わない
- ルーティングは URL ファーストの素直な App Router 構成に作り直す
  - `/` (BBS), `/messenger`, `/messenger/[id]`, `/profile/[id]`, `/profile/me/edit`, `/games`, `/games/crossword`
- Next.js API Routes:
  - `POST /api/upload` (multipart受信 → ディスク保存)
  - `DELETE /api/upload/[...path]`
  - `POST /api/profile-text` (Claude API プロキシ)
- アップロード保管: `/var/lib/susipero/uploads/` (デプロイ対象外、nginx 直配信)
- 既存 `greendayo-server/uploads/` を `/var/lib/susipero/uploads/` に mv するだけのデータ移行
- `deploy.sh` を Next.js + pm2 用に書き直し
- 旧 Flutter 一式と `greendayo-server/` の削除
- 移行完了後、`nextjs/` の中身をリポジトリルートへ昇格

### やらないこと
- SSG / ISR の導入 (CSR/SSR のみ。初回表示速度はバンドル軽量化で達成する)
- Firestore のデータマイグレーション (スキーマ・フィールド名すべて維持)
- Firebase Storage の再導入 (引き続き VPS ローカル保管)
- Socket.IO の維持 (全廃)
- UI デザインの根本変更 (現行に近い Material 風ダークテーマを Tailwind で再現)
- 多言語化 (現状 ja のみ)
- PWA 対応
- `assets/videos/`, `assets/images/susi*` 等 Top 連動アセットの引継ぎ
- Flutter ↔ Next.js の並行運用 (Phase 4 で一気に差し替え)

## 受け入れ基準

- 旧Flutter版にあった以下のユーザーフローがすべて動作する
  - 未ログインで `/` の掲示板を閲覧できる
  - Google ログインができる
  - 掲示板に投稿 (テキスト/画像) ができ、ドラッグ・ピンチで盤面を操作できる
  - メッセンジャーで会話一覧→トーク画面に遷移し、リアルタイムでメッセージが届く
  - プロフィール詳細を見られ、自分のプロフィール編集で AI 自己紹介を生成できる
  - ゲーム一覧から各ゲーム (クロスワード等) を開ける
- 既存 Firestore のレコードが新フロントから問題なく読み書きできる (スキーマ変更なし)
- 既存アップロード済みファイルの URL (`/storage/...`) が引き続き 200 を返す
- 初回表示 (LCP) が現行 Flutter Web 版より明確に短い
- `susipero.com` の差し替え後、ロールバックは nginx 設定の戻しと旧ビルド成果物の復帰のみで完結する

## 非目標

- パフォーマンスの数値目標 (LCP < N秒) は今回設定しない (体感重視)
- アクセシビリティ監査 (将来の別 change で扱う)
- E2E テストの整備 (将来の別 change で扱う)
