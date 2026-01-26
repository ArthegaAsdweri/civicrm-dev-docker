#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/var/www/html/private/log"
mkdir -p "$LOG_DIR"

(
  shopt -s nullglob
  declare -A tailed

  while true; do
    for f in "$LOG_DIR"/*.log; do
      if [[ -z "${tailed["$f"]+x}" ]]; then
        tailed["$f"]=1
        tail -n 0 -F "$f" &
      fi
    done
    sleep 2
  done
) &

exec "$@"
