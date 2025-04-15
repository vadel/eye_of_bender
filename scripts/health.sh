#!/bin/bash

echo "🤖 Cluster Health Report"
echo "==============================="

echo -e "\n🧠 Memory Usage:"
free -h

echo -e "\n💾 /home Disk Usage:"
df -h /home

echo -e "\n🔥 CPU Temperatures:"
if command -v sensors &> /dev/null; then
    sensors | grep -E 'Core|Package' || echo "No detailed output from sensors."
else
    echo "sensors command not available."
fi

# echo -e "\n🎮 GPU Status:"
# if command -v nvidia-smi &> /dev/null; then
#     nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits
# else
#     echo "nvidia-smi not available or no GPUs found."
# fi

echo -e "\n📦 Slurm Status:"
systemctl is-active slurmctld 2>/dev/null || echo "slurmctld status not available."

echo -e "\n📊 Load Average:"
uptime
echo "Cores: $(nproc)"

echo -e "\n✅ Node Summary:"
echo "NODE   STATE CPUS(Allocated/Idle/Other/Total)"
sinfo -Nh -o '%n %T %C' 2>/dev/null || echo "sinfo not available."
# 
echo -e "\n✅ Partition Summary:"
#echo "PART NODES  STATE    CPUS(A/I/O/T)"
#sinfo -h -o '%P %D %t %C'
printf "%-6s %-7s %-8s %-15s\n" "PART" "NODES" "STATE" "CPUS(A/I/O/T)"
#echo "-----------------------------------------"
sinfo -h -o '%P %D %t %C' | while read -r part nodes state cpus; do
    printf "%-6s %-7s %-8s %-15s\n" "$part" "$nodes" "$state" "$cpus"
done

