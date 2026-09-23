#!/usr/bin/env bash
set -euo pipefail

install_packages() {
  echo "Installing lab prerequisites..."
  sudo apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    john hydra tcpdump curl nmap git less openssh-server openssl \
    apache2-utils dirb nikto sqlmap python3 python3-flask python3-pip

  python3 -m pip install --upgrade pip >/dev/null 2>&1 || true
  python3 -m pip install flask || python3 -m pip install --user flask || \
    python3 -m pip install --break-system-packages flask || true
  python3 -c "import flask" || echo "WARNING: Flask import failed for $(command -v python3)"

  echo "Configuring sshd for localhost-only, password auth..."
  sudo mkdir -p /etc/ssh/sshd_config.d
  sudo tee /etc/ssh/sshd_config.d/lab.conf >/dev/null <<'EOF'
ListenAddress 127.0.0.1
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
PermitRootLogin no
X11Forwarding no
AllowTcpForwarding no
Subsystem sftp /usr/lib/openssh/sftp-server
LogLevel VERBOSE
MaxStartups 20:30:100
LoginGraceTime 60
EOF

  sudo mkdir -p /run/sshd

  LAB_USER="testuser"
  LAB_PASS="password"
  if ! id -u "${LAB_USER}" >/dev/null 2>&1; then
    echo "Creating lab user '${LAB_USER}'..."
    sudo useradd -m -s /bin/bash "${LAB_USER}"
  fi
  echo "${LAB_USER}:${LAB_PASS}" | sudo chpasswd
}

generate_lab_files() {
  LAB_USER="testuser"
  LAB_PASS="password"
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  WORKDIR="${REPO_ROOT}"
  mkdir -p "${WORKDIR}"
  cd "${WORKDIR}"

  echo "Working directory: ${WORKDIR}"

  printf "%s\n" "${LAB_USER}" > users.txt
  printf "%s\n" "${LAB_PASS}" "123456" "qwerty" "letmein" > passwords.txt

  HASH="$(openssl passwd -6 -salt labsalt "${LAB_PASS}")"
  echo "${LAB_USER}:${HASH}" > hash.txt

  SQLI_PASSWORD="Dragon2024!"
  openssl passwd -6 -salt sqlisalt "${SQLI_PASSWORD}" > "${WORKDIR}/apps/.sqli_admin_hash"

  echo -n 'FLAG{b64_d3c0de_ok}' | base64 > cipher_b64.txt
  echo -n 'letmein' | md5sum | awk '{print $1}' > md5_hash.txt

  chmod +x "${WORKDIR}"/scripts/*.sh "${WORKDIR}"/apps/*.sh 2>/dev/null || true
  sudo chown -R vscode:vscode "${WORKDIR}" 2>/dev/null || true
}

case "${1:-all}" in
  --packages)
    install_packages
    ;;
  --content)
    generate_lab_files
    ;;
  *)
    install_packages
    generate_lab_files
    ;;
esac

echo "Setup complete."
