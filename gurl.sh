#!/usr/bin/env bash
set -euo pipefail

[[ $# -ne 1 ]] && { echo "uso: gurl <url>"; exit 1; }

curl --fail --silent --show-error "$1"

