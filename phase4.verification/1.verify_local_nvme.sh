#!/bin/bash
# verify-local-nvme.sh

echo "**全ノードで実行:**"

echo "=== Local NVMe Storage Verification ==="
echo "Node: $(hostname)"
echo ""

# マウント状態確認
echo "--- Mount Status ---"
mountpoint -q /var/lib/local-nvme && echo "✓ Mounted" || echo "✗ Not mounted"
df -h /var/lib/local-nvme

echo ""
echo "--- Filesystem Status ---"
tune2fs -l /dev/nvme0n1p1 | grep -E "Filesystem|Mount count|Check interval"

echo ""
echo "--- fstab Entry ---"
grep local-nvme /etc/fstab

echo ""
echo "--- Directory Structure ---"
tree -L 2 /var/lib/local-nvme || ls -la /var/lib/local-nvme

echo ""
echo "--- Proxmox Storage ---"
pvesm status | grep local-nvme

echo ""
echo "--- Write Test ---"
TEST_FILE="/var/lib/local-nvme/temp/test-$(date +%s).dat"
dd if=/dev/zero of=${TEST_FILE} bs=1M count=100 conv=fdatasync 2>&1 | tail -3
rm -f ${TEST_FILE}

echo ""
echo "=== Verification completed ==="
