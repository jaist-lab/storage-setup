#!/bin/bash
# 1.install_ceph_packages.sh (Proxmox統合Ceph版)

echo "**全ノードで実行:**"

echo "=== Installing Ceph Packages (Version Fix) ==="

# 外部Cephリポジトリを削除
rm -f /etc/apt/sources.list.d/ceph.list
rm -f /usr/share/keyrings/ceph-archive-keyring.gpg

# パッケージリスト更新
apt-get update

echo ""
echo "Current Ceph packages:"
dpkg -l | grep ceph | grep ^ii

echo ""
echo "Checking available versions..."
apt-cache policy ceph ceph-mgr ceph-osd

# オプション1: pve2バージョンが利用可能か確認してインストール
echo ""
echo "Attempting to install ceph-mgr and ceph-osd with pve2..."
apt-get install -y \
    ceph-mgr=19.2.3-pve2 \
    ceph-osd=19.2.3-pve2 \
    libsqlite3-mod-ceph=19.2.3-pve2 \
    ceph-volume=19.2.3-pve2 2>/dev/null

# インストールできなかった場合は既存バージョンを使用
if [ $? -ne 0 ]; then
    echo ""
    echo "⚠️  Version 19.2.3-pve2 not available for all packages"
    echo "Checking if we can proceed with existing packages..."
    
    # 既にインストール済みのパッケージで必要なものが揃っているか確認
    MISSING=""
    
    # ceph-mgrの確認
    if ! dpkg -l | grep -q "^ii.*ceph-mgr"; then
        MISSING="${MISSING} ceph-mgr"
    fi
    
    # ceph-osdの確認
    if ! dpkg -l | grep -q "^ii.*ceph-osd"; then
        MISSING="${MISSING} ceph-osd"
    fi
    
    if [ -n "${MISSING}" ]; then
        echo "ERROR: Missing critical packages:${MISSING}"
        echo "Trying to install available version..."
        apt-get install -y ceph-mgr ceph-osd --allow-downgrades
    else
        echo "✓ All critical Ceph packages are already installed"
    fi
fi

# cephメタパッケージ（オプショナル）
echo ""
echo "Attempting to install ceph metapackage..."
apt-get install -y ceph=19.2.3-pve2 2>/dev/null || \
    echo "⚠️  ceph metapackage not installed (not critical)"

# radosgw（オプショナル - 必要な場合のみ）
# apt-get install -y radosgw 2>/dev/null || true

echo ""
echo "=== Final Package Status ==="
dpkg -l | grep ceph | grep ^ii

echo ""
echo "Ceph version:"
ceph --version

echo ""
echo "Critical commands check:"
which ceph-mon && echo "✓ ceph-mon available"
which ceph-mgr && echo "✓ ceph-mgr available" || echo "✗ ceph-mgr missing"
which ceph-osd && echo "✓ ceph-osd available" || echo "✗ ceph-osd missing"

echo ""
echo "=== Installation completed ==="
