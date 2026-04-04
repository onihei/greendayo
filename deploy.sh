#!/usr/bin/env bash
set -euo pipefail

REMOTE="susipero"
REMOTE_WEB="/var/www/"
REMOTE_SERVER="/home/onihei/workspace/greendayo/greendayo-server/"

echo "=== Build ==="
flutter build web --wasm

echo "=== Deploy Web ==="
rsync -avz --delete \
  --exclude='kinoko.apk' \
  --exclude='.well-known' \
  build/web/ "$REMOTE:$REMOTE_WEB"

echo "=== Deploy Server ==="
rsync -avz --delete \
  --exclude='node_modules' \
  --exclude='uploads' \
  greendayo-server/ "$REMOTE:$REMOTE_SERVER"

echo "=== Install dependencies ==="
ssh "$REMOTE" "cd $REMOTE_SERVER && npm install --production"

echo "=== Restart pm2 ==="
ssh "$REMOTE" 'pm2 restart greendayo'

echo "=== Done ==="
