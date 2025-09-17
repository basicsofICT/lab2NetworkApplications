# Bonus Task 2: Password Cracking, Brute-Force, Network Analysis & Phishing Awareness Lab (10 Points)

Welcome to the Password Cracking, Brute-Force, Network Analysis, and Phishing Awareness Lab! This hands-on lab provides a secure environment to:

- Practice password hash analysis and cracking using John the Ripper
- Perform SSH brute-force attacks with Hydra
- Capture and analyze network traffic using tcpdump
- Identify phishing techniques and red flags in suspicious emails

All activities are performed inside a single GitHub Codespace container, with all required tools pre-installed and a localhost-only SSH service running automatically.

> ⚠️ **For educational use only.** Never attempt these techniques on systems you do not own or lack explicit written permission to test.

## Objectives

By completing this lab, you will:

1. **Analyze and Crack Password Hashes**
	- Explore how password hashes are stored and protected.
	- Use John the Ripper to identify and recover weak passwords from hash files.

2. **Perform SSH Brute-Force Attacks**
	- Simulate a real-world dictionary attack on an SSH service using Hydra.
	- Understand the risks and impact of weak credentials.

3. **Observe and Analyze Network Traffic**
	- Capture live network packets with tcpdump.
	- Identify and interpret different types of network traffic, including authentication and web requests.

4. **Detect Phishing Techniques**
	- Examine a sample phishing email for common red flags.
	- Learn how to recognize and respond to social engineering attempts.

> These objectives will help you understand how attackers exploit weak credentials and user behavior, and how to defend against these threats in real-world scenarios.

---
## Ethics & Legal Notes


- Only test and attack the container provided by this lab. Never target external or production systems.
- All activities and findings are for educational purposes only. Do not use these techniques outside of approved environments.

---
## Getting Started

To begin the lab:

1. Open this repository in GitHub Codespaces.
3. Wait for the setup script to finish. The SSH daemon (localhost only) will start automatically and log to `/tmp/sshd.log`.
4. Confirm services are running by executing:
	- `ps aux | grep sshd` (check for the SSH process)
	- `tail -n +1 /tmp/sshd.log` (view SSH log output)

---
## Key Lab Files

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

In this task, you'll use John the Ripper to attempt to crack a password hash. The first command tells John to use the passwords listed in `passwords.txt` to try and match the hash stored in `hash.txt`. If successful, John will discover the original password. The second command displays any cracked credentials in a readable format. This process demonstrates how attackers can recover weak passwords if hashes and wordlists are available.

Commands:
```sh
john --wordlist=passwords.txt hash.txt
john --show hash.txt
```

**Deliverables:**
- Screenshot or copy of the cracked credentials line.
- Brief explanation (2–3 sentences) of how the `$6$` (SHA-512 crypt) format works.


> [John the Ripper password cracker](https://www.openwall.com/john/) : "John the Ripper is an Open Source password security auditing and password recovery tool available for many operating systems. John the Ripper jumbo supports hundreds of hash and cipher types, including for: user passwords of Unix flavors (Linux, *BSD, Solaris, AIX, QNX, etc.),"
---

### 2. SSH Brute-Force with Hydra (3 pts)
**Goal:** Use a small dictionary attack against the local SSH service.

In this task, you will use Hydra to automate login attempts against the SSH service running on localhost. Hydra will try each username from `users.txt` with each password from `passwords.txt`, attempting to find a valid login combination. This simulates a real-world brute-force attack, where attackers use lists of common credentials to gain unauthorized access.

Command:
```sh
hydra -L users.txt -P passwords.txt ssh://localhost
```
After running the command, Hydra will report any successful login attempts, showing the username and password that worked. This demonstrates how weak or reused credentials can be exploited by attackers.

**Troubleshooting:**

If you encounter a "connection refused" error when running Hydra, ensure the OpenSSH server is installed and running:

```sh
# Check if OpenSSH server is installed
dpkg -l | grep openssh-server || { 
	sudo apt-get update && sudo apt-get install -y openssh-server; 
}
# Start the SSH service if it's not running
sudo service ssh start
```

**Deliverables:**
- Screenshot: Hydra output showing the discovered login/password.
- Brief explanation (2–3 sentences) of how online brute-force differs from offline hash cracking.

> [hydra](https://www.kali.org/tools/hydra/?utm_source=chatgpt.com)
---

### 3. Traffic Capture & Analysis (3 pts)
**Goal:** Capture and analyze network packets generated by basic traffic.

In this task, you'll use `tcpdump` to monitor and record network activity on your system. By running `tcpdump`, you can see real-time packets as they travel across the network interface. Generating traffic with commands like `curl` (for HTTP) and `ssh` (for SSH) will produce different types of packets, allowing you to observe how various protocols appear in packet captures. This exercise helps you understand how network tools can be used to inspect and troubleshoot network communications, and how attackers or defenders might analyze traffic for signs of compromise or misuse.

**Instructions:**
1. In one terminal, start packet capture:

	The following command uses `tcpdump` to capture 20 packets from any network interface on your system. This allows you to observe live network traffic and analyze the types of packets being transmitted:
	```sh
	sudo tcpdump -i any -c 20
	```
2. While tcpdump is running, open another terminal and generate network traffic:
	```sh
	curl https://example.com
	ssh testuser@localhost
	```
	(You can use either or both commands to observe different types of packets.)

3. Review the tcpdump output to identify packet types such as TCP handshakes, DNS lookups, SSH, and HTTP traffic.

**Deliverables:**
- Take a screenshot of your tcpdump output showing captured packet types (e.g., TCP handshake, DNS lookup).
- Use a yellow highlight or annotation tool to mark and call out key packet types in your screenshot, especially any SSH or HTTP packets you observe.
- Briefly describe the highlighted packets and explain their significance in your answer.

---

### 4. Phishing Email Red-Flags (2 pts)
**Goal:** Learn to spot common signs of phishing in suspicious emails.

**Instructions:**
1. Open the file `phishing_email.txt` and read the email carefully.
2. Identify at least five red flags that indicate the email may be a phishing attempt. Common red flags include:
	- Generic greeting (e.g., "Dear user")
	- Suspicious or mismatched links
	- Requests for sensitive information
	- Poor spelling or grammar
	- Urgent or threatening language
	- Unexpected attachments
	- Sender address that doesn't match the organization
3. For each red flag, briefly explain why it is suspicious.
4. In your answer, write a short paragraph listing the five red flags you found and describe how a user can verify if an email is legitimate (e.g., checking the sender's address, hovering over links, contacting the organization directly).

**Deliverable:**
- Short paragraph listing at least five red flags and how a user should verify legitimacy.

---

## Report Template
Fill out `yourAnswers.md` as you complete each task.
