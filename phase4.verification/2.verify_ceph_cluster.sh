#!/bin/bash
# verify-ceph-cluster.sh

echo "**r760xs1で実行:**"
echo " "
echo "========================================="
echo "  Ceph Cluster Verification"
echo "========================================="
echo ""

# クラスタ健全性
echo "--- Cluster Health ---"
ceph -s
echo ""

# Monitor状態
echo "--- Monitor Status ---"
ceph mon stat
ceph quorum_status --format json-pretty | jq '.quorum_names'
echo ""

# Manager状態
echo "--- Manager Status ---"
ceph mgr stat
echo ""

# OSD状態
echo "--- OSD Status ---"
ceph osd stat
ceph osd tree
echo ""
ceph osd df tree
echo ""

# Pool状態
echo "--- Pool Status ---"
ceph osd pool ls detail
echo ""
ceph df
echo ""

# PG状態
echo "--- PG Status ---"
ceph pg stat
ceph pg dump_stuck 2>/dev/null || echo "No stuck PGs"
echo ""

# パフォーマンス
echo "--- Performance ---"
ceph osd perf
echo ""

# ネットワーク疎通確認
echo "--- Network Connectivity ---"
for i in {11..15}; do
    echo -n "172.16.200.$i: "
    ping -c 1 -W 1 172.16.200.$i > /dev/null && echo "OK" || echo "FAIL"
done
echo ""

# 期待される結果
echo "========================================="
echo "  Expected Results:"
echo "========================================="
echo "✓ Health: HEALTH_OK"
echo "✓ Monitors: 5/5 in quorum"
echo "✓ Managers: 1 active, 4 standby"
echo "✓ OSDs: 24 up, 24 in"
echo "✓ PGs: all active+clean"
echo "✓ Network: all nodes reachable"
echo "========================================="
