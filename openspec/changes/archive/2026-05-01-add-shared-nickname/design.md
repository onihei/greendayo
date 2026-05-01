# Design: Shared Nickname Across Games

## Context

susipero.com には 3 つのゲーム (nasbi / kaeru / sumomo) がサブディレクトリで
ホストされている。すべて同一オリジンのため localStorage は仕様上共有可能だが、
現在キー名がゲームごとに分かれているため共有されていない。

ニックネーム関連ロジック (キー読書 + バリデーション + nanoid userId 生成) は
kaeru と sumomo に **完全に同一の `profile.ts`** がコピペで存在し、nasbi は
App.tsx に直書きされている。実質既に三重実装の状態。

## Decisions

### D1. ストレージは localStorage (Cookie ではない)

| 観点 | localStorage | Cookie |
|------|-------------|--------|
| 同一オリジンでのパス共有 | ✅ | ✅ |
| 既存ゲームの実装 | 既に使用 | 全部書き直し |
| SSR で読める | ❌ | ✅ |
| Socket.IO handshake | auth payload で渡す | header 自動送信 |

カジュアル路線で SSR 「おかえり◯◯さん」表示は要件に無く、Socket.IO の
handshake は既に auth payload で値を渡す実装になっているため、Cookie の
利点が要件に効かない。**移行コストの最も小さい localStorage を選ぶ**。

### D2. ロジックの所在は greendayo (susipero.com 本体)

候補:
- (a) 独立リポ `greendayo-login/` として TS パッケージ化 → tarball/npm 配布
- (b) **greendayo の `lib/` に置き、各ゲームへコピー** ← 採用
- (c) ランタイム JS module を greendayo が配信、各ゲームが import

判断:
- (a) は 30 行のコードに対してパッケージ・配布の重みが過剰。tarball 更新の
  たびに 3 ゲーム分の `pnpm add` が要るのは見合わない
- (c) は vite/Next の bundling と相性が悪く dev/build フローが複雑化
- (b) は drift リスクはあるが 30 行なので目視で十分管理できる。
  greendayo は susipero.com そのもので「サイト共通仕様の住処」として最適

`greendayo-login/` リポは未使用のまま削除する。

### D3. userId は共通化しない

カジュアル路線でスコア保存もないため、ゲーム横断のユーザ識別連続性は
今回必要ない。各ゲームの `<game>:userId` は socket handshake / 同タブ
二重ログイン検出 (kaeru) に内部利用されているため、触らない方が安全。

将来クロスゲームのハイスコア等が必要になった時点で別 change として共通化を
検討する。今回は **userName だけ共有・userId は据え置き**。

### D4. 各ゲームの入力 UI は据え置き

nasbi (luxury テイスト) / kaeru (蛙テイスト) / sumomo は各々既存の
`NicknamePage` 系コンポーネントを持つ。見た目の統一は本 change のスコープ外。
**コアロジック (キー名・validation・migration) のみを揃える**。

### D5. Firebase Auth とは独立

greendayo の Firebase Auth (Google ログイン) と本ニックネームは別軸の概念。

- Firebase ログインしてもニックネームを上書きしない
- Firebase ログアウトしてもニックネームを消さない
- ニックネームはあくまで「カジュアル表示名」として独立

将来連携が必要になったら別 change で扱う。

## Migration Strategy

初回ロード時 (= `susipero:nickname` が `null`) に以下を順に拾う:

1. `nasbi:userName`
2. `kaeru:userName`
3. `sumomo:userName`

最初に見つかった値を `susipero:nickname` に書き込む。**旧キーは削除しない**
(ロールバック余地と「他ゲームで使ってた名前を後から拾う」可能性を残すため)。

複数のゲームで違うニックネームを使い分けていたユーザは、最初に拾った値で
固定される。これは仕様として受け入れる。明示的にニックネームを変更する
ときは各ゲームの既存変更 UI から行う (= `susipero:nickname` を上書き)。

## Distribution & Drift Management

各ゲームの `lib/nickname.ts` は greendayo の正本を **手でコピー** する。

- 30 行の小ささなので drift しても目視ですぐわかる
- canonical 実装は greendayo の `lib/nickname.ts`
- 規約 (キー名・validation 規則) は greendayo の `CLAUDE.md` / `AGENTS.md` に明記

将来 drift が問題化したら以下を検討:
- gitignore された生成スクリプトで cp 自動化
- pnpm workspace 化
- 真の npm パッケージ化

ただしカジュアル個人プロジェクトでは現時点で過剰。

## Non-decisions (記録)

- 認証統合 (Firebase Auth) は別軸の機能であり本 change で関与しない (D5)
- パッケージ配布手段 (npm/tarball) は採用しない (D2)
- userId 共通化は今回見送り (D3)
- UI 統一は今回見送り (D4)
