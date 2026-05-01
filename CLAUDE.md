@AGENTS.md

# CLAUDE.md

## プロジェクト概要

すしぺろ (susipero.com) - Next.js Web ソーシャルプラットフォーム

- フレームワーク: Next.js 16 (App Router) + TypeScript
- スタイル: Tailwind CSS v4
- 状態管理: Zustand (UI状態) + Firestore `onSnapshot` 直叩き (サーバ状態)
- 認証: Firebase Auth (Google ログイン)
- データベース: Cloud Firestore
- AI: Anthropic Claude (自己紹介文生成)
- ファイル配信: nginx が `/var/lib/susipero/uploads/` から直接配信
- ホスティング: さくらVPS / pm2 (port 3100) + nginx リバースプロキシ

## ディレクトリ構造

```
.
├─ app/                          App Router (UI + API Routes)
│  ├─ layout.tsx                 ルート (AuthProvider 包含)
│  ├─ page.tsx                   / 掲示板 (BBS, 未ログイン閲覧可)
│  ├─ globals.css                Material 風ダークテーマトークン
│  ├─ messenger/
│  │  ├─ page.tsx                会話一覧
│  │  └─ [sessionId]/page.tsx    トーク
│  ├─ profile/
│  │  ├─ [userId]/page.tsx       公開プロフィール
│  │  └─ me/edit/page.tsx        自分のプロフィール編集 (9問ステップ)
│  ├─ games/page.tsx             ゲーム一覧 (外部リンク)
│  └─ api/
│     ├─ upload/route.ts         POST: ファイルアップロード
│     ├─ upload/[...path]/route.ts DELETE
│     └─ profile-text/route.ts   POST: Claude API でプロフィール文生成
├─ components/
│  ├─ auth/{auth-provider, login-dialog}.tsx
│  ├─ layout/{app-bar, bottom-nav, drawer, app-shell}.tsx
│  ├─ bbs/{board, card, form, page-content, store}.tsx
│  └─ messenger/{session-list, talk-view}.tsx
├─ lib/
│  ├─ firebase.ts                initializeApp + 二重実行ガード
│  ├─ uploads.ts                 SUSIPERO_UPLOADS_DIR + safeJoin
│  ├─ image-resize.ts            Canvas で 500px / quality 0.8 / ULID
│  ├─ upload-client.ts           POST/DELETE クライアント
│  ├─ talk-use-case.ts           セッション開始 + メッセージ送信
│  ├─ games.ts                   ゲームメタデータ
│  ├─ firestore/                 CRUD 関数群 (旧 *_repository.dart 相当)
│  │  ├─ articles.ts
│  │  ├─ sessions.ts
│  │  ├─ talks.ts
│  │  └─ profiles.ts
│  └─ hooks/                     useAuth, useArticles, useMyProfile, ...
├─ stores/                       Zustand
│  ├─ auth.ts                    認証状態
│  └─ ui.ts                      ドロワー、ログインダイアログ
├─ types/                        Firestore モデル + from/to ヘルパー
│  ├─ article.ts
│  ├─ session.ts
│  ├─ talk.ts
│  └─ profile.ts
├─ deploy/
│  ├─ deploy.sh                  ローカルから VPS へデプロイ
│  ├─ susipero.com.conf          nginx 設定 (リファレンス、本番は nginx.conf に直書き)
│  └─ CUTOVER.md                 切替・運用手順書
├─ public/                       静的アセット (favicon, icons)
├─ next.config.ts                output: 'standalone'
├─ tailwind.config.ts            (Tailwind v4 は CSS で設定)
├─ tsconfig.json                 paths: @/* → ./*
└─ openspec/                     仕様駆動 change 管理
```

## 設計方針

### URL ファーストのルーティング

App Router のファイルベース。状態が画面スタックを決める旧 Navigator 2.0 reactive スタイルは採用しない。
未ログインで開けるルート: `/`, `/profile/[id]`, `/games`。

### 状態管理

- **サーバ状態 (Firestore)**: `onSnapshot` を `useEffect` 内で直接購読。TanStack Query 等のキャッシュ層は導入しない。
- **クライアント UI 状態**: Zustand 1 ストア (`stores/ui.ts`) で完結。
- **認証状態**: Zustand `stores/auth.ts` に `onAuthStateChanged` を流す (`useAuthSubscriber`)。

### Firestore モデル

- `types/{article,session,talk,profile}.ts` にプレーン TS 型と `fromXxxDoc` / `toXxxDoc` を持つ。
- `Timestamp` ⇄ `Date` 変換はこのヘルパー内で行う。
- `lib/firestore/*.ts` は CRUD 関数群 (旧 `*_repository.dart` 相当)。クラスは作らない。

### ファイルアップロード

- クライアント: `<input type="file">` → Canvas で 500px / JPEG quality 0.8 にリサイズ → `POST /api/upload`
- サーバ: `app/api/upload/route.ts` (Node Runtime) が `multipart/form-data` を受信し `/var/lib/susipero/uploads/{path}` に保存
- 配信: nginx が `/storage/*` を `/var/lib/susipero/uploads/` から直接配信 (Next.js を経由しない)
- `safeJoin` でパストラバーサル防止
- 上限 10MB

### AI 自己紹介

- `POST /api/profile-text` (Node Runtime) が Anthropic SDK で `claude-haiku-4-5-20251001` を呼ぶ
- 旧 Socket.IO `generateProfileText` の REST 化
- `CLAUDE_API_KEY` はサーバ環境変数のみ、クライアントに露出しない

## 開発

```bash
npm install
npm run dev          # http://localhost:3000
npm run build        # standalone ビルド (.next/standalone)
npm run start        # node .next/standalone/server.js (要 PORT 等の env)

# 型チェック (build_runner 相当はない、tsc が代替)
npx tsc --noEmit
```

`.env.local` の中身は `.env.local.example` を参照。Firebase Web 設定 + `CLAUDE_API_KEY` + `SUSIPERO_UPLOADS_DIR=./uploads-dev`。

## デプロイ

```bash
bash deploy/deploy.sh
```

- ローカルで `npm ci && npm run build` (standalone)
- `.next/standalone/` + `.next/static/` + `public/` を rsync で `susipero:/home/onihei/susipero/`
- ssh で `pm2 restart susipero || pm2 start server.js --name susipero`
- nginx は触らない (一度切替済み、`/storage/` alias + `/` proxy to :3100 + `/greendayo.io/` 削除済み)

VPS の `.env.production` (port 3100, Firebase 設定, CLAUDE_API_KEY, SUSIPERO_UPLOADS_DIR=/var/lib/susipero/uploads) は rsync 除外で温存される。

詳細・ロールバック手順は `deploy/CUTOVER.md`。

## 重要な制約

- Firestore のスキーマ・コレクション名・フィールド名は旧 Flutter 版と完全互換 (`articles`, `sessions`, `talks`, `profiles` の構造を絶対に変更しない)
- 既存アップロード済みファイルの URL (`/storage/{path}`) を必ず維持する
- ポート 3100 (3000 は VPS 上の他アプリ `battlechat.io` で使用中)
- nginx 設定は VPS 上の `/etc/nginx/nginx.conf` に直接書かれている (sites-enabled は使われていない)。複数アプリ (nasbi/kaeru/sumomo/fx/kinoko/battlechat) と同居しているので変更時はサージカルに
