#!/bin/bash

# RADOSベンチマーク（10秒書き込み）
rados bench -p vm-storage 10 write --no-cleanup

# 期待結果（100GbE, NVMe, Replica 3）:
# Bandwidth: 1,000-3,000 MB/s
# Average IOPS: 250-750
# Average Latency: 40-120 ms

# シーケンシャル読み込み
rados bench -p vm-storage 10 seq

# クリーンアップ
rados -p vm-storage cleanup
