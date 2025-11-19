#!/bin/bash
# 9.ceph-pools-create.sh

echo "**r760xs1で実行:**"

echo "=== Creating Ceph Storage Pools ==="

# Pool 1: vm-storage (VM用RBD)
echo "Creating vm-storage pool..."
ceph osd pool create vm-storage 512 512
ceph osd pool set vm-storage size 3
ceph osd pool set vm-storage min_size 2
ceph osd pool application enable vm-storage rbd
rbd pool init vm-storage

# Pool 2: k8s-rbd (Kubernetes用RBD)
echo "Creating k8s-rbd pool..."
ceph osd pool create k8s-rbd 256 256
ceph osd pool set k8s-rbd size 3
ceph osd pool set k8s-rbd min_size 2
ceph osd pool application enable k8s-rbd rbd
rbd pool init k8s-rbd

# Pool 3 & 4: CephFS (オプション - 使用する場合のみ)
read -p "Create CephFS pools? (yes/no): " create_cephfs

if [ "$create_cephfs" = "yes" ]; then
    echo "Creating CephFS pools..."
    
    # Metadata pool
    ceph osd pool create cephfs-metadata 64 64
    ceph osd pool set cephfs-metadata size 3
    ceph osd pool set cephfs-metadata min_size 2
    
    # Data pool
    ceph osd pool create cephfs-data 128 128
    ceph osd pool set cephfs-data size 3
    ceph osd pool set cephfs-data min_size 2
    
    # CephFS作成
    ceph fs new cephfs cephfs-metadata cephfs-data
    
    echo "CephFS created"
    ceph fs ls
fi

# 圧縮有効化 (オプション)
read -p "Enable compression on pools? (yes/no): " enable_compression

if [ "$enable_compression" = "yes" ]; then
    echo "Enabling lz4 compression..."
    ceph osd pool set vm-storage compression_algorithm lz4
    ceph osd pool set vm-storage compression_mode aggressive
    
    ceph osd pool set k8s-rbd compression_algorithm lz4
    ceph osd pool set k8s-rbd compression_mode aggressive
    
    if [ "$create_cephfs" = "yes" ]; then
        ceph osd pool set cephfs-data compression_algorithm lz4
        ceph osd pool set cephfs-data compression_mode aggressive
    fi
    
    echo "Compression enabled"
fi

echo ""
echo "=== Pool creation completed ==="
ceph osd pool ls detail
ceph df
