#!/bin/bash
# ceph-perf-test.sh

echo "**r760xs1で実行:**"
echo " "
echo "=== Ceph Storage Performance Test ==="
echo ""

# RADOSベンチマーク (書き込み)
echo "--- RADOS Benchmark: Write (10 seconds) ---"
rados bench -p vm-storage 10 write --no-cleanup 2>&1 | tee /root/storage-setup/logs/ceph-bench-write.log
echo ""

# RADOSベンチマーク (シーケンシャル読み込み)
echo "--- RADOS Benchmark: Sequential Read (10 seconds) ---"
rados bench -p vm-storage 10 seq 2>&1 | tee /root/storage-setup/logs/ceph-bench-read.log
echo ""

# RADOSベンチマーク (ランダム読み込み)
echo "--- RADOS Benchmark: Random Read (10 seconds) ---"
rados bench -p vm-storage 10 rand 2>&1 | tee /root/storage-setup/logs/ceph-bench-rand.log
echo ""

# クリーンアップ
rados -p vm-storage cleanup

echo "Performance test completed"
echo "Logs saved in: /root/storage-setup/logs/"
