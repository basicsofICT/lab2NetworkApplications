#!/usr/bin/env bash
# Starts (or restarts) all background services used by the lab tasks.
# Safe to re-run: any previous instances are killed first.
set -uo pipefail
cd "$(dirname "$0")/.."

ensure_flask() {
  if python3 -c "import flask" >/dev/null 2>&1; then
    return 0
  fi
  echo "Flask is missing for $(command -v python3); installing..."
  python3 -m pip install flask >/tmp/flask_install.log 2>&1 \
    || python3 -m pip install --user flask >>/tmp/flask_install.log 2>&1 \
    || python3 -m pip install --break-system-packages flask >>/tmp/flask_install.log 2>&1 \
    || true
  if ! python3 -c "import flask" >/dev/null 2>&1; then
    echo "ERROR: cannot import flask. Last install log:"
    tail -n 20 /tmp/flask_install.log 2>/dev/null || true
    return 1
  fi
}

ensure_flask || true

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
sleep 0.5

export PYTHONUNBUFFERED=1
nohup python3 apps/dos_target.py       >/tmp/dos_target.log     2>&1 &
nohup python3 apps/session_app.py      >/tmp/session_app.log    2>&1 &
nohup python3 apps/vuln_login_app.py   >/tmp/vuln_login_app.log 2>&1 &
nohup python3 apps/sniff_target.py     >/tmp/sniff_target.log   2>&1 &
nohup python3 apps/modern_api.py       >/tmp/modern_api.log     2>&1 &
nohup bash apps/simulate_admin.sh      >/tmp/simulate_admin.log 2>&1 &
nohup bash apps/simulate_oauth.sh      >/tmp/simulate_oauth.log 2>&1 &
nohup python3 -m http.server 8000 --bind 0.0.0.0 --directory webroot >/tmp/webrecon.log 2>&1 &

port_is_up() {
  python3 - "$1" <<'PY'
import socket, sys
s = socket.socket()
s.settimeout(0.4)
try:
    s.connect(("127.0.0.1", int(sys.argv[1])))
except OSError:
    raise SystemExit(1)
finally:
    s.close()
PY
}

PORTS=(22 5001 5002 5003 8000 8080 8081)
FAILED=()
for _ in $(seq 1 15); do
  FAILED=()
  for port in "${PORTS[@]}"; do
    if ! port_is_up "${port}"; then
      FAILED+=("${port}")
    fi
  done
  if [[ ${#FAILED[@]} -eq 0 ]]; then
    break
  fi
  sleep 0.4
done

echo ""
echo "Lab services (127.0.0.1):"
echo "   SSH            :22"
echo "   Sniff target   :8081   http://127.0.0.1:8081/"
echo "   DoS target     :8080   http://127.0.0.1:8080/"
echo "   Session app    :5001   http://127.0.0.1:5001/login"
echo "   SQLi app       :5002   http://127.0.0.1:5002/user?id=1"
echo "   Modern API     :5003   http://127.0.0.1:5003/api/users/1"
echo "   Web recon site :8000   http://127.0.0.1:8000/"

if [[ ${#FAILED[@]} -ne 0 ]]; then
  echo ""
  echo "ERROR: not listening: ${FAILED[*]}"
  echo "Python: $(command -v python3) ($(python3 -c 'import sys; print(sys.version.split()[0])'))"
  python3 -c "import flask; print('Flask', flask.__version__)" 2>&1 || echo "Flask import FAILED"
  echo "Recent app logs:"
  tail -n 8 /tmp/dos_target.log /tmp/session_app.log /tmp/vuln_login_app.log /tmp/sniff_target.log /tmp/modern_api.log /tmp/webrecon.log 2>/dev/null || true
  exit 1
fi

echo "All lab ports are listening."
