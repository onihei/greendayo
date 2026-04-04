# CLAUDE.md

## プロジェクト概要

すしぺろ (susipero.com) - Flutter Web ソーシャルプラットフォーム
- フロントエンド: Flutter Web (Riverpod + Hooks)
- バックエンド: Node.js Express + Socket.IO (`greendayo-server/`)
- データベース: Cloud Firestore + SQLite (サーバー側)
- 認証: Firebase Auth

## 設計方針

### ルーティング: Navigator 2.0 Reactive Navigation

GoRouterは使わない。`RouterDelegate` + Riverpodの状態でスタックをリアクティブに構築する。

- 認証状態 (`userProvider`) と選択中ユーザー (`selectedUserIdProvider`) が画面スタックを決定する
- ルーターに画面遷移を命令するのではなく、状態の変化に応じてスタックが宣言的に構築される
- `MaterialApp.router` は1つだけ（`MyApp`）。認証前/後の分岐もRouterDelegate内で行う

```
RouterDelegate
  ├─ user==null → [TopPage]
  ├─ user!=null, selectedUserId==null → [HomePage]
  └─ user!=null, selectedUserId!=null → [HomePage, ProfilePage]
```

## ビルド・デプロイ

```bash
flutter analyze        # 静的解析
flutter build web      # Webビルド
bash deploy.sh         # デプロイ
```

## サーバー

```bash
cd greendayo-server
npm install
node index.js          # ポート10005
```
