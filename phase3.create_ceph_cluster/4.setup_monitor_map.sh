#!/bin/bash

echo "**r760xs1で実行:**"

# FSID取得
FSID=$(grep fsid /etc/ceph/ceph.conf | awk '{print $3}')

# Monmapの作成
monmaptool --create --add r760xs1 172.16.200.11 --add r760xs2 172.16.200.12 \
    --add r760xs3 172.16.200.13 --add r760xs4 172.16.200.14 --add r760xs5 172.16.200.15 \
    --fsid ${FSID} /tmp/monmap

# Monmap確認
monmaptool --print /tmp/monmap

echo "Monitor map created: /tmp/monmap"
