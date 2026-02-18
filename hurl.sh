#!/usr/bin/env bash
set -euo pipefail

[[ $# -ne 1 ]] && { echo "uso: hurl <url>"; exit 1; }

url="$1"

response=$(curl -s -I -L "$url")

status=$(echo "$response" | grep -m1 HTTP | awk '{print $2}')
type=$(echo "$response" | grep -i '^Content-Type:' | awk '{print $2}' | tr -d '\r')
size=$(echo "$response" | grep -i '^Content-Length:' | awk '{print $2}' | tr -d '\r')

echo "Status : ${status:-unknown}"
echo "Type   : ${type:-unknown}"
echo "Size   : ${size:-unknown}"
echo "Final  : $(curl -s -o /dev/null -w '%{url_effective}' -L "$url")"

