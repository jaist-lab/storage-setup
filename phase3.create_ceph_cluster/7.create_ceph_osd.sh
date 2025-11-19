#!/bin/bash
# ceph-osd-create.sh

echo "**全ノードで実行:**"

HOSTNAME=$(hostname -s)

echo "=== Creating OSDs on ${HOSTNAME} ==="

# r760xs1: nvme1n1-nvme4n1 (4台)
# r760xs2-5: nvme1n1-nvme5n1 (5台)

if [ "${HOSTNAME}" = "r760xs1" ]; then
    OSD_DEVICES="/dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1 /dev/nvme4n1"
else
    OSD_DEVICES="/dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1 /dev/nvme4n1 /dev/nvme5n1"
fi

for device in ${OSD_DEVICES}; do
    if [ ! -b "${device}" ]; then
        echo "WARNING: Device ${device} not found, skipping..."
        continue
    fi
    
    echo ""
    echo "--- Creating OSD on ${device} ---"
    
    # デバイス情報表示
    lsblk ${device}
    
    # デバイスのクリーンアップ
    echo "Wiping device ${device}..."
    wipefs -a ${device}
    sgdisk --zap-all ${device}
    
    # OSD作成
    echo "Creating OSD on ${device}..."
    ceph-volume lvm create --data ${device}
    
    if [ $? -eq 0 ]; then
        echo "OSD created successfully on ${device}"
    else
        echo "ERROR: Failed to create OSD on ${device}"
    fi
    
    sleep 2
done

echo ""
echo "=== OSD creation completed on ${HOSTNAME} ==="
echo "OSD list:"
ceph-volume lvm list
