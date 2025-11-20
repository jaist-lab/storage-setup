#!/bin/bash

# r760xs1から全ノードにインストール

for node in r760xs{1..5}; do
    echo "=== Installing Ceph on ${node} ==="
    ssh root@${node} "pveceph install --repository no-subscription"
done
