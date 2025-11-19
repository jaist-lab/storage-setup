#!/bin/bash
# ceph-config-create.sh (シングルネットワーク - 初期構築用)

echo "**r760xs1で実行 (管理ノード):**"

echo "=== Creating Ceph Configuration (Initial) ==="

# /etc/cephディレクトリ作成
mkdir -p /etc/ceph
chown ceph:ceph /etc/ceph 2>/dev/null || chown root:root /etc/ceph

CEPH_CONF="/etc/ceph/ceph.conf"
CLUSTER_NAME="ceph"
FSID=$(uuidgen)

cat > ${CEPH_CONF} << EOF
[global]
fsid = ${FSID}
cluster = ${CLUSTER_NAME}

# ★★★ 初期構築時は最初のノードのみ ★★★
mon_initial_members = r760xs1
mon_host = 172.16.200.11

# 認証設定
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

# ネットワーク設定（シングルネットワーク: 全て100GbE）
public_network = 172.16.200.0/24
cluster_network = 172.16.200.0/24

# メッセージングプロトコル
ms_bind_msgr1 = true
ms_bind_msgr2 = true

# Monitor設定
mon_allow_pool_delete = false
mon_max_pg_per_osd = 300

# OSD設定
osd_pool_default_size = 3
osd_pool_default_min_size = 2
osd_pool_default_pg_num = 128
osd_pool_default_pgp_num = 128
osd_crush_chooseleaf_type = 1

# BlueStore設定
osd_objectstore = bluestore
bluestore_block_db_size = 0
bluestore_block_wal_size = 0

# Performance Tuning
osd_op_threads = 8
osd_disk_threads = 4
osd_recovery_max_active = 3
osd_max_backfills = 1

# Journal/WAL設定 (NVMe最適化)
osd_journal_size = 10240
filestore_xattr_use_omap = true

# Network設定 (100GbE最適化)
ms_bind_port_min = 6800
ms_bind_port_max = 7300
ms_async_op_threads = 5
ms_dispatch_throttle_bytes = 1048576000

# Client設定
rbd_cache = true
rbd_cache_size = 67108864
rbd_cache_max_dirty = 50331648
rbd_cache_target_dirty = 33554432

[mon]
mon_data_avail_warn = 15
mon_data_avail_crit = 10

[osd]
osd_memory_target = 4294967296
osd_max_write_size = 512
osd_client_message_size_cap = 524288000
osd_deep_scrub_interval = 1209600
osd_scrub_begin_hour = 1
osd_scrub_end_hour = 7

[mgr]
mgr/dashboard/ssl = true
mgr/dashboard/ssl_server_port = 8443

[mds]
mds_cache_memory_limit = 4294967296
EOF

echo "Ceph configuration created: ${CEPH_CONF}"
echo ""
echo "Configuration contents:"
cat ${CEPH_CONF}

# FSIDを記録
mkdir -p /root/storage-setup/logs
echo ${FSID} > /root/storage-setup/logs/ceph-fsid.txt
echo ""
echo "FSID saved to: /root/storage-setup/logs/ceph-fsid.txt"
echo "FSID: ${FSID}"

# Proxmox共有ディレクトリへコピー
echo ""
echo "Copying to Proxmox shared storage..."
cp /etc/ceph/ceph.conf /etc/pve/ceph.conf

# シンボリックリンク作成
echo "Creating symbolic link..."
rm -f /etc/ceph/ceph.conf
ln -s /etc/pve/ceph.conf /etc/ceph/ceph.conf

# 確認
echo ""
echo "Verifying symbolic link..."
ls -l /etc/ceph/ceph.conf

echo ""
echo "=== Configuration setup completed ==="
