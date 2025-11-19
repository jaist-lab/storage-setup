#!/bin/bash
# ceph-mgr-init.sh

echo "**全ノードで実行:**"

HOSTNAME=$(hostname -s)
MGR_DATA="/var/lib/ceph/mgr/ceph-${HOSTNAME}"

echo "=== Initializing Manager on ${HOSTNAME} ==="

# Managerデータディレクトリ作成
mkdir -p ${MGR_DATA}

# Managerキーリング作成
ceph auth get-or-create mgr.${HOSTNAME} mon 'allow profile mgr' osd 'allow *' mds 'allow *' \
    -o ${MGR_DATA}/keyring

# 権限設定
chown -R ceph:ceph ${MGR_DATA}

# Systemd サービス有効化と起動
systemctl enable ceph-mgr@${HOSTNAME}
systemctl start ceph-mgr@${HOSTNAME}

# 起動確認
sleep 3
systemctl status ceph-mgr@${HOSTNAME}

echo "Manager initialization completed on ${HOSTNAME}"
