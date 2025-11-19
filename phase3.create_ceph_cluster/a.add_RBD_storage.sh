#!/bin/bash

# RBDストレージの登録
echo "**r760xs1で実行:**"

pvesm add rbd ceph-rbd \
    --pool vm-storage \
    --content images,rootdir \
    --nodes r760xs1,r760xs2,r760xs3,r760xs4,r760xs5 \
    --krbd 0

# CephFS登録 (作成した場合のみ)
# pvesm add cephfs cephfs \
#     --path /mnt/pve/cephfs \
#     --content vztmpl,backup,iso,snippets \
#     --nodes r760xs1,r760xs2,r760xs3,r760xs4,r760xs5 \
#     --monhost 172.16.200.11,172.16.200.12,172.16.200.13,172.16.200.14,172.16.200.15

# ストレージ状態確認
pvesm status

# Ceph状態確認
ceph -s
ceph df
ceph osd tree

echo "**Proxmox Web GUIで確認:**"
echo "1. Datacenter → Storage"
echo "2. `ceph-rbd` ストレージが表示されることを確認"
echo "3. 各ノードで使用可能であることを確認"
