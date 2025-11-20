#!/bin/bash

# ファイルシステムチェック (オフライン時のみ)
umount /var/lib/local-nvme
fsck.ext4 -f /dev/nvme0n1p1
mount /var/lib/local-nvme

# SMART情報確認
smartctl -a /dev/nvme0n1

# 容量クリーンアップ
find /var/lib/local-nvme/temp -mtime +7 -delete
find /var/lib/local-nvme/logs -mtime +30 -delete

