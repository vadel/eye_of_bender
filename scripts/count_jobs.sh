#!/bin/bash

echo "Jobs per user:"
squeue -h -o "%u" | sort | uniq -c | sort -nr

total=$(squeue -h | wc -l)
echo "--------------------"
echo "Total jobs in queue: $total"
