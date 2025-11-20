#!/bin/bash
# 0.prepare_environment.sh

echo "=== Preparing Ceph Environment ==="

# 必要なディレクトリ作成
mkdir -p /var/run/ceph
chown ceph:ceph /var/run/ceph 2>/dev/null || mkdir -p /var/run/ceph
chmod 755 /var/run/ceph

# tmpfiles.d設定（再起動後も/var/run/cephが自動作成されるように）
cat > /etc/tmpfiles.d/ceph.conf << 'EOF'
d /var/run/ceph 0755 ceph ceph -
EOF

echo "✓ Environment prepared"
