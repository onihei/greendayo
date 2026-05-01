# 本番切替 (Phase 4) 手順

Flutter 版 → Next.js 版へ susipero.com を一気に差し替える手順。
所要時間 ~30分。ロールバックは nginx 設定戻し + Flutter 旧プロセス再起動で完結する。

## 0. ローカル準備 (事前)

- [x] `cd nextjs && npm run build` が成功する
- [x] `cd nextjs && npm run dev` で本番 Firestore に接続して全画面動作確認

## 1. VPS 事前準備 (Phase 0)

```bash
# Node を最新 LTS に
nvm install --lts && nvm alias default 'lts/*'
node -v   # v22 系を確認

# pm2 を最新化
npm i -g pm2@latest
pm2 update

# アップロード保管ディレクトリ
sudo mkdir -p /var/lib/susipero/uploads
sudo chown -R onihei:onihei /var/lib/susipero/uploads

# 既存 uploads を移送 (旧サーバを止めずに mv で OK)
sudo mv /home/onihei/workspace/greendayo/greendayo-server/uploads/* /var/lib/susipero/uploads/ 2>/dev/null || true

# 旧 nginx 設定バックアップ
sudo cp /etc/nginx/sites-available/susipero.com /etc/nginx/sites-available/susipero.com.flutter.bak

# Next.js 配置先を作成
mkdir -p /home/onihei/susipero
```

## 2. .env.production を配置 (一度だけ)

VPS 上で `/home/onihei/susipero/.env.production` を作成:

```env
NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyB5a6p7YZhAu-TK0SzhUY7KPd_DgLxVEdI
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=greendao-a5344.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=greendao-a5344
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=greendao-a5344.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=145740451737
NEXT_PUBLIC_FIREBASE_APP_ID=1:145740451737:web:a339176dba0be1a45c0d08
NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID=G-Y2QRTBDCRJ

CLAUDE_API_KEY=sk-ant-...本番キー...

SUSIPERO_UPLOADS_DIR=/var/lib/susipero/uploads
```

## 3. ローカルからデプロイ

```bash
bash nextjs/deploy/deploy.sh
```

これで:
- `next build` → `.next/standalone/` 生成
- standalone + `.next/static` + `public` を rsync
- `pm2 restart susipero || pm2 start server.js --name susipero` で起動

VPS 上で確認:
```bash
ssh susipero
pm2 status susipero
curl -I http://127.0.0.1:3000/      # → 200
curl http://127.0.0.1:3000/api/upload -X POST  # → 400 (file required) なら API 動作中
```

## 4. nginx 切替

```bash
# 新設定をアップロード
scp nextjs/deploy/susipero.com.conf susipero:/tmp/susipero.com.conf
ssh susipero
sudo mv /tmp/susipero.com.conf /etc/nginx/sites-available/susipero.com
sudo nginx -t                          # 構文OK確認
sudo systemctl reload nginx           # ★ ここで本番が Next.js 版になる
```

## 5. 本番動作確認チェックリスト

ブラウザで `https://susipero.com/` を開いて以下を確認:

- [ ] 未ログインで掲示板が表示される
- [ ] 既存記事の写真が `/storage/...` 経由で 200 (Network タブで確認)
- [ ] Google ログインができる
- [ ] 新規投稿 (テキスト) → ドラッグ → 表示される
- [ ] 新規投稿 (画像) → アップロード → ファイルが `/var/lib/susipero/uploads/bbs/photo/` に存在
- [ ] 画像投稿の削除でファイルも消える
- [ ] `/messenger` で会話一覧
- [ ] トーク画面でリアルタイム新着が届く
- [ ] `/profile/{自分のuid}` で編集 → AI 自己紹介が生成される
- [ ] プロフィール写真を変更 → 即時反映
- [ ] `/games` から外部ゲームに飛べる
- [ ] ボトムナビ・ドロワー動作

## 6. 異常時のロールバック

問題発生時は **15秒で旧 Flutter 版に戻す** ことができる:

```bash
ssh susipero
# 1. nginx を旧設定に戻す
sudo cp /etc/nginx/sites-available/susipero.com.flutter.bak /etc/nginx/sites-available/susipero.com
sudo nginx -t && sudo systemctl reload nginx

# 2. 旧 greendayo-server を再起動 (もし既に止めていた場合)
cd /home/onihei/workspace/greendayo/greendayo-server
pm2 restart greendayo || pm2 start index.js --name greendayo

# 3. (任意) Next.js プロセスを停止
pm2 stop susipero
```

これで `https://susipero.com/` は Flutter 版と旧 `/storage/*` (= 旧 server 経由) の組み合わせに戻る。
`/var/lib/susipero/uploads/` は両バージョン共通で書き込まれているのでデータ整合性は保たれている。

## 7. 切替成功後 (1〜2 週間運用後)

- [ ] 旧 `greendayo-server` プロセスを完全停止: `pm2 stop greendayo && pm2 delete greendayo && pm2 save`
- [ ] 旧 Flutter 配信先 (`/var/www/`) と `/home/onihei/workspace/greendayo/greendayo-server/` を削除
- [ ] 旧 nginx バックアップ (`susipero.com.flutter.bak`) を削除
- [ ] リポジトリのクリーンアップ (Phase 5 へ)
