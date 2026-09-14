# Lab 2: Scanning, Exploitation, and Web Attacks (5 Points)

Hands-on practice with selected **CEH v13** techniques: network scanning, packet sniffing, password cracking, online brute force, denial of service, session hijacking, web reconnaissance, and SQL injection.

All work is performed in a GitHub Codespace. Required tools are pre-installed, and the target services start automatically on **localhost only**.

> **Authorized use only.** Attack only the lab services listed below. Do not scan, flood, or exploit any system you do not own or lack written permission to test.

---

## Learning outcomes

After this lab you will be able to:

1. Scan a host, enumerate services, and interpret captured packets.
2. Recover weak credentials offline (hash cracking) and online (SSH brute force).
3. Measure the impact of an HTTP flood on a local service.
4. Steal and replay a session cookie sent over plaintext HTTP.
5. Discover a hidden web resource and exploit SQL injection to crack a password.

---

## CEH v13 alignment

| Task | Lab activity | CEH v13 module | Pts |
|---|---|---|---|
| 1 | Host/service enumeration (Nmap) and packet capture (tcpdump) | 03 Scanning Networks; 04 Enumeration; 08 Sniffing | 1 |
| 2 | Offline hash cracking (John) and SSH dictionary attack (Hydra) | 06 System Hacking | 1 |
| 3 | HTTP flood simulation | 10 Denial-of-Service | 1 |
| 4 | Session cookie theft and replay | 11 Session Hijacking | 1 |
| 5 | Web server recon (Nikto, Dirb) and SQL injection | 13 Hacking Web Servers; 14 Hacking Web Applications; 15 SQL Injection | 1 |

---

## Getting started

1. Open this repository in GitHub Codespaces and wait for setup to finish.
2. Confirm the lab services are running:

	```sh
	ps aux | grep -E "sshd|dos_target|session_app|vuln_login_app|http.server"
	tail -n +1 /tmp/sshd.log /tmp/dos_target.log /tmp/session_app.log /tmp/vuln_login_app.log /tmp/webrecon.log
	```

3. If a service is missing (common after a stopped Codespace), restart them:

	```sh
	bash scripts/start_services.sh
	```

4. If helper scripts are not executable:

	```sh
	chmod +x scripts/*.sh apps/*.sh
	```

---

## Lab services

| Service | Address | Used in |
|---|---|---|
| SSH | `127.0.0.1:22` (user `testuser`) | Task 2 |
| DoS target | `http://localhost:8080` (`/`, `/stats`, `/reset`) | Task 3 |
| Session app | `http://localhost:5001` (`/login`, `/account`) | Task 4 |
| Web recon site | `http://localhost:8000` | Task 5 |
| SQL injection app | `http://localhost:5002` (`/user?id=`) | Task 5 |

Task 1 scans all of the services above. Do not enable port forwarding.

---

## How you are graded

Each task is worth **1 point**. Maximum score is **5**. Record written answers and screenshot links in `yourAnswers.md`. Check file-based tasks at any time:

```sh
bash scripts/grade_all.sh
```

Task 1 also requires a tcpdump screenshot in `yourAnswers.md`. The auto-grader awards the Task 1 point from `nmap_scan.txt`.

**How to read the tasks.** Objectives, constraints, and **deliverable filenames** are required (the auto-grader looks for those exact names). Worked commands are **examples against a different host**. Adapt the tool, flags, and target to this lab. Use `--help` or the linked man page if a flag is unclear.

---

## Tasks

### 1. Scanning and sniffing (1 pt)

**Objective:** Capture localhost packets and enumerate the lab’s listening TCP services.

**Constraints:** Scan and sniff **127.0.0.1 / loopback only**. Do not send test traffic to external websites.

**Part A: packet capture**

1. In one terminal, capture a short burst of packets on the **loopback** interface (enough to see a TCP handshake). Limit the capture with a packet count so it stops on its own.
2. In a second terminal, generate **local** traffic while the capture is running (HTTP to a lab URL, and/or an SSH attempt to localhost). An SSH attempt may fail without a password; that is fine if it still produces packets.
3. In the output, identify a TCP handshake (`SYN`, `SYN-ACK`, `ACK`) and HTTP or SSH traffic.

Example against another interface (adapt the interface and packet count):

```sh
sudo tcpdump -i eth0 -c 20
```

**Part B: Nmap enumeration**

1. Confirm lab services are running (`bash scripts/start_services.sh` if needed).
2. Run a **TCP connect** scan with **service/version** detection against `127.0.0.1`. The lab ports are all below 10000.
3. Save Nmap **normal** output (`-oN`) as `nmap_scan.txt` in the repository root.

Example against another host (do not use this target):

```sh
nmap -sT -sV -p 1-1000 10.0.0.5 -oN example_scan.txt
```

**Deliverables:**

- Screenshot of the capture with key packet types highlighted, plus a short description in `yourAnswers.md`.
- `nmap_scan.txt` at the repository root (auto-graded). Every lab TCP port must appear as `open`.
- Short port-to-service list in `yourAnswers.md`.

**Check:** `bash scripts/grade_task1_scan.sh`

Tool references: [tcpdump](https://www.tcpdump.org/manpages/tcpdump.1.html), [Nmap](https://nmap.org/book/man.html)

---

### 2. Password cracking and SSH brute force (1 pt)

**Objective:** Recover the password in `hash.txt`, then recover the same login with an online SSH dictionary attack on localhost.

**Part A: offline crack (John the Ripper)**

Use John with the provided wordlist `passwords.txt` against `hash.txt`, then display any cracked credentials.

Example against other files (adapt the names):

```sh
john --wordlist=wordlist.txt hashes.txt
john --show hashes.txt
```

**Part B: online attack (Hydra)**

Use Hydra with `users.txt` and `passwords.txt` against **SSH on localhost**. Look for a valid `login` and `password` in the output.

Example against another host (do not use this target):

```sh
hydra -L users.txt -P passwords.txt ssh://10.0.0.8
```

If you see `connection refused`, SSH is not running. Start it with `sudo service ssh start`, or restart every lab service:

```sh
bash scripts/start_services.sh
```

**Deliverables:**

- Screenshots of the cracked `username:password` line and of Hydra reporting the valid login.
- Two to three sentences in `yourAnswers.md` on what `$6$` means (SHA-512 crypt) and how this *online* attack differs from the *offline* crack (rate limits, lockouts, network noise).

Both parts must succeed for the point.

**Check:** `bash scripts/grade_task2_creds.sh`

Tool references: [John the Ripper](https://www.openwall.com/john/), [Hydra](https://www.kali.org/tools/hydra/)

---

### 3. Denial-of-service simulation (1 pt)

**Objective:** Send a high volume of HTTP requests to the local test app and record the impact.

The Flask app on port 8080 counts requests. Useful paths: `/` (counted), `/stats` (JSON totals), `/reset` (clears the counter).

**Hints:**

- Reset the counter before a scored run so your numbers are clean.
- Use ApacheBench (`ab`) to send on the order of **1000** requests with many concurrent connections. The grader expects a high request count in the saved stats (well above a handful of manual `curl`s).
- Save the `/stats` JSON as `dos_report.json` in the repository root.

Example against another URL (adapt host, count, and concurrency):

```sh
ab -n 500 -c 10 http://10.0.0.8/
```

You may optionally watch the flood on loopback with tcpdump while `ab` runs.

**Deliverables:**

- `dos_report.json` at the repository root (auto-graded).
- Screenshot of `ab` or tcpdump output.
- Two to three sentences in `yourAnswers.md` relating this HTTP flood to SYN or ICMP floods, and one reason a real DoS is harder to stop.

**Check:** `bash scripts/grade_task3_dos.sh`

---

### 4. Session hijacking via cookie replay (1 pt)

**Objective:** Capture an in-transit session cookie and reuse it to reach a protected page without logging in.

A background script logs in as `admin` about every 15 seconds over **plaintext HTTP** on port 5001 (`/login` issues a cookie; `/account` is protected).

**Hints:**

1. Capture loopback traffic on **port 5001** in ASCII (`tcpdump -A`) for about 20 seconds so at least one login appears. Save the capture to a log file you can search.
2. Find the session cookie in the HTTP headers (look for `Set-Cookie` / a `session=` value).
3. Replay that cookie to `/account` **without logging in**. Save the response as `session_hijack_flag.txt` in the repository root.

Example of sending a cookie to another site (adapt URL, cookie name, and value):

```sh
curl -s -b "session=00deadbeef" http://10.0.0.8/profile -o response.txt
```

If the response is `Access denied`, the cookie expired. Capture again and replay a fresh value.

**Deliverables:**

- `session_hijack_flag.txt` at the repository root (auto-graded).
- Two to three sentences in `yourAnswers.md` on how HTTPS and short-lived session tokens would prevent this attack.

**Check:** `bash scripts/grade_task4_session.sh`

---

### 5. Web reconnaissance and SQL injection (1 pt)

**Objective:** Find an unlisted web resource, then exploit a vulnerable query to dump hashes and crack the admin password.

**Part A: web reconnaissance**

A static site is served at `http://localhost:8000`. The hidden path is **not** linked from the homepage.

**Hints:**

- Run a web-server check (Nikto) against the local site.
- Brute-force directories with Dirb and the lab wordlist `scripts/web_wordlist.txt`.
- When you find a directory that is not the site root, retrieve the flag file inside it and save the contents as `web_recon_flag.txt`.

Example against another site (adapt the URL and wordlist):

```sh
nikto -h http://10.0.0.8
dirb http://10.0.0.8/ wordlist.txt
```

**Part B: SQL injection**

The app on port 5002 builds SQL with string concatenation on `/user?id=`. Start with a normal request (`id=1`) and inspect the JSON fields.

**Hints:**

- The endpoint is vulnerable to a **UNION**-based injection. Your payload must return extra rows so `admin` and `password_hash` appear in the response. Comment out the remainder of the original query if needed.
- You may instead use sqlmap against the `id` parameter once you understand the injection point.
- Save the admin hash as `sqli_extracted_hash.txt` in this exact format: `admin:<hash>`
- Crack it with John and `scripts/sqli_wordlist.txt`, then save `sqli_cracked_password.txt` as `admin:<password>`

Example UNION against another app (adapt columns and URL to what this lab returns):

```sh
curl "http://10.0.0.8/item?id=0 UNION SELECT id,name,price FROM catalogue--"
```

Example sqlmap against another URL:

```sh
sqlmap -u "http://10.0.0.8/item?id=1" --batch --dump
```

**Deliverables:**

- `web_recon_flag.txt`, `sqli_extracted_hash.txt`, and `sqli_cracked_password.txt` at the repository root (auto-graded).
- Screenshot of Nikto or Dirb output showing the discovered directory.
- In `yourAnswers.md`: why an unlinked directory is still a risk, and one SQL injection defence (for example parameterized queries).

Both parts must succeed for the point.

**Check:** `bash scripts/grade_task5_web.sh`

---

## Submission

Complete every section of `yourAnswers.md`, then commit and push **before** you stop the Codespace:

```sh
git add .
git commit -m "Complete lab tasks and answers"
git push
```

Confirm the files appear on GitHub: `yourAnswers.md`, screenshots, `nmap_scan.txt`, `dos_report.json`, `session_hijack_flag.txt`, `web_recon_flag.txt`, `sqli_extracted_hash.txt`, and `sqli_cracked_password.txt`.
