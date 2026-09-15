#!/usr/bin/env bash
# Starts (or restarts) all background services used by the lab tasks.
# Safe to re-run: any previous instances are killed first.
set -uo pipefail
cd "$(dirname "$0")/.."

mkdir -p /run/sshd
sudo ssh-keygen -A >/dev/null 2>&1 || true
sudo pkill -f "/usr/sbin/sshd -D" 2>/dev/null || true
sudo /usr/sbin/sshd -D >/tmp/sshd.log 2>&1 &

pkill -f "apps/dos_target.py" 2>/dev/null || true
pkill -f "apps/session_app.py" 2>/dev/null || true
pkill -f "apps/vuln_login_app.py" 2>/dev/null || true
pkill -f "apps/sniff_target.py" 2>/dev/null || true
pkill -f "apps/modern_api.py" 2>/dev/null || true
pkill -f "apps/simulate_admin.sh" 2>/dev/null || true
pkill -f "apps/simulate_oauth.sh" 2>/dev/null || true
pkill -f "http.server 8000" 2>/dev/null || true

nohup python3 apps/dos_target.py       >/tmp/dos_target.log     2>&1 &
nohup python3 apps/session_app.py      >/tmp/session_app.log    2>&1 &
nohup python3 apps/vuln_login_app.py   >/tmp/vuln_login_app.log 2>&1 &
nohup python3 apps/sniff_target.py     >/tmp/sniff_target.log   2>&1 &
nohup python3 apps/modern_api.py       >/tmp/modern_api.log     2>&1 &
nohup bash apps/simulate_admin.sh      >/tmp/simulate_admin.log 2>&1 &
nohup bash apps/simulate_oauth.sh      >/tmp/simulate_oauth.log 2>&1 &
nohup python3 -m http.server 8000 --directory webroot >/tmp/webrecon.log 2>&1 &

sleep 1
echo ""
echo "✅ Lab services started:"
echo "   SSH            127.0.0.1:22   (localhost only)"
echo "   Sniff target   http://localhost:8081"
echo "   DoS target     http://localhost:8080  (/, /stats, /reset)"
echo "   Session app    http://localhost:5001  (/login, /account)"
echo "   SQLi app       http://localhost:5002  (/user?id=)"
echo "   Modern API     http://localhost:5003  (/oauth/token, /api/me, /api/users/<id>)"
echo "   Web recon site http://localhost:8000"
