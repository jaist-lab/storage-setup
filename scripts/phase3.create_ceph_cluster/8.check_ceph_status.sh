#!/bin/bash

# 全体ステータス
ceph -s

# OSD詳細
ceph osd tree
# 期待: r760xs1に3台、r760xs2-5に各4台のOSD

# プール確認
ceph df
# 期待: vm-storage, cephfs-metadata, cephfs-data が表示

# ストレージ確認（Proxmox）
pvesm status
# 期待: vm-storage と cephfs-storage が active

# ネットワーク確認
ceph config dump | grep -E "public_network|cluster_network"
# 期待: public_network = 172.16.200.0/24
#       cluster_network = 172.16.200.0/24

# Monitor アドレス確認
ceph mon dump | grep addr
# 期待: 172.16.200.11-15 のアドレスが表示
