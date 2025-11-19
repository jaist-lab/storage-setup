#!/bin/bash
# ceph-config-create.sh

echo "**r760xs1で実行 (管理ノード):**"

CEPH_CONF="/etc/ceph/ceph.conf"
CLUSTER_NAME="ceph"
FSID=$(uuidgen)

cat > ${CEPH_CONF} << EOF
[global]
# クラスタ基本設定
fsid = ${FSID}
cluster = ${CLUSTER_NAME}
mon_initial_members = r760xs1,r760xs2,r760xs3,r760xs4,r760xs5
mon_host = 172.16.200.11,172.16.200.12,172.16.200.13,172.16.200.14,172.16.200.15

# 認証設定
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

# ネットワーク設定
public_network = 172.16.100.0/24
cluster_network = 172.16.200.0/24

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
# OSD特有の設定
osd_memory_target = 4294967296  # 4GB per OSD
osd_max_write_size = 512
osd_client_message_size_cap = 524288000
osd_deep_scrub_interval = 1209600  # 2週間
osd_scrub_begin_hour = 1
osd_scrub_end_hour = 7

[mgr]
# Manager Dashboard
mgr/dashboard/ssl = true
mgr/dashboard/ssl_server_port = 8443

[mds]
# Metadata Server設定
mds_cache_memory_limit = 4294967296  # 4GB
EOF

echo "Ceph configuration created: ${CEPH_CONF}"
cat ${CEPH_CONF}

# FSIDを記録
echo ${FSID} > /root/storage-setup/logs/ceph-fsid.txt
echo "FSID saved to: /root/storage-setup/logs/ceph-fsid.txt"
