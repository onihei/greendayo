<!-- BEGIN:nextjs-agent-rules -->
# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->

# Shared Nickname Convention (susipero.com)

サブディレクトリゲーム (nasbi / kaeru / sumomo) と greendayo (susipero.com 本体)
で共有するニックネーム規約。**正本 (canonical) は greendayo の `lib/nickname.ts`**。
仕様を変更するときは greendayo を最初に更新し、各ゲームに同一ロジックをコピーする。

- 共通 localStorage キー: `susipero:nickname`
- バリデーション規則 (`validateNickname`):
  - 文字列であること
  - 改行 (`\n` `\r`) およびタブ (`\t`) を含まないこと
  - 前後 trim 後に 1〜20 文字
  - 無効値の理由は日本語で返す
- 旧キー migration 順序 (共通キーが空のとき初回ロードで昇格):
  1. `nasbi:userName`
  2. `kaeru:userName`
  3. `sumomo:userName`
- 旧キーは migration 後も**削除しない** (ロールバック余地のため)
- userId (`<game>:userId`) は **共通化しない**。各ゲームが独立に持つ
- Firebase Auth (Google ログイン) とは独立。displayName と自動同期しない
- 配布は **コピー運用**。npm/tarball 化はしない
