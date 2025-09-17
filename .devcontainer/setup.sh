#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing lab prerequisites..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  john hydra tcpdump curl nmap git less openssh-server openssl

# --- Configure SSH server to be LOCALHOST ONLY & password auth for the lab ---
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

# --- Create lab working files in the workspace ---
WORKDIR="/workspaces/system-exploitation-lab"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "📝 Generating users.txt and passwords.txt..."
printf "%s\n" "${LAB_USER}" > users.txt
# include the correct password and a few decoys
printf "%s\n" "${LAB_PASS}" "123456" "password" "letmein" > passwords.txt

echo "🔐 Creating a SHA-512 test hash for John the Ripper..."
# Generate a deterministic SHA-512 hash with a fixed salt so results are reproducible
HASH="$(openssl passwd -6 -salt labsalt "${LAB_PASS}")"
# classic shadow-format line: username:hash
echo "${LAB_USER}:${HASH}" > hash.txt

# Add a small phishing example file for the social engineering discussion
cat > phishing_email.txt <<'EOF'
Subject: Account Deactivation Notice

Hi,

Your account is scheduled for deactivation. Click [here] to verify.

Regards,
IT Support
EOF

# Helpful hints file that the README can reference
cat > LAB_START_HERE.txt <<'EOF'
Quick commands for the lab:

1) John the Ripper (hash cracking)
   john hash.txt
   john --show hash.txt   # show cracked creds (after success)

2) Hydra (dictionary attack against localhost only)
   hydra -L users.txt -P passwords.txt ssh://localhost

3) Tcpdump (capture 20 packets; run curl in another terminal to generate noise)
   sudo tcpdump -i any -c 20
   curl https://example.com

4) Browse harmless repo for malware techniques (theory only)
   git clone https://github.com/0xInfection/Awesome-Windows-Exploitation.git
   cd Awesome-Windows-Exploitation && less README.md
EOF

# Make sure ownership is correct for the vscode user
sudo chown -R vscode:vscode "${WORKDIR}"

echo "✅ Setup complete."
