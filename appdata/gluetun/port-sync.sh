#!/bin/sh
# Run by gluetun whenever PIA assigns a forwarded port ({{PORTS}} arrives as $1).
# Points qBittorrent's listen port at it, otherwise incoming peer connections
# never arrive and download speeds collapse.
# Credentials come from QBT_USER / QBT_PASS in gluetun's environment.

QB="http://127.0.0.1:8080"
PORT="${1%%,*}"
CJ=/tmp/qbt-portsync.cookies

[ -n "$PORT" ] || { echo "[port-sync] no port given"; exit 0; }

# qBittorrent starts after gluetun is healthy, so its WebUI may not answer yet
i=0
while [ "$i" -lt 60 ]; do
  wget -q -O- --timeout=5 "$QB/api/v2/app/version" >/dev/null 2>&1 && break
  # a 403 means it is up but unauthenticated, which is good enough
  wget -S -q -O- --timeout=5 "$QB/api/v2/app/version" 2>&1 | grep -q "403" && break
  i=$((i + 1))
  sleep 5
done

rm -f "$CJ"
wget -q -O- --save-cookies "$CJ" --keep-session-cookies --timeout=10 \
  --header "Referer: $QB" \
  --post-data "username=${QBT_USER}&password=${QBT_PASS}" \
  "$QB/api/v2/auth/login" >/dev/null 2>&1 || { echo "[port-sync] login failed"; exit 1; }

wget -q -O- --load-cookies "$CJ" --timeout=10 \
  --header "Referer: $QB" \
  --post-data "json={\"listen_port\":${PORT}}" \
  "$QB/api/v2/app/setPreferences" >/dev/null 2>&1 \
  && echo "[port-sync] qBittorrent listen_port set to ${PORT}" \
  || echo "[port-sync] setPreferences failed"

rm -f "$CJ"
