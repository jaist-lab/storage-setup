#!/bin/bash

# r760xs1から全ノードで実行
for node in r760xs{1..5}; do
    echo "=== Preparing ${node} ==="
    ssh root@${node} 'bash -s' < prepare_environment.sh
done
