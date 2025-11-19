#!/bin/bash

echo "**r760xs1 (またはいずれか1ノード) で実行:**"

# 全ノードのローカルNVMeストレージを登録

for node in r760xs{1..5}; do
    echo "Adding local-nvme storage on ${node}..."
    
    pvesm add dir local-nvme \
        --path /var/lib/local-nvme/images \
        --content vztmpl,backup,iso,rootdir,images \
        --nodes ${node} \
        --prune-backups keep-last=3 \
        --shared 0
    
    echo "Storage added for ${node}"
done

# 登録確認
pvesm status | grep local-nvme

echo "**Proxmox Web GUIで確認:**"
echo "1. Datacenter → Storage"
echo "2. `local-nvme` ストレージが各ノードに表示されることを確認"
echo "3. 各ノードを選択して、Contentが正しく設定されていることを確認"

