#!/bin/bash
# 7.create_ceph_osd.sh

# 使用可能なNVMeデバイス確認
lsblk -d | grep nvme

# 想定:
# r760xs1: nvme1n1-nvme3n1 (3台、nvme0n1はローカルストレージ用)
# r760xs2-5: nvme1n1-nvme4n1 (4台、nvme0n1はローカルストレージ用)

# r760xs1: 3台のOSD作成
for dev in nvme{1..3}n1; do
    echo "Creating OSD on /dev/${dev}..."
    # このコマンドが以下を自動実行:
    # 1. デバイスのワイプ（wipefs, sgdisk --zap-all）
    # 2. LVM PV/VG/LV作成
    # 3. OSD認証キーリング作成
    # 4. BlueStoreデータベース初期化
    # 5. OSDデーモン起動
    pveceph osd create /dev/${dev}
    sleep 5
done

# 確認
ceph osd tree

# r760xs2で実行
ssh root@r760xs2 << 'EOF'
for dev in nvme{1..4}n1; do
    echo "Creating OSD on /dev/${dev}..."
    pveceph osd create /dev/${dev}
    sleep 5
done
EOF

# r760xs3で実行
ssh root@r760xs3 << 'EOF'
for dev in nvme{1..4}n1; do
    echo "Creating OSD on /dev/${dev}..."
    pveceph osd create /dev/${dev}
    sleep 5
done
EOF

# r760xs4で実行
ssh root@r760xs4 << 'EOF'
for dev in nvme{1..4}n1; do
    echo "Creating OSD on /dev/${dev}..."
    pveceph osd create /dev/${dev}
    sleep 5
done
EOF

# r760xs5で実行
ssh root@r760xs5 << 'EOF'
for dev in nvme{1..4}n1; do
    echo "Creating OSD on /dev/${dev}..."
    pveceph osd create /dev/${dev}
    sleep 5
done
EOF

# OSD状態確認
ceph osd tree
# 期待: 19 OSDs (r760xs1=3, r760xs2-5=4×4=16)

ceph osd stat
# 期待: 19 osds: 19 up, 19 in

ceph -s
# 期待: osd: 19 osds: 19 up, 19 in; 全PGがactive+clean
