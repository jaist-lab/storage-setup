#!/bin/bash
# complete_ceph_cleanup.sh

echo "=============================================="
echo "  Ceph Complete Cleanup Script"
echo "=============================================="
echo ""
echo "⚠️  WARNING: This will completely remove Ceph!"
echo "⚠️  All data will be LOST!"
echo ""
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

# Phase 1: サービス停止
echo ""
echo "Phase 1: Stopping services..."
systemctl stop ceph.target
systemctl stop 'ceph-*'
pkill -9 ceph-mon ceph-mgr ceph-osd ceph-mds radosgw 2>/dev/null || true
sleep 3

# Phase 2: サービス無効化
echo ""
echo "Phase 2: Disabling services..."
systemctl disable ceph-mon@$(hostname -s) 2>/dev/null || true
systemctl disable ceph-mgr@$(hostname -s) 2>/dev/null || true
systemctl disable ceph-mds@$(hostname -s) 2>/dev/null || true
systemctl disable ceph.target 2>/dev/null || true

# Phase 3: データ削除
echo ""
echo "Phase 3: Removing data..."
rm -rf /var/lib/ceph/mon/ceph-*
rm -rf /var/lib/ceph/mgr/ceph-*
rm -rf /var/lib/ceph/mds/ceph-*
rm -rf /var/lib/ceph/osd/ceph-*
rm -rf /var/lib/ceph/bootstrap-*
rm -f /tmp/ceph.mon.keyring /tmp/monmap

# Phase 4: 設定削除
echo ""
echo "Phase 4: Removing configuration..."
rm -f /etc/ceph/ceph.conf
rm -f /etc/ceph/ceph.client.admin.keyring
rm -f /etc/pve/ceph.conf 2>/dev/null || true

# Phase 5: OSDデバイスクリーンアップ
echo ""
echo "Phase 5: Cleaning OSD devices..."
HOSTNAME=$(hostname -s)
if [ "${HOSTNAME}" = "r760xs1" ]; then
    OSD_DEVICES="/dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1 /dev/nvme4n1"
else
    OSD_DEVICES="/dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1 /dev/nvme4n1 /dev/nvme5n1"
fi

for device in ${OSD_DEVICES}; do
    if [ -b "${device}" ]; then
        echo "  Cleaning ${device}..."
        VG=$(pvs ${device}* 2>/dev/null | grep ceph | awk '{print $2}' | head -1)
        [ -n "${VG}" ] && vgremove -f ${VG} 2>/dev/null || true
        pvremove -ff ${device}* 2>/dev/null || true
        sgdisk --zap-all ${device} 2>/dev/null || true
        wipefs -a ${device} 2>/dev/null || true
    fi
done

# Phase 6: パッケージアンインストール
echo ""
echo "Phase 6: Uninstalling packages..."
apt-get purge -y ceph ceph-mon ceph-mgr ceph-osd ceph-mds ceph-common 2>/dev/null || true
apt-get autoremove -y
rm -f /etc/apt/sources.list.d/ceph.list
apt-get update

# Phase 7: 最終クリーンアップ
echo ""
echo "Phase 7: Final cleanup..."
rm -rf /var/lib/ceph /var/run/ceph /etc/ceph
systemctl daemon-reload
systemctl reset-failed

echo ""
echo "=============================================="
echo "  Cleanup completed!"
echo "=============================================="
echo ""
echo "Device status:"
lsblk | grep -E "nvme[1-5]n1"
