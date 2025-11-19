#!/bin/bash
# 2.local-nvme-mount.sh

LOCAL_DEVICE="/dev/nvme0n1"
PARTITION="${LOCAL_DEVICE}p1"
MOUNT_POINT="/var/lib/local-nvme"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /root/storage-setup/logs/local-nvme-setup.log
}

log_message "===== Configuring mount point ====="

# マウントポイント作成
if [ ! -d "${MOUNT_POINT}" ]; then
    log_message "Creating mount point: ${MOUNT_POINT}"
    mkdir -p ${MOUNT_POINT}
fi

# UUID取得
UUID=$(blkid -s UUID -o value ${PARTITION})
log_message "Partition UUID: ${UUID}"

if [ -z "${UUID}" ]; then
    log_message "ERROR: Could not get UUID for ${PARTITION}"
    exit 1
fi

# fstab エントリ作成
FSTAB_ENTRY="UUID=${UUID}  ${MOUNT_POINT}  ext4  defaults,noatime,nodiratime,discard  0  2"

# 既存エントリのチェック
if grep -q "${MOUNT_POINT}" /etc/fstab; then
    log_message "WARNING: Mount point already exists in /etc/fstab"
    log_message "Existing entry:"
    grep "${MOUNT_POINT}" /etc/fstab | tee -a /root/storage-setup/logs/local-nvme-setup.log
    
    read -p "Replace existing entry? (yes/no): " replace
    if [ "$replace" = "yes" ]; then
        # 既存エントリを削除
        sed -i "\|${MOUNT_POINT}|d" /etc/fstab
    else
        log_message "Keeping existing entry"
        exit 0
    fi
fi

# fstab に追加
log_message "Adding entry to /etc/fstab:"
echo "${FSTAB_ENTRY}" >> /etc/fstab
log_message "${FSTAB_ENTRY}"

# fstab 検証
log_message "Validating fstab..."
if findmnt --fstab --target ${MOUNT_POINT} &> /dev/null; then
    log_message "fstab entry is valid"
else
    log_message "ERROR: fstab entry validation failed"
    exit 1
fi

# マウント
log_message "Mounting ${PARTITION} to ${MOUNT_POINT}..."
mount ${MOUNT_POINT}

if mountpoint -q ${MOUNT_POINT}; then
    log_message "Successfully mounted"
    df -h ${MOUNT_POINT} | tee -a /root/storage-setup/logs/local-nvme-setup.log
else
    log_message "ERROR: Mount failed"
    exit 1
fi

log_message "===== Mount configuration completed ====="
