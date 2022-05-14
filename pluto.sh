#!/bin/bash
touch /logi/info.log
echo "Data utworzenia kontenera: $(date)" >> /logi/info.log
echo "Dostępna pamięć: $(grep MemTotal /proc/meminfo)" >> /logi/info.log
echo "Limit pamięci kontenera w bajtach: $(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)" >> /logi/info.log
sleep infinity
