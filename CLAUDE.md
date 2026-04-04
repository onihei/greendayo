# CLAUDE.md

## プロジェクト概要

すしぺろ (susipero.com) - Flutter Web ソーシャルプラットフォーム
- フロントエンド: Flutter Web (Riverpod + Hooks)
- バックエンド: Node.js Express + Socket.IO (`greendayo-server/`)
- データベース: Cloud Firestore + SQLite (サーバー側)
- 認証: Firebase Auth

## ディレクトリ構造: feature-first

```
lib/
├── main.dart
├── app/                          ← ルーター・テーマ・ナビゲーション
│   ├── my_app.dart               ← MaterialApp.router + RouterDelegate
│   └── navigation_item_widget.dart
├── features/                     ← 機能ごとにまとめる
│   ├── auth/                     ← 認証
│   │   ├── user_provider.dart
│   │   └── login_dialog.dart
│   ├── bbs/                      ← 掲示板
│   │   ├── article.dart          ← モデル（プレーンDart）
│   │   ├── article_repository.dart
│   │   ├── article_providers.dart
│   │   ├── bbs_page.dart
│   │   ├── bbs_board.dart
│   │   ├── bbs_form.dart
│   │   └── bbs_controller.dart
│   ├── messenger/                ← メッセンジャー
│   │   ├── talk.dart / session.dart  ← モデル
│   │   ├── *_repository.dart
│   │   ├── *_providers.dart
│   │   ├── talk_use_case.dart    ← 複数Repoの協調はUseCaseに
│   │   ├── backend_socket.dart
│   │   ├── messenger_page.dart
│   │   └── talk_session_widget.dart
│   ├── profile/                  ← プロフィール
│   │   ├── profile.dart          ← モデル
│   │   ├── profile_repository.dart
│   │   ├── profile_providers.dart
│   │   ├── profile_page.dart
│   │   ├── edit_my_profile_page.dart
│   │   └── talk_session_page.dart
│   ├── home/                     ← ホーム（タブコンテナ）
│   │   └── home_page.dart
│   └── top/                      ← 未認証トップ
│       └── top_page.dart
└── shared/                       ← 共通部品
    ├── ui/                       ← 共通Widget・シェーダー
    ├── hooks/
    ├── utils/
    ├── web/                      ← conditional import
    └── config.dart
```

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

### モデル

- モデルはプレーンDart（Firestore非依存）
- `fromJson` / `toJson` のみ持つ
- Firestoreの `Timestamp` 変換はRepository側の `withConverter` で行う

### UseCase

- 常にUseCaseを挟むのではなく、必要なときだけ作る
- 単純なCRUD → Repositoryを直接使う
- 複数Repoの協調・バリデーション → UseCaseに抽出する

## ビルド・デプロイ

```bash
flutter analyze        # 静的解析
flutter build web      # Webビルド
bash deploy.sh         # デプロイ
dart run build_runner build --delete-conflicting-outputs  # コード生成
```

## サーバー

```bash
cd greendayo-server
npm install
node index.js          # ポート10005
```
