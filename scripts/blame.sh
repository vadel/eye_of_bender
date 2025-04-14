#!/bin/bash

declare -A user_job_count
declare -A user_max_time
declare -A user_max_time_human

# Collect data
users=$(squeue -h -o "%u" | sort | uniq)

for user in $users; do
    # Count jobs
    job_count=$(squeue -h -u "$user" | wc -l)
    user_job_count["$user"]=$job_count

    # Max running time
    runtimes=$(squeue -h -u "$user" -t RUNNING -o "%M")
    max_seconds=0

    for time in $runtimes; do
        IFS='-' read -ra PARTS <<< "$time"
        if [[ ${#PARTS[@]} -eq 2 ]]; then
            days=${PARTS[0]}
            timepart=${PARTS[1]}
        else
            days=0
            timepart=${PARTS[0]}
        fi

        IFS=':' read -ra t <<< "$timepart"
        if [[ ${#t[@]} -eq 3 ]]; then
            hours=${t[0]}
            minutes=${t[1]}
            seconds=${t[2]}
        else
            hours=0
            minutes=${t[0]}
            seconds=${t[1]}
        fi

        total=$((10#$days * 86400 + 10#$hours * 3600 + 10#$minutes * 60 + 10#$seconds))
        if (( total > max_seconds )); then
            max_seconds=$total
        fi
    done

    user_max_time["$user"]=$max_seconds
    if (( max_seconds > 0 )); then
        user_max_time_human["$user"]=$(printf '%dd %02dh:%02dm:%02ds' $((max_seconds/86400)) $(( (max_seconds%86400)/3600 )) $(( (max_seconds%3600)/60 )) $((max_seconds%60)))
    else
        user_max_time_human["$user"]="-"
    fi
done

# Determine top users
top_jobs_user=$(for u in "${!user_job_count[@]}"; do echo "$u ${user_job_count[$u]}"; done | sort -k2 -nr | head -n1 | cut -d' ' -f1)
top_time_user=$(for u in "${!user_max_time[@]}"; do echo "$u ${user_max_time[$u]}"; done | sort -k2 -nr | head -n1 | cut -d' ' -f1)

# Print header
printf "%-12s %-6s %-20s %-15s\n" "USER" "JOBS" "MAX_RUNNING_TIME" "🏅"
echo "---------------------------------------------------------------------"

# Print stats
for user in "${!user_job_count[@]}"; do
    badge=""
    [[ "$user" == "$top_jobs_user" ]] && badge+="🧨"
    [[ "$user" == "$top_time_user" ]] && badge+="🔥"
    printf "%-12s %-6s %-20s %-15s\n" \
        "$user" \
        "${user_job_count[$user]}" \
        "${user_max_time_human[$user]}" \
        "$badge"
done
