#!/bin/bash
# 2.local_nvme_storage.sh

echo "===  local-nvme storage on all nodes ==="

# 1. 既存ストレージ削除
echo "Removing existing storage configuration..."
pvesm remove local-nvme

# 2. 全ノードでディレクトリ準備
echo ""
echo "Preparing directories on all nodes..."
for node in r760xs{1..5}; do
    echo "--- ${node} ---"
    ssh ${node} << 'EOF'
# imagesディレクトリ作成
mkdir -p /var/lib/local-nvme/images/{template,private}
chmod 755 /var/lib/local-nvme/images

# 確認
if [ -d /var/lib/local-nvme/images ]; then
    echo "✓ images directory exists"
    ls -la /var/lib/local-nvme/ | grep images
else
    echo "✗ Failed to create images directory"
    exit 1
fi
EOF
done

# 3. ストレージ登録（全ノードを一度に指定）
echo ""
echo "Registering storage with all nodes..."
pvesm add dir local-nvme \
    --path /var/lib/local-nvme/images \
    --content vztmpl,backup,iso,rootdir,images \
    --nodes r760xs1,r760xs2,r760xs3,r760xs4,r760xs5 \
    --prune-backups keep-last=3 \
    --shared 0

# 4. 設定確認
echo ""
echo "=== Storage Configuration ==="
cat /etc/pve/storage.cfg | grep -A 7 local-nvme

# 5. 全ノードでステータス確認
echo ""
echo "=== Storage Status on All Nodes ==="
for node in r760xs{1..5}; do
    echo "--- ${node} ---"
    ssh ${node} "pvesm status | grep local-nvme"
done

echo ""
echo "===  completed ==="
