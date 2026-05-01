# shared-nickname Specification

すしぺろ (susipero.com) のサブディレクトリゲーム間でニックネームを共有する規約。

## ADDED Requirements

### Requirement: Canonical Storage Key

サイト共通ニックネームは localStorage の単一キー `susipero:nickname` に保存 MUST されることで、susipero.com オリジン全体のサブディレクトリゲーム間で共有される。

#### Scenario: 共通キーで保存
- **WHEN** ユーザがゲーム内で有効なニックネーム `"すし"` を確定する
- **THEN** localStorage のキー `susipero:nickname` に値 `"すし"` が保存される

#### Scenario: 共通キーから読み取り
- **GIVEN** localStorage に `susipero:nickname = "ペロ"` が存在する
- **WHEN** いずれかのゲームが起動して現在のニックネームを取得する
- **THEN** `"ペロ"` が返される

#### Scenario: 未設定時は null
- **GIVEN** localStorage に `susipero:nickname` も legacy キーも存在しない
- **WHEN** ニックネーム取得 API を呼ぶ
- **THEN** `null` が返される

### Requirement: Validation Rules

ニックネームは以下のすべてのルールを満た MUST。
バリデータは無効値に対して具体的な日本語の理由を返 SHALL。

- 文字列型であること
- 改行 (`\n` `\r`) およびタブ (`\t`) を含まないこと
- 前後空白を trim した後、1 文字以上 20 文字以下であること

#### Scenario: 有効な値
- **WHEN** バリデータに `"  すしぺろ  "` を渡す
- **THEN** `{ ok: true, value: "すしぺろ" }` が返される

#### Scenario: 空文字
- **WHEN** バリデータに `""` または `"   "` を渡す
- **THEN** `{ ok: false, reason: "ニックネームを入力してください" }` が返される

#### Scenario: 長すぎる
- **WHEN** バリデータに 21 文字以上 (trim 後) を渡す
- **THEN** `{ ok: false, reason: "20 文字以内で入力してください" }` が返される

#### Scenario: 改行/タブ含む
- **WHEN** バリデータに改行・キャリッジリターン・タブのいずれかを含む文字列を渡す
- **THEN** `{ ok: false, reason: "改行やタブは使えません" }` が返される

### Requirement: Legacy Key Migration

共通キー `susipero:nickname` が未設定の場合、システムは旧ゲーム別キーから最初に見つかった値を共通キーへ昇格 SHALL し、旧キーは削除せず保持 MUST する。

旧キー優先順位:
1. `nasbi:userName`
2. `kaeru:userName`
3. `sumomo:userName`

#### Scenario: 旧 nasbi キーからの昇格
- **GIVEN** localStorage に `susipero:nickname` は無く、`nasbi:userName = "すし"` が存在する
- **WHEN** ニックネーム取得 API を呼ぶ
- **THEN** `susipero:nickname` に `"すし"` が書き込まれ、`"すし"` が返される

#### Scenario: 優先順位 (nasbi が kaeru より優先)
- **GIVEN** `nasbi:userName = "すし"`, `kaeru:userName = "ペロ"` の両方が存在し、共通キーは空
- **WHEN** ニックネーム取得 API を呼ぶ
- **THEN** `"すし"` が共通キーに昇格して返される

#### Scenario: 旧キーの保持
- **GIVEN** マイグレーション完了後
- **WHEN** localStorage を確認
- **THEN** 旧キー (`nasbi:userName` 等) は削除されず残っている

#### Scenario: 共通キーが既にあれば旧キーは無視
- **GIVEN** `susipero:nickname = "新しい名前"` が既に存在し、`nasbi:userName = "古い名前"` も残っている
- **WHEN** ニックネーム取得 API を呼ぶ
- **THEN** `"新しい名前"` が返される (旧キーは無視)

### Requirement: Cross-Game Synchronization

サイト共通ニックネームを変更したら、他のゲームを次回開いた時にその値が反映 SHALL され、各ゲームはニックネームの読み取りを共通 API 経由で行 MUST。

#### Scenario: nasbi → kaeru 引き継ぎ
- **GIVEN** ユーザが nasbi で `"すし"` を入力して `susipero:nickname` に保存した
- **WHEN** 同じブラウザで kaeru を開く
- **THEN** kaeru のニックネーム入力画面が初期値 `"すし"` で表示される、もしくは入力をスキップして直接プレイ画面に遷移する (各ゲームの実装に依存)

#### Scenario: kaeru で変更が他ゲームに反映
- **GIVEN** ユーザが kaeru で名前を `"ペロ"` に変更した
- **WHEN** 同じブラウザの別タブで nasbi をリロードする
- **THEN** nasbi が新しい値 `"ペロ"` を読み取って表示・利用する

### Requirement: Per-Game Identity Independence

ニックネーム共有は **userName のみ** を対象と SHALL。
各ゲームの内部 userId (`<game>:userId`) は独立に維持 MUST であり、
本仕様で touch しては NOT MUST。

#### Scenario: userId は共有されない
- **GIVEN** nasbi で生成された `nasbi:userId = "abc..."`
- **WHEN** kaeru を開く
- **THEN** `kaeru:userId` は kaeru 独自に生成・保持される (nasbi の値とは関係しない)

### Requirement: Canonical Implementation Location

共通ニックネームの正本 (canonical) 実装は greendayo の `lib/nickname.ts` に存在 SHALL し、各ゲームは同一ロジックをコピーして使用 MUST。仕様変更時は greendayo を最初に更新する。

#### Scenario: greendayo が正本
- **WHEN** 仕様 (キー名・validation・migration) を変更する必要が生じた
- **THEN** greendayo の `lib/nickname.ts` を最初に更新し、各ゲームへ展開する

### Requirement: Independence From Authentication

サイト共通ニックネームは Firebase Auth (Google ログイン) と独立 MUST。
Firebase の displayName と `susipero:nickname` の間で自動同期を行っては
NOT MUST。

#### Scenario: 未ログインでも利用可
- **GIVEN** ユーザが Firebase Auth にログインしていない
- **WHEN** ゲームでニックネームを設定する
- **THEN** `susipero:nickname` に保存され、ゲームは通常通り動作する

#### Scenario: ログイン状態が共通ニックネームに影響しない
- **GIVEN** `susipero:nickname = "すし"`
- **WHEN** ユーザが Firebase Auth にログインまたはログアウトする
- **THEN** `susipero:nickname` の値は変化しない (Firebase の displayName とは別)
