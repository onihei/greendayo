# すしぺろ (susipero.com)

Next.js 16 製のソーシャルプラットフォーム。掲示板、メッセンジャー、プロフィール、ゲーム外部リンクで構成。

## セットアップ

```bash
cp .env.local.example .env.local      # 値を埋める (CLAUDE_API_KEY 必須)
npm install
npm run dev                            # http://localhost:3000
```

## デプロイ

```bash
bash deploy/deploy.sh
```

詳細は [`deploy/CUTOVER.md`](deploy/CUTOVER.md)。

## 技術構成

| レイヤ | 採用 |
|--------|------|
| フレームワーク | Next.js 16 (App Router) + TypeScript |
| スタイル | Tailwind CSS v4 |
| 認証 | Firebase Auth (Google) |
| データベース | Cloud Firestore (`onSnapshot` 直叩き) |
| クライアント状態 | Zustand |
| AI | Anthropic Claude (`claude-haiku-4-5-20251001`) |
| ホスティング | さくらVPS / pm2 + nginx |
| ファイル保管 | `/var/lib/susipero/uploads/` (nginx 直配信) |

詳しい構造は [`CLAUDE.md`](CLAUDE.md) を参照。
