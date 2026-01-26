#!/usr/bin/env bash
set -euo pipefail

# Simple SSH tunnel helper: local 3307 -> remote 127.0.0.1:3306
# Usage: run and keep the terminal open while you use the tunnel.

read -r -p "SSH user: " SSH_USER
read -r -p "Server (host or ip): " SSH_HOST

LOCAL_PORT="${LOCAL_PORT:-3307}"
REMOTE_HOST="${REMOTE_HOST:-127.0.0.1}"
REMOTE_PORT="${REMOTE_PORT:-3306}"

echo
echo "Opening tunnel:"
echo "  localhost:${LOCAL_PORT} -> ${REMOTE_HOST}:${REMOTE_PORT} on ${SSH_USER}@${SSH_HOST}"
echo
echo "Keep this terminal open. Press Ctrl+C to close the tunnel."
echo

exec ssh -4 -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes -N -L "${LOCAL_PORT}:${REMOTE_HOST}:${REMOTE_PORT}" "${SSH_USER}@${SSH_HOST}"

