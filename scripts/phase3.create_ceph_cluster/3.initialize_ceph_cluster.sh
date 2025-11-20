#!/bin/bash

# 100GbEネットワークでCephを初期化
# このコマンドが以下を自動実行:
# 1. クラスタFSID（UUID）を生成
# 2. /etc/ceph/ceph.conf を作成
# 3. public_network と cluster_network を設定
# 4. Monitor認証キーリングの基礎を準備

pveceph init --network 172.16.200.0/24 --cluster-network 172.16.200.0/24

# 設定確認
cat /etc/ceph/ceph.conf
