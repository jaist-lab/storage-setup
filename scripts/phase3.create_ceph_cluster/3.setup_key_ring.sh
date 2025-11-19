#!/bin/bash

echo "**r760xs1で実行:**"

# Monitorキーリング作成
ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'

# Admin キーリング作成
ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin \
    --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

# Bootstrap OSD キーリング作成
mkdir -p /var/lib/ceph/bootstrap-osd
ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd \
    --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'

# Monキーリングにadminとbootstrap-osdキーを追加
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring

# 権限設定
chown ceph:ceph /tmp/ceph.mon.keyring
chmod 600 /etc/ceph/ceph.client.admin.keyring
chown ceph:ceph /var/lib/ceph/bootstrap-osd/ceph.keyring

echo "Keyrings created successfully"
ls -l /tmp/ceph.mon.keyring
ls -l /etc/ceph/ceph.client.admin.keyring
