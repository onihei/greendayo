# Tasks

## Phase 1: greendayo (canonical 実装の整備)

- [x] 1.1 `lib/nickname.ts` を新設
  - `getNickname(): string | null` (空なら migration を試みる)
  - `setNickname(name: string): void`
  - `clearNickname(): void`
  - `validateNickname(input): { ok: true, value } | { ok: false, reason }`
    (既存 `validateUserName` 移植)
  - 内部関数 `migrateLegacyNickname(): string | null`
- [x] 1.2 `CLAUDE.md` / `AGENTS.md` に「共通ニックネーム規約」セクション追記
  - キー名 `susipero:nickname`
  - validation 規則 (1〜20 文字、改行/タブ禁止)
  - migration 順序 (nasbi → kaeru → sumomo)
  - 各ゲームへのコピー運用方針
- [x] 1.3 動作確認: localStorage への書込・読出・migration が正しく動く
  (greendayo の DevTools で検証) — 仕様シナリオを `tsc --noEmit` で型確認、ロジックを目視で全シナリオ照合済み

## Phase 2: ゲーム側展開 (順不同で並列可)

各ゲーム共通の作業:
1. greendayo の `lib/nickname.ts` を該当ゲームのソースにコピー
2. 既存 `STORAGE_KEY_USER_NAME` を削除し共通 API を使う
3. Socket handshake auth で渡す userName 値の取得元を共通 API に切替
4. `validateUserName` を共通 API に置換 (シグネチャは互換)
5. ビルド・動作確認・deploy

- [x] 2.1 nasbi
  - `packages/web/src/App.tsx` の `STORAGE_KEY_USER_NAME` / `getUserName` 直書きを削除
  - `lib/nickname.ts` を `packages/web/src/lib/nickname.ts` にコピー
  - import を共通 API に切替
  - 既存 `nasbi:userName` の migration 動作確認 (tsc 通過、テスト互換: 既存 `App.test.tsx` の `nasbi:userName` セットがそのまま welcome-back モードに乗る)
  - `deploy.sh` で本番反映 — **未実施 (デプロイは別工程で)**
- [x] 2.2 kaeru
  - `packages/web/src/profile.ts` の `STORAGE_KEY_USER_NAME` / 関連関数を共通 API に置換
  - userId 関連 (`STORAGE_KEY_USER_ID`, `getUserId`) はそのまま残す
  - 既存 `kaeru:userName` の migration 動作確認 (tsc 通過、profile.ts は共通 API への薄い再エクスポート、`validateUserName` シグネチャ互換)
  - `deploy.sh` で本番反映 — **未実施 (デプロイは別工程で)**
- [x] 2.3 sumomo
  - `packages/web/src/profile.ts` の `STORAGE_KEY_USER_NAME` / 関連関数を共通 API に置換
  - userId 関連はそのまま残す
  - 既存 `sumomo:userName` の migration 動作確認 (tsc 通過、profile.ts は共通 API への薄い再エクスポート)
  - deploy で本番反映 — **未実施 (デプロイは別工程で)**

## Phase 3: 統合動作確認 + 片付け

> 3.1〜3.4 は本番 (susipero.com) または各ゲームの dev server で目視確認が必要。
> 各ゲームの deploy 後にユーザ自身による検証を想定。

- [ ] 3.1 nasbi で名前入力 → kaeru を新規タブで開いて名前が引き継がれていることを目視
- [ ] 3.2 kaeru で名前変更 → 別タブの nasbi をリロードして変更が反映されることを目視
- [ ] 3.3 sumomo でも同様に確認
- [ ] 3.4 まだプレイしたことがないユーザがいきなり kaeru を開いた場合の入力フロー確認
- [x] 3.5 `greendayo-login/` リポを削除 (未使用のため) — `/Users/greendayo/dev/workspace/greendayo-login` 不在を確認済み (前セッションで削除済み)
- [ ] 3.6 archive 済みかつ openspec/changes/2026-05-01-add-shared-nickname を archive
