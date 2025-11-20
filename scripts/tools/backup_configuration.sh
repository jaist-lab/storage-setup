#!/bin/bash

# 定期実行推奨 (cron)
#!/bin/bash
BACKUP_DIR="/root/ceph-backup-$(date +%Y%m%d)"
mkdir -p ${BACKUP_DIR}

# 設定ファイル
cp /etc/ceph/ceph.conf ${BACKUP_DIR}/
cp /etc/ceph/ceph.client.admin.keyring ${BACKUP_DIR}/

# クラスタマップ
ceph mon getmap -o ${BACKUP_DIR}/monmap
ceph osd getcrushmap -o ${BACKUP_DIR}/crushmap

# クラスタ状態
ceph -s > ${BACKUP_DIR}/cluster-status.txt
ceph osd tree > ${BACKUP_DIR}/osd-tree.txt
ceph df > ${BACKUP_DIR}/cluster-df.txt

tar -czf /root/ceph-backup-$(date +%Y%m%d).tar.gz ${BACKUP_DIR}
rm -rf ${BACKUP_DIR}
