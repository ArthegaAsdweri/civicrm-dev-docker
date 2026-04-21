#!/usr/bin/env bash
set -euo pipefail

read -r -p "SSH user (optional): " SSH_USER
read -r -p "Server (host or ip): " SSH_HOST

LOCAL_PORT="${LOCAL_PORT:-3307}"
REMOTE_HOST="${REMOTE_HOST:-127.0.0.1}"
REMOTE_PORT="${REMOTE_PORT:-3306}"
BIND_ADDRESS="${BIND_ADDRESS:-0.0.0.0}"

if [ -n "$SSH_USER" ]; then
  SSH_TARGET="${SSH_USER}@${SSH_HOST}"
else
  SSH_TARGET="${SSH_HOST}"
fi

echo
echo "Opening tunnel:"
echo "  ${BIND_ADDRESS}:${LOCAL_PORT} -> ${REMOTE_HOST}:${REMOTE_PORT} on ${SSH_TARGET}"
echo
echo "Keep this terminal open. Press Ctrl+C to close the tunnel."
echo

exec ssh -N -g -L "${BIND_ADDRESS}:${LOCAL_PORT}:${REMOTE_HOST}:${REMOTE_PORT}" "${SSH_TARGET}"