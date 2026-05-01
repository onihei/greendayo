# 設計: Flutter Web → Next.js 移行

## 設計原則

1. **シンプル最優先**: 機能追加ではなく構成削減を伴う移行。新規ライブラリ追加には常に「これがないと困るか?」を問う。
2. **URL ファーストのルーティング**: 旧 Navigator 2.0 の reactive スタイル (state がスタックを決める) は捨て、URL がそのまま画面を決める素直なモデルにする。
3. **状態管理を最小化**: サーバ状態は Firestore `onSnapshot` を `useEffect` 内で直接購読。クライアント状態 (UI フラグ) は Zustand 1ストアで完結。Riverpod の Provider/Notifier 階層は持ち込まない。
4. **責務分離**: ファイル配信は nginx、ファイル受信と業務ロジックは Next.js、データ層は Firestore、認証は Firebase Auth。境界を曖昧にしない。
5. **Firestore スキーマは不変**: 既存データを 1 件も触らないことが移行の前提。

## 採用スタック

| 役割 | 採用 | 理由 |
|------|------|------|
| フレームワーク | Next.js 16 (App Router) | UI と API を 1 プロセスに集約 |
| 言語 | TypeScript | Firestore モデルの型安全 |
| スタイル | Tailwind CSS | 設定ゼロで dark テーマを Tailwind トークンに落とせる |
| Firebase | `firebase` (クライアントSDK) のみ | Admin SDK 不要 (SSG しないため) |
| サーバ状態 | `onSnapshot` を `useEffect` で直叩き | TanStack Query 等のキャッシュ層は不要 |
| クライアント状態 | Zustand | Riverpod の置換として最小 |
| ジェスチャ | `@use-gesture/react` | BBS の pan/pinch 実装 |
| AI | `@anthropic-ai/sdk` | 旧 server からそのまま流用 |
| プロセス管理 | pm2 (既存) | デプロイ運用を変えない |

採用しない:
- Redux / Recoil / Jotai / TanStack Query
- MUI / shadcn フルセット (必要パーツだけ後追いで導入)
- next-pwa, next-i18next
- SSG / ISR
- Socket.IO (用途消滅)

## ディレクトリ構造

```
nextjs/
├─ app/
│  ├─ layout.tsx                ルートレイアウト + AuthProvider + Theme
│  ├─ page.tsx                  / 掲示板 (BBS, 未ログイン閲覧可)
│  ├─ messenger/
│  │  ├─ page.tsx               一覧
│  │  └─ [sessionId]/page.tsx   トーク
│  ├─ profile/
│  │  ├─ [userId]/page.tsx      公開プロフィール
│  │  └─ me/edit/page.tsx       編集
│  ├─ games/
│  │  ├─ page.tsx               ゲーム一覧
│  │  └─ crossword/page.tsx     クロスワード
│  └─ api/
│     ├─ upload/route.ts                  POST: ファイル保存
│     ├─ upload/[...path]/route.ts        DELETE
│     └─ profile-text/route.ts            POST: Claude 呼び出し
├─ components/
│  ├─ ui/                       最小限の汎用 UI (button, dialog 等)
│  ├─ auth/login-dialog.tsx
│  ├─ bbs/{board, card, form}.tsx
│  ├─ messenger/{session-list, talk-view}.tsx
│  ├─ profile/{photo, edit-form}.tsx
│  └─ layout/{app-bar, bottom-nav, drawer}.tsx
├─ lib/
│  ├─ firebase.ts               initializeApp + 二重実行ガード
│  ├─ firestore/                旧 *_repository.dart 相当 (関数のみ)
│  │  ├─ articles.ts
│  │  ├─ sessions.ts
│  │  ├─ talks.ts
│  │  └─ profiles.ts
│  ├─ hooks/                    useAuth, useArticles, useMyProfile, ...
│  └─ storage.ts                ファイルパス計算 (旧 storage.dart 相当)
├─ stores/
│  └─ ui.ts                     Zustand: drawerOpen など
├─ types/                       Firestore モデル (article, session, talk, profile)
├─ public/icons/
├─ package.json
├─ tsconfig.json
├─ next.config.ts               output: 'standalone'
├─ tailwind.config.ts
└─ .env.local                   Firebase config + CLAUDE_API_KEY
```

## 主要設計判断

### 1. ファイルアップロードの保管場所

**決定**: `/var/lib/susipero/uploads/` (VPS 永続ディレクトリ) に保存し、nginx が `/storage/*` URL で直接配信する。

**理由**:
- 現行の保存形式 (multer によるディスク配置) と互換 → 既存 `greendayo-server/uploads/` を `mv` するだけで移行完了
- Firestore に保存済みの URL (`/storage/...`) を書き換えなくて済む
- デプロイ対象パス (`/home/onihei/susipero/`) の外に置くため、`rsync --delete` で消えない
- Node プロセスを介さないため、画像配信で Next.js が詰まらない
- 追加サービス (Firebase Storage, S3 等) のコスト・依存ゼロ

**代替案と却下理由**:
- Firebase Storage: 利用規約変更で過去に廃止済み (`2026-04-04-replace-firebase-storage` 参照)。再導入は逆行
- S3 / R2: コスト追加 + 既存 URL 書き換え必要 + 学習コスト
- Next.js の `/api/storage/*` で配信: Node がボトルネックになる

### 2. Next.js の API 設計

| エンドポイント | メソッド | 処理 |
|---|---|---|
| `/api/upload` | POST | `multipart/form-data` を受信、`form.field('path')` のパスで `/var/lib/susipero/uploads/{path}` に保存。`{ url: '/storage/...' }` を返却 |
| `/api/upload/[...path]` | DELETE | 該当ファイルとサイドカー meta を削除 |
| `/api/profile-text` | POST | リクエスト body のプロフィール項目で Anthropic Messages API を呼び、生成テキストを返却 |

実装は Route Handler (`app/api/.../route.ts`)。Edge Runtime ではなく Node Runtime (`export const runtime = 'nodejs'`) — `fs` と Anthropic SDK のため。

### 3. 認証ハンドリング

- ルート `layout.tsx` に `AuthProvider` を 1つ置き、`onAuthStateChanged` を購読
- 認証状態は Zustand ストアにキャッシュ (`useAuth()` フックで参照)
- 未ログインで開けるページ (`/`, `/profile/[id]` 等) は user==null でも描画
- ログインダイアログはモーダル。URL を持たない (旧 Flutter 版と同じ挙動)
- ログイン要のページでは未ログイン時にログインを促す UI を出す (リダイレクトはしない、旧版踏襲)

### 4. Firestore データアクセス

旧 `*_repository.dart` (Riverpod Provider 群) は **ただの関数モジュール** に解体する:

```ts
// lib/firestore/articles.ts
export function articlesQuery() { return query(collection(db, 'articles'), orderBy('createdAt','desc')); }
export async function createArticle(input: ArticleInput) { ... }
export async function deleteArticle(id: string) { ... }
```

リアクティブ購読はフック側:

```ts
// lib/hooks/use-articles.ts
export function useArticles() {
  const [docs, setDocs] = useState<Article[]>([]);
  useEffect(() => onSnapshot(articlesQuery(), snap => setDocs(snap.docs.map(toArticle))), []);
  return docs;
}
```

クラスベースの Controller (旧 `bbsControllerProvider`, `_ViewControllerProvider`) は廃止。「アクション関数の集合」と「フック」に分けるだけで十分機能する。

### 5. 型変換 (Firestore Timestamp)

旧 `withConverter` の置換として、各モデルファイルに手書きの `from / to` を置く:

```ts
// types/article.ts
export type Article = { id: string; content: string; createdAt: Date; ... };
export const fromArticleDoc = (d: QueryDocumentSnapshot): Article => ({
  id: d.id,
  content: d.get('content'),
  createdAt: (d.get('createdAt') as Timestamp).toDate(),
  ...
});
```

Zod 等の追加ライブラリは導入しない。型と変換関数だけで十分。

### 6. BBS 盤面のジェスチャ

旧 `GestureDetector.onScaleStart/Update` の挙動 (1指=pan / 2指以上=scale) を `@use-gesture/react` の `useGesture` で再現。

```ts
const bind = useGesture({
  onDrag: ({ pinching, movement }) => { if (!pinching) setPan(...) },
  onPinch: ({ offset: [scale] }) => setScale(scale),
});
```

慣性スクロールは `react-spring` を必要に応じて後追い導入 (初期実装では入れない)。

### 7. nginx の責務分離

```nginx
location /storage/ {
  alias /var/lib/susipero/uploads/;
  expires max;
  add_header Cache-Control "public, immutable";
  try_files $uri =404;
}
location / {
  proxy_pass http://127.0.0.1:3000;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```

旧 `/greendayo.io/` (Socket.IO パス) は完全削除。

### 8. デプロイ

```bash
# deploy.sh (新版)
npm ci && npm run build
rsync -avz --delete --exclude=node_modules --exclude=.next/cache ./ susipero:/home/onihei/susipero/
ssh susipero 'cd /home/onihei/susipero && npm ci --omit=dev && (pm2 restart susipero || pm2 start npm --name susipero -- start)'
```

`next.config.ts` は `output: 'standalone'` を採用。さらにスリムな転送を実現する場合は `.next/standalone/` のみを rsync する形に最適化可能 (Phase 4 までに判断)。

## ロールバック戦略

差し替え時 (Phase 4):

1. 旧 `build/web/` 一式と旧 nginx 設定 (`susipero.com.conf.flutter`) を VPS に保持
2. 新 nginx 設定 (`susipero.com.conf.nextjs`) で動作確認
3. 異常時は `cp susipero.com.conf.flutter /etc/nginx/sites-available/susipero.com && nginx -s reload && pm2 stop susipero`
4. アップロードファイルは `/var/lib/susipero/uploads/` に新旧共通で存在するため、旧 Flutter 版は `greendayo-server` を起動し直すだけで復活する

## リスクと対策

| リスク | 影響 | 対策 |
|---|---|---|
| Firebase 初期化が HMR で多重実行 | dev で例外 | `getApps().length ? getApp() : initializeApp(...)` ガード |
| Firestore セキュリティルールで未ログイン読みが弾かれる | `/` が空になる | 既に「ログイン前でも掲示板を見せる」コミットで調整済み。新フロントに切り替え後すぐ動作確認 |
| `/var/lib/susipero/uploads/` への書き込み権限不足 | アップロード失敗 | `chown onihei:onihei` を VPS 側で初回設定 |
| 旧 Flutter 版とのスキーマ差異 | データ破損 | スキーマは一切変更しない。`fromXxx` だけ書く |
| pm2 が古い node を掴む | 起動失敗 | `pm2 update` を Phase 4 で実施 |
| Socket.IO 廃止で AI 自己紹介の挙動が変わる | UX 退行 | REST 版で同じレスポンス形式を返す。Loading 状態を明示 |
