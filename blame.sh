#!/bin/bash

echo -e "USER\tJOBS\tMAX_RUNNING_TIME"

# Get unique users
users=$(squeue -h -o "%u" | sort | uniq)

for user in $users; do
    # Count total jobs
    job_count=$(squeue -h -u "$user" | wc -l)

    # Get all running job times for this user
    runtimes=$(squeue -h -u "$user" -t RUNNING -o "%M")

    # Convert each time to seconds and get the max
    max_seconds=0
    for time in $runtimes; do
        # Convert time format (D-HH:MM:SS or HH:MM:SS) to seconds
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

    # Format max_seconds back to human-readable
    if (( max_seconds > 0 )); then
        max_time=$(printf '%dd %02dh:%02dm:%02ds\n' $((max_seconds/86400)) $(( (max_seconds%86400)/3600 )) $(( (max_seconds%3600)/60 )) $((max_seconds%60)))
    else
        max_time="-"
    fi

    echo -e "${user}\t${job_count}\t${max_time}"
done


