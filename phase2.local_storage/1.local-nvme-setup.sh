#!/bin/bash
# 1.local-nvme-setup.sh

# 設定変数 (環境に応じて変更)
LOCAL_DEVICE="/dev/nvme0n1"
MOUNT_POINT="/var/lib/local-nvme"
FS_LABEL="local-nvme-$(hostname -s)"
PROXMOX_STORAGE_ID="local-nvme"

# ログ関数
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /root/storage-setup/logs/local-nvme-setup.log
}

log_message "===== Local NVMe Storage Setup Started ====="
log_message "Node: $(hostname)"
log_message "Device: ${LOCAL_DEVICE}"

# デバイス存在確認
if [ ! -b "${LOCAL_DEVICE}" ]; then
    log_message "ERROR: Device ${LOCAL_DEVICE} not found!"
    exit 1
fi

# デバイス情報表示
log_message "Device information:"
lsblk ${LOCAL_DEVICE} | tee -a /root/storage-setup/logs/local-nvme-setup.log
smartctl -i ${LOCAL_DEVICE} | tee -a /root/storage-setup/logs/local-nvme-setup.log

# 確認プロンプト
echo ""
echo "⚠️  WARNING: This will erase all data on ${LOCAL_DEVICE}"
echo "Device: ${LOCAL_DEVICE}"
echo "Size: $(lsblk -dno SIZE ${LOCAL_DEVICE})"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    log_message "Operation cancelled by user"
    exit 0
fi

# 既存のファイルシステムシグネチャを削除
log_message "Wiping existing filesystem signatures..."
wipefs -a ${LOCAL_DEVICE}

# パーティションテーブルを削除
log_message "Removing existing partition table..."
sgdisk --zap-all ${LOCAL_DEVICE}

# 新しいGPTパーティションテーブルを作成
log_message "Creating new GPT partition table..."
parted -s ${LOCAL_DEVICE} mklabel gpt

# パーティション作成 (全容量使用)
log_message "Creating partition..."
parted -s ${LOCAL_DEVICE} mkpart primary ext4 1MiB 100%

# パーティション情報表示
log_message "Partition table:"
parted ${LOCAL_DEVICE} print | tee -a /root/storage-setup/logs/local-nvme-setup.log

# カーネルにパーティション情報を再読み込み
partprobe ${LOCAL_DEVICE}
sleep 2

# パーティションデバイス名
PARTITION="${LOCAL_DEVICE}p1"

if [ ! -b "${PARTITION}" ]; then
    log_message "ERROR: Partition ${PARTITION} not found!"
    exit 1
fi

log_message "Partition created: ${PARTITION}"

# ファイルシステム作成
log_message "Creating ext4 filesystem with label ${FS_LABEL}..."
mkfs.ext4 -L "${FS_LABEL}" -m 1 -O ^has_journal ${PARTITION}

# ジャーナルを無効化してパフォーマンス向上 (etcd推奨)
# 注: 電源断時のデータ整合性は低下するが、etcdは独自に整合性を保証
tune2fs -O ^has_journal ${PARTITION}

# ファイルシステム情報表示
log_message "Filesystem information:"
tune2fs -l ${PARTITION} | grep -E "Filesystem|Block size|Block count|Reserved" | tee -a /root/storage-setup/logs/local-nvme-setup.log

log_message "===== Filesystem creation completed ====="
