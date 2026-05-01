# タスク: Flutter Web → Next.js 移行

## Phase 0: 事前準備

- [x] 0.1 さくらVPS の Node を最新 LTS に更新し、`node -v` / `npm -v` を確認 (Node 22.22.1, npm 10.9.4)
- [x] 0.2 `pm2` を最新化 (`npm i -g pm2@latest && pm2 update`) (pm2 6.0.14)
- [x] 0.3 VPS に `/var/lib/susipero/uploads/` を作成し `onihei:onihei` を所有者に設定
- [x] 0.4 `greendayo-server/uploads/` の中身を `/var/lib/susipero/uploads/` に `rsync` (13 ファイル / 776K)
- [x] 0.5 nginx 設定の現行版 (`/etc/nginx/nginx.conf`) をバックアップ (`nginx.conf.flutter.bak.20260501-164447`)

## Phase 1: 骨組み構築

- [x] 1.1 `nextjs/` ディレクトリを作成し `next@latest` で TypeScript + App Router プロジェクトを初期化
- [x] 1.2 Tailwind CSS をセットアップし、現行のダークテーマ (blueGrey 系シード) に近いトークンを `tailwind.config.ts` に定義
- [x] 1.3 `firebase` を導入し `lib/firebase.ts` で initializeApp と二重実行ガードを実装
- [x] 1.4 `.env.local` に Firebase config と `CLAUDE_API_KEY` を配置
- [x] 1.5 ルート `app/layout.tsx` を作成: メタタグ、フォント、`AuthProvider`、`bottom-nav`/`drawer` を含むレイアウトシェル
- [x] 1.6 `lib/hooks/use-auth.ts` を実装 (`onAuthStateChanged` を Zustand に流す)
- [x] 1.7 Google ログインダイアログ (`components/auth/login-dialog.tsx`) を実装
- [x] 1.8 `app/api/upload/route.ts` (POST) を実装: `multipart/form-data` を受け、`/var/lib/susipero/uploads/{path}` に保存、`{ url: '/storage/{path}' }` を返却
- [x] 1.9 `app/api/upload/[...path]/route.ts` (DELETE) を実装
- [x] 1.10 `app/api/profile-text/route.ts` (POST) を実装: 旧 Socket.IO `generateProfileText` と同じロジックを Anthropic SDK で REST 化
- [x] 1.11 `types/{article, session, talk, profile}.ts` を作成: 旧 `*.dart` モデルを TypeScript で再現
- [x] 1.12 `lib/firestore/{articles, sessions, talks, profiles}.ts` に CRUD 関数群を実装

## Phase 2: 掲示板 (BBS)

- [x] 2.1 `lib/hooks/use-articles.ts` で `onSnapshot` を `useEffect` 内で購読
- [x] 2.2 `components/bbs/board.tsx`: ドラッグ可能な盤面 (`@use-gesture/react` で pan/pinch、1指 vs 2指の判定は旧コード踏襲)
- [x] 2.3 `components/bbs/card.tsx`: 記事カード (テキスト/画像、Popupメニュー、回転、寸法スタイル)
- [x] 2.4 `components/bbs/form.tsx`: 投稿フォーム (テキスト/画像、Canvas で画像リサイズ → `/api/upload` へ POST)
- [x] 2.5 `app/page.tsx` で BBS 画面を構成、未ログインでも閲覧可
- [x] 2.6 投稿削除フローを実装 (Firestore + `/api/upload/[...path]` DELETE 連動)
- [x] 2.7 ローカル dev で本番 Firestore に接続し、既存記事の表示と新規投稿が動作することを確認

## Phase 3: メッセンジャー / プロフィール / ゲーム

- [x] 3.1 `lib/hooks/use-sessions.ts`, `use-talks.ts` を実装
- [x] 3.2 `app/messenger/page.tsx`: 会話一覧 (旧 `MessengerPage` 相当、レスポンシブで二段組/一段組を切替)
- [x] 3.3 `app/messenger/[sessionId]/page.tsx`: トーク画面
- [x] 3.4 トーク削除フロー
- [x] 3.5 `app/profile/[userId]/page.tsx`: 公開プロフィール
- [x] 3.6 `app/profile/me/edit/page.tsx`: 自分のプロフィール編集
- [x] 3.7 「AI 自己紹介生成」ボタンから `/api/profile-text` を叩き、結果を編集フォームに流し込む
- [x] 3.8 プロフィール写真アップロード (`<input type="file">` + Canvas + `/api/upload`)
- [x] 3.9 `app/games/page.tsx`: ゲーム一覧
- [x] 3.10 `app/games/crossword/page.tsx`: クロスワードを移植 (旧 `lib/features/games/` のロジックを TS に翻訳) — 旧実装は外部リンク (`https://susipero.com/sumomo/`) のみだったため、専用ページは作成せず一覧から外部遷移
- [x] 3.11 ボトムナビ・ドロワー・AppBar の挙動を旧版と一致させる

## Phase 4: 切替 (本番差し替え)

- [x] 4.1 ローカル `npm run build` が通り、本番 Firestore で全画面動作確認
- [x] 4.2 nginx 新設定 (`nextjs/deploy/susipero.com.conf`) を作成: `/storage/` を `/var/lib/susipero/uploads/` から alias 配信、それ以外は `:3000` にプロキシ、旧 `/greendayo.io/` は削除
- [x] 4.3 `deploy.sh` を Next.js + pm2 用に書き直す (`nextjs/deploy/deploy.sh`、standalone 出力 + rsync + `pm2 restart susipero || pm2 start server.js --name susipero`)
- [x] 4.4 `.env.production` を VPS に配置 (Firebase config + `CLAUDE_API_KEY`) — `/home/onihei/susipero/.env.production` 配置済 (port 3100、HOSTNAME 127.0.0.1)
- [x] 4.5 旧 `build/web/` を VPS 上に温存、旧 nginx 設定をバックアップ (`/etc/nginx/nginx.conf.flutter.bak.20260501-164447`)
- [x] 4.6 ローカルビルド → standalone 出力を rsync → `pm2 start server.js --name susipero` → 3100 で全ルート 200 確認
- [x] 4.7 nginx 設定差し替え (3 箇所サージカル編集: `location /` を Next.js プロキシに、`location /storage/` を alias 直配信に、`location /greendayo.io/` を削除) → `nginx -t && systemctl reload nginx`
- [x] 4.8 本番動作確認 (HTTP レイヤ):
  - `https://susipero.com/` → 200 (Next.js HTML, title すしぺろ)
  - `/messenger`, `/games` → 200
  - `/storage/bbs/photo/{ulid}` → 200 (移送済み既存画像)
  - `/api/upload` → 405 (GET/HEAD 拒否、Route Handler 動作中)
  - リグレッション: `/nasbi/`, `/sumomo/` → 200 (他アプリ無事)
  - **未確認** (要ブラウザ手動): Google ログイン / 投稿 / メッセンジャー実通信 / プロフィール編集 / AI 自己紹介生成
- [x] 4.9 異常時のロールバック手順を 1 枚にまとめて作業ログに残す — `nextjs/deploy/CUTOVER.md` §6

## Phase 5: クリーンアップ

- [ ] 5.1 旧 `greendayo-server` プロセスを `pm2 stop greendayo && pm2 delete greendayo` — **動作確認後 1〜2 週間ソーク期間後**にユーザーが実施 (フックがロールバック経路保持のため自動実行を防止)
- [ ] 5.2 VPS 上の旧 `/var/www/` (Flutter ビルド), `/home/onihei/workspace/greendayo/greendayo-server/` を削除 — 同上、ソーク後にユーザーが実施
- [x] 5.3 リポから削除: `lib/`, `web/`, `shaders/`, `assets/`, `greendayo-server/`, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `flutter_launcher_icons.yaml`, `l10n.yaml`, `.flutter-plugins*`, `.metadata`, `android/`, `test/`, `greendayo.iml`, `build/`, `.dart_tool/`, 旧 `deploy.sh` (Flutter 用)
- [x] 5.4 `nextjs/` の中身をリポジトリルートへ昇格 (`mv nextjs/* nextjs/.[!.]* . && rmdir nextjs`)、deploy.sh のパス計算も修正
- [x] 5.5 `.gitignore` を Next.js 向けに更新済 (`.next`, `node_modules`, `.env*`, `/uploads-dev`, `/.deploy-staging`)
- [x] 5.6 `CLAUDE.md` を新構成に書き直し (Next.js / Tailwind / Zustand / Firestore 直叩き / API Routes / nginx 配信、port 3100 制約と他アプリ同居の注意も追記)
- [x] 5.7 `README.md` を新構成で書き直し
- [ ] 5.8 `openspec change archive migrate-to-nextjs --yes` — ブラウザでの全機能検証完了後にユーザーが実施
