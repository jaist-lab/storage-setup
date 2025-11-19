#!/bin/bash
# local-nvme-perf-test.sh

echo "**各ノードで実行:**"

MOUNT_POINT="/var/lib/local-nvme"
TEST_FILE="${MOUNT_POINT}/test-perf-file"
RESULT_FILE="/root/storage-setup/logs/local-nvme-perf-$(hostname).log"

echo "===== Local NVMe Performance Test =====" | tee ${RESULT_FILE}
echo "Node: $(hostname)" | tee -a ${RESULT_FILE}
echo "Device: $(df ${MOUNT_POINT} | tail -1 | awk '{print $1}')" | tee -a ${RESULT_FILE}
echo "Date: $(date)" | tee -a ${RESULT_FILE}
echo "" | tee -a ${RESULT_FILE}

# Sequential Write Test
echo "--- Sequential Write Test (1GB) ---" | tee -a ${RESULT_FILE}
dd if=/dev/zero of=${TEST_FILE} bs=1M count=1024 conv=fdatasync 2>&1 | tee -a ${RESULT_FILE}

# Sequential Read Test
echo "" | tee -a ${RESULT_FILE}
echo "--- Sequential Read Test (1GB) ---" | tee -a ${RESULT_FILE}
dd if=${TEST_FILE} of=/dev/null bs=1M 2>&1 | tee -a ${RESULT_FILE}

# Random Write Test (fio)
if command -v fio &> /dev/null; then
    echo "" | tee -a ${RESULT_FILE}
    echo "--- Random Write Test (fio, 4K blocks, 1GB) ---" | tee -a ${RESULT_FILE}
    fio --name=randwrite --ioengine=libaio --iodepth=16 --rw=randwrite --bs=4k --direct=1 \
        --size=1G --numjobs=1 --runtime=30 --group_reporting \
        --filename=${TEST_FILE} 2>&1 | tee -a ${RESULT_FILE}
    
    echo "" | tee -a ${RESULT_FILE}
    echo "--- Random Read Test (fio, 4K blocks, 1GB) ---" | tee -a ${RESULT_FILE}
    fio --name=randread --ioengine=libaio --iodepth=16 --rw=randread --bs=4k --direct=1 \
        --size=1G --numjobs=1 --runtime=30 --group_reporting \
        --filename=${TEST_FILE} 2>&1 | tee -a ${RESULT_FILE}
    
    echo "" | tee -a ${RESULT_FILE}
    echo "--- fsync Latency Test (etcd simulation) ---" | tee -a ${RESULT_FILE}
    fio --name=fsync_test --ioengine=sync --rw=write --bs=4k --direct=1 \
        --size=100M --fsync=1 --numjobs=1 \
        --filename=${TEST_FILE} 2>&1 | tee -a ${RESULT_FILE}
else
    echo "fio not installed, skipping advanced tests" | tee -a ${RESULT_FILE}
    echo "Install with: apt-get install -y fio" | tee -a ${RESULT_FILE}
fi

# Clean up
rm -f ${TEST_FILE}

echo "" | tee -a ${RESULT_FILE}
echo "===== Performance test completed =====" | tee -a ${RESULT_FILE}
echo "Results saved to: ${RESULT_FILE}"

echo " "
echo "**期待される結果 (NVMe SSD):**"
echo "- Sequential Write: 1,000 MB/s以上"
echo "- Sequential Read: 2,000 MB/s以上"
echo "- Random Write (4K): 50,000 IOPS以上"
echo "- Random Read (4K): 100,000 IOPS以上"
echo "- fsync latency: 1ms以下"
echo " "
