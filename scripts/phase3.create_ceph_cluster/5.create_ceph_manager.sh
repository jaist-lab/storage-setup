#!/bin/bash

# 全ノードでManagerを作成
# このコマンドが以下を自動実行:
# 1. Manager認証キーリング作成
# 2. Managerデータディレクトリ準備
# 3. Managerデーモン起動

for node in r760xs{1..5}; do
    echo "Creating Manager on ${node}..."
    ssh root@${node} "pveceph mgr create"
done

# 確認
ceph mgr stat
# 期待: 1 active, 4 standby

ceph -s
# 期待: mgr: r760xs1(active, since Xs), standbys: r760xs2, r760xs3, r760xs4, r760xs5
