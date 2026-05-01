#!/usr/bin/env bash
# Next.js 版 すしぺろ デプロイスクリプト
#
# 使い方: bash deploy/deploy.sh
#
# 前提:
#   - ~/.ssh/config に Host susipero が定義済み
#   - VPS 側に /home/onihei/susipero/ ディレクトリが存在
#   - VPS 側に .env.production が配置済み (rsync で消えないよう除外している)
#   - pm2 がインストール済み (npm i -g pm2)
set -euo pipefail

REMOTE="susipero"
REMOTE_DIR="/home/onihei/susipero/"
APP_NAME="susipero"

# このスクリプトの一つ上のディレクトリ (=リポルート) で動かす
cd "$(dirname "$0")/.."

echo "=== Build ==="
npm ci
npm run build

echo "=== Pack standalone output ==="
# standalone モードの成果物だけを集めて転送する
rm -rf .deploy-staging
mkdir -p .deploy-staging
cp -R .next/standalone/. .deploy-staging/
mkdir -p .deploy-staging/.next
cp -R .next/static .deploy-staging/.next/static
cp -R public .deploy-staging/public

echo "=== Deploy ==="
rsync -avz --delete \
  --exclude='.env.production' \
  --exclude='.env.local' \
  .deploy-staging/ "$REMOTE:$REMOTE_DIR"

echo "=== Restart ==="
ssh "$REMOTE" "cd $REMOTE_DIR && (pm2 restart $APP_NAME --update-env || pm2 start server.js --name $APP_NAME --update-env) && pm2 save"

echo "=== Cleanup ==="
rm -rf .deploy-staging

echo "=== Done ==="
