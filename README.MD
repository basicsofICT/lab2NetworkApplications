# System Exploitation – Bonus Task 2: Brute-Force & Hash-Cracking Lab (10 Points)

Welcome to the Brute-Force & Hash-Cracking Lab! This exercise provides a secure, hands-on environment to learn and practice password hash cracking and SSH brute-forcing techniques. All activities take place within a single GitHub Codespace container, with essential tools pre-installed and a localhost-only SSH service running automatically.

> ⚠️ **For educational use only.** Never attempt these techniques on systems you do not own or lack explicit written permission to test.

## Objectives

1. **Password Hash Analysis & Cracking**
	- Understand how password hashes are stored.
	- Use John the Ripper to recover weak passwords from hashes.

2. **Online Password Guessing (Brute Force)**
	- Perform a controlled SSH dictionary attack using Hydra.

3. **Network Observation**
	- Capture and analyze live network traffic with tcpdump.

4. **Phishing Awareness**
	- Recognize social engineering tactics and identify red flags in example emails.

👉 By completing these tasks, you will gain insight into how attackers exploit weak credentials and user behavior—and learn strategies to defend against these threats.

---
## Ethics & Legal Notes

- **Test only the container provided by this lab.**
- **Never** perform brute-force or scanning attacks on external or production systems.
- All findings are strictly for educational purposes.

---
## Getting Started

1. **Open this repository in GitHub Codespaces.**
3. Wait for the setup script to complete. The SSH daemon (localhost only) will start automatically and log to `/tmp/sshd.log`.
4. To confirm services are running, use:
	- `ps aux | grep sshd`
	- `tail -n +1 /tmp/sshd.log`

---
## Key Lab Files (in `/workspaces/system-exploitation-lab`)

- `users.txt`, `passwords.txt`
- `hash.txt` (SHA-512 crypt)
- `phishing_email.txt`
- `LAB_START_HERE.txt` (quick commands)

---
## Services in the Lab

- **SSH:** Running only on `127.0.0.1:22`
  - Username: `testuser`
## Lab Tasks (Total: 10 Points)

Before you begin, make sure all scripts in the `scripts/` folder are executable. Run this command once during setup:

```sh
chmod +x scripts/*.sh
```

---

### 1. Hash Cracking with John the Ripper (2 pts)
**Goal:** Recover the lab user's password from `hash.txt`.

Commands:
```sh
john --wordlist=passwords.txt hash.txt
john --show hash.txt
```

**Deliverables:**
- Screenshot or copy of the cracked credentials line.
- Brief explanation (2–3 sentences) of how the `$6$` (SHA-512 crypt) format works.

---

### 2. SSH Brute-Force with Hydra (3 pts)
**Goal:** Use a small dictionary attack against the local SSH service.

Command:
```sh
hydra -L users.txt -P passwords.txt ssh://localhost
```

**Deliverables:**
- Hydra output showing the discovered login/password.
- Brief explanation (2–3 sentences) of how online brute-force differs from offline hash cracking.

---

### 3. Traffic Capture & Analysis (3 pts)
**Goal:** Observe network packets while generating simple traffic.

Commands:
```sh
sudo tcpdump -i any -c 20
# In another terminal:

```

**Deliverables:**
- Brief summary of captured packet types (e.g., TCP handshake, DNS lookup).
- Note any SSH or HTTP packets you observed.

---

### 4. Phishing Email Red-Flags (2 pts)
Open `phishing_email.txt` and identify at least five red flags (e.g., generic greeting, suspicious link).

**Deliverable:**
- Short paragraph listing five red flags and how a user should verify legitimacy.

---

## Report Template
Fill out `yourAnswers.md` as you complete each task.
Report Template
Fill out yourAnswers.md as you do these tasks: