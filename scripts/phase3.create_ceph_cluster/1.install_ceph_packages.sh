#!/bin/bash
# 1.install_ceph_packages.sh (Proxmox統合版)

echo "=== Installing Ceph via Proxmox Integration ==="

# 外部リポジトリ削除
rm -f /etc/apt/sources.list.d/ceph.list
rm -f /usr/share/keyrings/ceph-archive-keyring.gpg

# パッケージリスト更新
apt-get update

echo ""
echo "Installing Ceph using pveceph..."

# Proxmox統合Cephのインストール
pveceph install --repository no-subscription

if [ $? -eq 0 ]; then
    echo "✓ Ceph installed successfully via pveceph"
else
    echo "⚠️  pveceph install failed, trying manual installation..."
    
    # 手動で不足パッケージをインストール
    apt-get install -y \
        ceph-mgr \
        ceph-osd \
        ceph-volume \
        libsqlite3-mod-ceph \
        ceph-mgr-modules-core
fi

echo ""
echo "=== Final Package Status ==="
dpkg -l | grep ceph | grep ^ii

echo ""
echo "Ceph version:"
ceph --version

echo ""
echo "Critical commands check:"
for cmd in ceph-mon ceph-mgr ceph-osd ceph-volume monmaptool ceph-authtool; do
    if which $cmd > /dev/null 2>&1; then
        echo "✓ $cmd available"
    else
        echo "✗ $cmd missing"
    fi
done

echo ""
echo "=== Installation completed ==="
