#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing lab prerequisites..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  john hydra tcpdump curl nmap git less openssh-server openssl \
  apache2-utils dirb nikto sqlmap python3-flask python3-pip

# Install Flask into the Python that will run the lab apps (devcontainer Python
# is often not the Debian python3 that python3-flask is packaged for).
python3 -m pip install --upgrade pip >/dev/null 2>&1 || true
python3 -m pip install flask || python3 -m pip install --user flask || \
  python3 -m pip install --break-system-packages flask || true
python3 -c "import flask" || echo "WARNING: Flask import failed for $(command -v python3)"

echo "🔐 Configuring sshd for localhost-only, password auth..."
sudo mkdir -p /etc/ssh/sshd_config.d
sudo tee /etc/ssh/sshd_config.d/lab.conf >/dev/null <<'EOF'
# Lab-only config: bind only to loopback; allow password auth for demonstration
ListenAddress 127.0.0.1
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
PermitRootLogin no
X11Forwarding no
AllowTcpForwarding no
Subsystem sftp /usr/lib/openssh/sftp-server
# Optional: more verbose auth logs to correlate Hydra attempts
LogLevel VERBOSE
# Optional: ease connection throttling for demo smoothness (still localhost)
MaxStartups 20:30:100
LoginGraceTime 60
EOF

# Ensure host keys directory exists; keys are generated in postStartCommand.
sudo mkdir -p /run/sshd

# --- Create a dedicated local test account for the SSH brute-force demo ---
LAB_USER="testuser"
LAB_PASS="password"
if ! id -u "${LAB_USER}" >/dev/null 2>&1; then
  echo "👤 Creating lab user '${LAB_USER}'..."
  sudo useradd -m -s /bin/bash "${LAB_USER}"
fi
echo "${LAB_USER}:${LAB_PASS}" | sudo chpasswd

# --- Determine repo root dynamically (works regardless of repo name) ---
# This script lives at .devcontainer/setup.sh → repo root is one level up.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKDIR="${REPO_ROOT}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "📁 Working directory: ${WORKDIR}"

echo "📝 Generating users.txt and passwords.txt..."
printf "%s\n" "${LAB_USER}" > users.txt
printf "%s\n" "${LAB_PASS}" "123456" "qwerty" "letmein" > passwords.txt

echo "🔐 Creating a SHA-512 test hash for John the Ripper..."
HASH="$(openssl passwd -6 -salt labsalt "${LAB_PASS}")"
echo "${LAB_USER}:${HASH}" > hash.txt

echo "🔐 Generating SQL injection lab admin password hash (Task 8)..."
SQLI_PASSWORD="Dragon2024!"
openssl passwd -6 -salt sqlisalt "${SQLI_PASSWORD}" > "${WORKDIR}/apps/.sqli_admin_hash"

echo "🔐 Creating cryptography challenge files (Task 9)..."
echo -n 'FLAG{b64_d3c0de_ok}' | base64 > cipher_b64.txt
echo -n 'letmein' | md5sum | awk '{print $1}' > md5_hash.txt

echo "🚀 Making lab scripts executable..."
chmod +x "${WORKDIR}"/scripts/*.sh "${WORKDIR}"/apps/*.sh 2>/dev/null || true

# Make sure ownership is correct for the vscode user
sudo chown -R vscode:vscode "${WORKDIR}"

echo "✅ Setup complete."
