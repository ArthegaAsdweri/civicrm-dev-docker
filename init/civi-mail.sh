#!/usr/bin/env sh
set -eu

echo "[civi-mail] Configure CiviCRM outbound email via Mailpit (SMTP mailpit:1025)"

if ! command -v cv >/dev/null 2>&1; then
  echo "[civi-mail] ERROR: 'cv' not found"
  exit 1
fi

# IMPORTANT: set as PHP array via Civi settings (avoids JSON-string / wrong types)
cv ev '
$cfg = Civi::settings()->get("mailing_backend");
if (!is_array($cfg)) { $cfg = []; }

$cfg["outBound_option"] = 0;
$cfg["smtpServer"] = "mailpit";
$cfg["smtpPort"] = 1025;
$cfg["smtpAuth"] = 0;
$cfg["smtpUsername"] = "";
$cfg["smtpPassword"] = "";
$cfg["smtpSSL"] = "";

Civi::settings()->set("mailing_backend", $cfg);

echo "OK\n";
'
# Flush caches so the status check doesn't read stale/invalid values
cv flush

echo "[civi-mail] Done."
