**全ノードで実行:**

```bash
#!/bin/bash
# ceph-mds-init.sh

echo "**全ノードで実行:**"

HOSTNAME=$(hostname -s)
MDS_DATA="/var/lib/ceph/mds/ceph-${HOSTNAME}"

echo "=== Initializing MDS on ${HOSTNAME} ==="

# MDSデータディレクトリ作成
mkdir -p ${MDS_DATA}

# MDSキーリング作成
ceph auth get-or-create mds.${HOSTNAME} mon 'allow profile mds' osd 'allow rwx' mds 'allow *' \
    -o ${MDS_DATA}/keyring

# 権限設定
chown -R ceph:ceph ${MDS_DATA}

# Systemd サービス有効化と起動
systemctl enable ceph-mds@${HOSTNAME}
systemctl start ceph-mds@${HOSTNAME}

# 起動確認
sleep 3
systemctl status ceph-mds@${HOSTNAME}

echo "MDS initialization completed on ${HOSTNAME}"
