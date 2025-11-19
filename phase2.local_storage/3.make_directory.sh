#!/bin/bash

echo "**全ノードで実行:**"

# ディレクトリ構造作成
MOUNT_POINT="/var/lib/local-nvme"

mkdir -p ${MOUNT_POINT}/{kubernetes/{etcd,local-volumes},logs,temp}

# Proxmoxが自動で作成するディレクトリ (後でProxmoxストレージ追加時に作成される)
# mkdir -p ${MOUNT_POINT}/images/{template,private}

# 権限設定
chmod 755 ${MOUNT_POINT}
chmod 750 ${MOUNT_POINT}/kubernetes
chmod 750 ${MOUNT_POINT}/kubernetes/etcd
chmod 755 ${MOUNT_POINT}/kubernetes/local-volumes
chmod 1777 ${MOUNT_POINT}/temp  # sticky bit

# 確認
tree -L 3 ${MOUNT_POINT} || ls -laR ${MOUNT_POINT}
