
#!/bin/bash
# ceph-mon-init.sh

echo " **全ノードで実行:**"

HOSTNAME=$(hostname -s)
MON_DATA="/var/lib/ceph/mon/ceph-${HOSTNAME}"

echo "=== Initializing Monitor on ${HOSTNAME} ==="

# Monitorデータディレクトリ作成
mkdir -p ${MON_DATA}
chown ceph:ceph ${MON_DATA}

# r760xs1からファイルをコピー (r760xs2-5の場合)
if [ "${HOSTNAME}" != "r760xs1" ]; then
    echo "Copying configuration files from r760xs1..."
    scp r760xs1:/etc/ceph/ceph.conf /etc/ceph/ceph.conf
    scp r760xs1:/etc/ceph/ceph.client.admin.keyring /etc/ceph/ceph.client.admin.keyring
    scp r760xs1:/tmp/ceph.mon.keyring /tmp/ceph.mon.keyring
    scp r760xs1:/tmp/monmap /tmp/monmap
    
    # ディレクトリ作成
    mkdir -p /var/lib/ceph/bootstrap-osd
    scp r760xs1:/var/lib/ceph/bootstrap-osd/ceph.keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
    chown ceph:ceph /var/lib/ceph/bootstrap-osd/ceph.keyring
fi

# Monitor初期化
echo "Populating monitor database..."
sudo -u ceph ceph-mon --mkfs -i ${HOSTNAME} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

# Systemd サービス有効化と起動
systemctl enable ceph-mon@${HOSTNAME}
systemctl start ceph-mon@${HOSTNAME}

# 起動確認
sleep 5
systemctl status ceph-mon@${HOSTNAME}

echo "Monitor initialization completed on ${HOSTNAME}"
