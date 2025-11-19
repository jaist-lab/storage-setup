#!/bin/bash

# 1. まずProxmox共有ディレクトリへコピー（ここが重要です）
cp /etc/ceph/ceph.conf /etc/pve/ceph.conf

# 2. 元のファイルをリンクに置き換え
ln -sf /etc/pve/ceph.conf /etc/ceph/ceph.conf

# 3. 確認（以下のように表示されればOKです）
ls -l /etc/ceph/ceph.conf
# 出力例: lrwxrwxrwx ... /etc/ceph/ceph.conf -> /etc/pve/ceph.conf
