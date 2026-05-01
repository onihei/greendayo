# AI 自己紹介文生成

## ADDED Requirements

### Requirement: REST エンドポイントによる Claude 呼び出し

旧 `greendayo-server` の Socket.IO `generateProfileText` イベントは MUST 廃止される。Next.js の `POST /api/profile-text` が同等機能を SHALL 提供する。

#### Scenario: 自己紹介生成リクエスト
- **WHEN** クライアントが `POST /api/profile-text` に JSON `{ nickname, born, age, job, interesting, book, movie, goal, treasure }` を送信する
- **THEN** サーバは Anthropic Messages API (`claude-haiku-4-5-20251001`) を呼び出す
- **AND** 旧サーバと同一の日本語プロンプト (「他人に興味を持ってもらえる自己紹介文…最後に幸せ自慢を加えてください」) を使用する
- **AND** `max_tokens: 2048`, `temperature: 0.9` で生成する
- **AND** 生成テキストを `{ "text": "..." }` の形で返す

#### Scenario: 入力欠損項目の扱い
- **WHEN** リクエストの一部フィールドが `null` で送信される
- **THEN** プロンプト中で「null は特にないか教えたくないとこを意味しますので無視して良い」と Claude に伝えられ、欠損は許容される

### Requirement: API キー保護

`CLAUDE_API_KEY` はサーバ環境変数 (`.env.local` / `.env.production`) からのみ読み出 SHALL される。クライアントバンドルに MUST 露出してはならない。

#### Scenario: フロントエンドバンドル
- **WHEN** Next.js のビルド成果物を検査する
- **THEN** `CLAUDE_API_KEY` の文字列が含まれない
- **AND** Anthropic SDK の呼び出しは Route Handler (Node Runtime) からのみ実行される

### Requirement: Socket.IO 廃止

`socket_io_client`, `socket.io` 依存および接続コードはフロント・バックの双方から MUST 削除される。新フロントエンドからの Socket.IO 接続は MUST 行われない。

#### Scenario: 旧 Socket 経路
- **WHEN** クライアントが `wss://susipero.com/greendayo.io/` への接続を試みる
- **THEN** サーバは Socket.IO サーバを起動していないため接続は失敗する
- **AND** どのクライアントコードもこの URL に接続しない
