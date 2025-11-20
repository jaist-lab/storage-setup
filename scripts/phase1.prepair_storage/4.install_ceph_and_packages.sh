#!/bin/bash
# 4.install_package.sh

echo "**全ノードで実行:**"

# システム更新
apt-get update

# 必要なパッケージ
apt-get install -y \
    nvme-cli \
    lvm2 \
    parted \
    gdisk \
    smartmontools \
    hdparm \
    iotop \
    sysstat \
    glow \
    fio \
    iperf3 \
    tree \
    curl \
    attr

# Ceph関連パッケージ (Phase 3で使用)
apt-get install -y ceph-common

# インストール確認
nvme version
parted --version
ceph --version
