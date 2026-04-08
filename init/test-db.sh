#!/usr/bin/env sh
set -eu

DB_HOST="${TEST_DB_HOST}"
DB_PORT="${TEST_DB_PORT}"
DB_NAME="${TEST_DB_NAME}"
DB_USER="${TEST_DB_USER}"
DB_PASS="${TEST_DB_PASS}"

ADMIN_USER="admin"
ADMIN_PASS="12345678"
ADMIN_MAIL="hahn@systopia.de"
CMS_BASE_URL="http://localhost"

cd /var/www/html

echo "[test-db-init] waiting for mysql ${DB_HOST}:${DB_PORT} ..."
i=0
until mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASS}" -e "SELECT 1" >/dev/null 2>&1; do
  i=$((i+1))
  if [ "$i" -gt 60 ]; then
    echo "[test-db-init] ERROR: DB not reachable after 60s"
    exit 1
  fi
  sleep 1
done

if mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" \
    -e "SHOW TABLES LIKE 'civicrm_contact';" 2>/dev/null | grep -q civicrm_contact; then
  echo "[test-db-init] DB already initialized (civicrm_contact exists). Skipping."
  exit 0
fi

echo "[test-db-init] recreating database ${DB_NAME} ..."
mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASS}" -e "
DROP DATABASE IF EXISTS \`${DB_NAME}\`;
CREATE DATABASE \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
"

echo "[test-db-init] running cv core:install ..."
cv core:install \
  --db="mysql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}" \
  --url="${CMS_BASE_URL}" \
  --lang="de_DE" \
  --force

echo "[test-db-init] done."
