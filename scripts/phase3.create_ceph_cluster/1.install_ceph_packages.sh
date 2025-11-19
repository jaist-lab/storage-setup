#!/bin/bash
# 1.install_ceph_packages.sh (Proxmox統合Ceph版)

echo "**全ノードで実行:**"

echo "=== Installing Ceph Packages (Proxmox Version) ==="


# 外部Cephリポジトリを削除（競合回避）
echo "Removing external Ceph repository..."
rm -f /etc/apt/sources.list.d/ceph.list
rm -f /usr/share/keyrings/ceph-archive-keyring.gpg

# パッケージリスト更新
echo "Updating package list..."
apt-get update

# ProxmoxのCephパッケージインストール
echo "Installing Proxmox Ceph packages..."
apt-get install -y \
    ceph \
    ceph-mon \
    ceph-mgr \
    ceph-osd \
    ceph-mds \
    ceph-common \
    ceph-fuse \
    cephfs-top \
    python3-ceph-argparse \
    python3-cephfs

# 追加で必要なパッケージ
apt-get install -y \
    ceph-volume \
    librados2 \
    librbd1 \
    libcephfs2

# バージョン確認
echo ""
echo "Installed Ceph version:"
ceph --version

echo ""
echo "Installed packages:"
dpkg -l | grep ceph | grep ^ii

echo ""
echo "=== Ceph packages installed successfully ==="

