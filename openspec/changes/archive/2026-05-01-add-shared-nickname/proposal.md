# Add Shared Nickname Across Games

## Why

すしぺろ (susipero.com) のサブディレクトリゲーム (nasbi / kaeru / sumomo) は
それぞれ独自の localStorage キー (`<game>:userName`) でニックネームを保存しており、
ユーザは初回プレイ時にゲームごとに同じニックネームを入れ直す必要がある。
カジュアルプレイの導入摩擦になっている。

3 ゲームすべてが同一オリジン (susipero.com) にデプロイされているため、
**localStorage を共通キー (`susipero:nickname`) で共有するだけ** で、
入力 1 回でゲーム間を行き来できる体験になる。すでに各ゲームに散在している
ほぼ同じバリデーションロジックを 1 箇所に集約する DRY 効果も得られる。

## What Changes

- greendayo (susipero.com 本体) に **`lib/nickname.ts`** を新設し、
  サイト共通ニックネーム規約の **正本 (canonical)** とする
- 共通 localStorage キー: `susipero:nickname`
- バリデーション: 既存 kaeru/sumomo の `validateUserName` (1〜20 文字、改行/タブ禁止) を採用
- 既存キー (`nasbi:userName`, `kaeru:userName`, `sumomo:userName`) からの
  **片方向マイグレーション** を提供 (初回ロード時に共通キーが空なら拾って昇格)
- 各ゲーム (nasbi / kaeru / sumomo) は `lib/nickname.ts` を **コピー** して使用
- ニックネーム入力 UI は各ゲームの既存実装をそのまま利用 (見た目の統一はしない)
- 未使用の `greendayo-login/` ディレクトリを削除する

## Impact

- Affected specs: `shared-nickname` (新規 capability)
- Affected code:
  - greendayo: `lib/nickname.ts` 追加、`CLAUDE.md` / `AGENTS.md` 規約追記
  - nasbi: `packages/web/src/App.tsx` のインライン定数を `profile.ts` パターンへ寄せ、共通キーへ
  - kaeru: `packages/web/src/profile.ts` のキー差し替え
  - sumomo: `packages/web/src/profile.ts` のキー差し替え
  - greendayo-login/ リポ削除

## Out of Scope

- userId の共通化 (各ゲームの `<game>:userId` はそのまま温存)
- スコア・戦績のクロスゲーム集約
- Firebase Auth (Google ログイン) との統合
- ホスト UI (`/login` 専用ページなど) の作成
- パッケージ配布 (npm pack, file: 依存等) — コピー運用とする
