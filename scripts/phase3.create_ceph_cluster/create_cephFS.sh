#!/bin/bash

echo "**各ノードでMDS作成:**"

# 全ノードでMDSを作成
# このコマンドが以下を自動実行:
# 1. MDS認証キーリング作成
# 2. MDSデータディレクトリ準備
# 3. MDSデーモン起動
for node in r760xs{1..5}; do
    echo "Creating MDS on ${node}..."
    ssh root@${node} "pveceph mds create"
done

# 確認
ceph mds stat
# 期待: 1 up:standby, 4 up:standby

echo "**CephFS作成:**"

# CephFS作成（自動的にProxmoxストレージも作成）
# このコマンドが以下を自動実行:
# 1. ceph osd pool create cephfs-metadata（メタデータプール）
# 2. ceph osd pool create cephfs-data（データプール）
# 3. ceph fs new cephfs-storage（ファイルシステム作成）
# 4. pvesm add cephfs（Proxmoxストレージ登録）
pveceph fs create \
    --name cephfs-storage \
    --pg_num 128 \
    --add-storage

# contentを設定
pvesm set cephfs-storage --content vztmpl,backup,iso

# 確認
ceph fs status cephfs-storage
# 期待: 1 up:active, 4 up:standby

pvesm status | grep cephfs-storage
# 期待: cephfs-storage が active
