#!/bin/bash

echo "**全ノードで実行:**"

# Ceph リポジトリ追加 (Squid)
wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add -

echo "deb https://download.ceph.com/debian-squid/ $(lsb_release -sc) main" | \
    tee /etc/apt/sources.list.d/ceph.list

# パッケージリスト更新
apt-get update

# Cephパッケージインストール
apt-get install -y \
    ceph \
    ceph-mon \
    ceph-mgr \
    ceph-osd \
    ceph-mds \
    ceph-common \
    radosgw \
    python3-ceph-argparse \
    python3-cephfs

# バージョン確認
ceph --version
