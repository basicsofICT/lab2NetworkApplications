#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing lab prerequisites..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  john hydra tcpdump curl nmap git less openssh-server openssl \
  apache2-utils dirb nikto sqlmap python3-flask

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
LAB_PASS="testpass"
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
printf "%s\n" "${LAB_PASS}" "123456" "password" "letmein" > passwords.txt

echo "🔐 Creating a SHA-512 test hash for John the Ripper..."
HASH="$(openssl passwd -6 -salt labsalt "${LAB_PASS}")"
echo "${LAB_USER}:${HASH}" > hash.txt

cat > phishing_email.txt <<'EOF'
Subject: Urgent: Account Deactivation Notice

Dear User,

We have detected unusual activity on your account. To avoid permanent deactivation, please verify your information immediately by clicking the link below:

http://secure-update-account.com/verify

Failure to act within 24 hours will result in loss of access to your account and all associated data.

Best regards,
IT Support Team
EOF

cat > LAB_START_HERE.txt <<'EOF'
Quick commands for the lab:

1) John the Ripper (hash cracking)
   john hash.txt
   john --show hash.txt   # show cracked creds (after success)

   # Optional wordlist usage:
   john --wordlist=passwords.txt hash.txt

2) Hydra (dictionary attack against localhost only)
   hydra -L users.txt -P passwords.txt ssh://localhost

3) Tcpdump (capture 20 packets; run curl in another terminal to generate noise)
   sudo tcpdump -i any -c 20
   curl https://example.com

4) Phishing email review
   cat phishing_email.txt

5) DoS flood test (Task 5)
   ab -n 1000 -c 50 http://localhost:8080/
   curl -s http://localhost:8080/stats -o dos_report.json

6) Session hijacking (Task 6)
   sudo timeout 20 tcpdump -i lo -A -s 0 'tcp port 5001' > session_capture.log 2>&1
   curl -s -b "session=<stolen_token>" http://localhost:5001/account -o session_hijack_flag.txt

7) Web recon (Task 7)
   nikto -h http://localhost:8000
   dirb http://localhost:8000/ scripts/web_wordlist.txt
   curl http://localhost:8000/hidden-admin/flag.txt -o web_recon_flag.txt

8) SQL injection (Task 8)
   sqlmap -u "http://localhost:5002/user?id=1" --batch --dump
   john --wordlist=scripts/sqli_wordlist.txt sqli_extracted_hash.txt
EOF

echo "🔐 Generating SQL injection lab admin password hash (Task 8)..."
SQLI_PASSWORD="Dragon2024!"
openssl passwd -6 -salt sqlisalt "${SQLI_PASSWORD}" > "${WORKDIR}/apps/.sqli_admin_hash"

echo "🚀 Making lab scripts executable..."
chmod +x "${WORKDIR}"/scripts/*.sh "${WORKDIR}"/apps/*.sh 2>/dev/null || true

# Make sure ownership is correct for the vscode user
sudo chown -R vscode:vscode "${WORKDIR}"

echo "✅ Setup complete."
