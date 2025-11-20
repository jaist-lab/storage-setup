#!/bin/bash

# r760xs1でMonitorを作成
# このコマンドが以下を自動実行:
# 1. Monitor認証キーリング作成（ceph-authtool）
# 2. Monitorマップ（monmap）作成（monmaptool）
# 3. Monitorデータベース初期化（ceph-mon --mkfs）
# 4. Monitorデーモン起動（systemctl start ceph-mon@r760xs1）
pveceph mon create

# 他のノードでもMonitorを作成
ssh root@r760xs2 "pveceph mon create"
ssh root@r760xs3 "pveceph mon create"
ssh root@r760xs4 "pveceph mon create"
ssh root@r760xs5 "pveceph mon create"

# 確認
ceph mon stat
# 期待: 5 mons at 172.16.200.11,172.16.200.12,172.16.200.13,172.16.200.14,172.16.200.15

ceph -s
# 期待: mon: 5 daemons, quorum r760xs1,r760xs2,r760xs3,r760xs4,r760xs5
