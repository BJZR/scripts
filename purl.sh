#!/usr/bin/env bash
set -euo pipefail

[[ $# -ne 1 ]] && { echo "uso: purl <url>"; exit 1; }

url="$1"
count=5
total=0

for i in $(seq 1 $count); do
  time=$(curl -o /dev/null -s -w '%{time_total}' "$url")
  echo "Request $i: ${time}s"
  total=$(awk "BEGIN {print $total + $time}")
done

avg=$(awk "BEGIN {print $total / $count}")
echo "Average : ${avg}s"

