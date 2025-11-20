i#!/bin/bash

# VM用プール作成（自動的にProxmoxストレージも作成）
# このコマンドが以下を自動実行:
# 1. ceph osd pool create（プール作成）
# 2. ceph osd pool set（レプリカ数などの設定）
# 3. rbd pool init（RBDプール初期化）
# 4. pvesm add rbd（Proxmoxストレージ登録）
pveceph pool create vm-storage \
    --size 3 \
    --min_size 2 \
    --pg_autoscale_mode on \
    --target_size_ratio 0.8 \
    --application rbd \
    --add_storages 1

# 確認
ceph osd pool ls detail
# 期待: vm-storage が表示される

pvesm status | grep vm-storage
# 期待: vm-storage が active
