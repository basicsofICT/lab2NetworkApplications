# Lab 2: Scanning, Exploitation, and Web Attacks (25 Points)

Hands-on practice with selected **CEH v13** techniques and current incident patterns: network scanning, packet sniffing, password cracking, online brute force, denial of service, session hijacking, web reconnaissance, SQL injection, cryptography, stolen API tokens, API object-level access control, and cloud IAM mistakes.

All work is performed in a GitHub Codespace. Required tools are pre-installed, and the target services start automatically on **localhost only**.

> **Authorized use only.** Attack only the lab services listed below. Do not scan, flood, or exploit any system you do not own or lack written permission to test.

---

## Learning outcomes

After this lab you will be able to:

1. Enumerate localhost TCP services with Nmap.
2. Capture plaintext HTTP and recover a secret from the traffic.
3. Crack a Unix SHA-512 crypt hash offline.
4. Perform an SSH dictionary attack.
5. Measure the impact of an HTTP flood.
6. Steal and replay a session cookie sent over plaintext HTTP.
7. Discover an unlisted web directory.
8. Exploit SQL injection to extract and crack a password hash.
9. Decode Base64 and crack a raw MD5 hash.
10. Replay a stolen Bearer access token against an API.
11. Abuse an API IDOR (broken object-level authorization) flaw.
12. Find leaked cloud credentials and an overpermissive IAM policy.

---

## CEH v13 alignment

| Task | Lab activity | CEH v13 module | Pts |
|---|---|---|---|
| 1 | Host and service enumeration (Nmap) | 03 Scanning Networks; 04 Enumeration | 2 |
| 2 | Packet capture and credential/flag recovery (tcpdump) | 08 Sniffing | 2 |
| 3 | Offline hash cracking (John the Ripper) | 06 System Hacking | 2 |
| 4 | SSH dictionary attack (Hydra) | 06 System Hacking | 2 |
| 5 | HTTP flood simulation | 10 Denial-of-Service | 2 |
| 6 | Session cookie theft and replay | 11 Session Hijacking | 3 |
| 7 | Web server recon (Nikto, Dirb) | 13 Hacking Web Servers; 14 Hacking Web Applications | 2 |
| 8 | SQL injection and hash cracking | 15 SQL Injection | 3 |
| 9 | Base64 decoding and MD5 cracking | 20 Cryptography | 2 |
| 10 | Stolen Bearer token replay | 11 Session Hijacking; 14 Hacking Web Applications | 2 |
| 11 | API IDOR (broken object-level authorization) | 14 Hacking Web Applications | 2 |
| 12 | Leaked cloud credentials and wildcard IAM | 19 Cloud Computing | 1 |

---

## Getting started

1. Open this repository in GitHub Codespaces and wait for setup to finish.
2. Confirm the lab services are running:

	```sh
	ps aux | grep -E "sshd|dos_target|session_app|vuln_login_app|sniff_target|modern_api|http.server"
	tail -n +1 /tmp/sshd.log /tmp/dos_target.log /tmp/session_app.log /tmp/vuln_login_app.log /tmp/sniff_target.log /tmp/modern_api.log /tmp/webrecon.log
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
| SSH | `127.0.0.1:22` (user `testuser`) | Task 4 |
| Sniff target | `http://localhost:8081` | Task 2 |
| DoS target | `http://localhost:8080` (`/`, `/stats`, `/reset`) | Task 5 |
| Session app | `http://localhost:5001` (`/login`, `/account`) | Task 6 |
| Web recon site | `http://localhost:8000` | Task 7 |
| SQL injection app | `http://localhost:5002` (`/user?id=`) | Task 8 |
| Modern API | `http://localhost:5003` (`/oauth/token`, `/api/me`, `/api/users/<id>`) | Tasks 10 and 11 |

---

## How you are graded

Maximum score is **25**. All twelve tasks are auto-graded from files you create. Record written answers and screenshot links in `yourAnswers.md`. Check your score at any time:

```sh
bash scripts/grade_all.sh
```

**How to read the tasks.** Objectives, constraints, and **deliverable filenames** are required (the auto-grader looks for those exact names). Worked commands are **examples against a different host**. Adapt the tool, flags, and target to this lab. Use `--help` or the linked man page if a flag is unclear. 

---

## Tasks

### 1. Network scanning and enumeration (2 pts)

**Objective:** Discover which TCP services are listening on localhost. Scan **127.0.0.1 only**.

**Hints:**

- Confirm lab services are running (`bash scripts/start_services.sh` if needed).
- Run a **TCP connect** scan with **service/version** detection. The lab ports are all below 10000.
- Save Nmap **normal** output (`-oN`) as `nmap_scan.txt` in the repository root.

Example against another host (do not use this target):

```sh
nmap -sT -sV -p 1-1000 10.0.0.5 -oN example_scan.txt
```

**Deliverables:**

- `nmap_scan.txt` at the repository root (auto-graded). Every lab TCP port must appear as `open`.
- Short port-to-service list in `yourAnswers.md`.
- Two to three sentences on why ethical hackers scan before exploitation.

**Check:** `bash scripts/grade_task1_scan.sh`

Tool reference: [Nmap](https://nmap.org/book/man.html)

---

### 2. Packet sniffing (2 pts)

**Objective:** Capture plaintext HTTP on loopback and recover a secret from the traffic.

**Constraints:** Sniff **loopback only**. Do not send test traffic to external websites.

A small HTTP service on port **8081** returns a confidential token in the response body.

**Hints:**

1. In one terminal, capture loopback traffic for port 8081 in ASCII (`tcpdump -A`) and save it to a log you can search.
2. In a second terminal, request `http://localhost:8081/` so packets appear in the capture.
3. Extract the `FLAG{...}` value from the capture (not only from `curl` on screen) and save it as `sniff_flag.txt`.

Example of an ASCII capture on another interface (adapt interface and port):

```sh
sudo tcpdump -i eth0 -A -s 0 -c 20 'tcp port 80'
```

**Deliverables:**

- `sniff_flag.txt` at the repository root (auto-graded).
- Screenshot of the capture showing the token in transit.
- Two to three sentences in `yourAnswers.md` on why plaintext HTTP exposes secrets to anyone on the path.

**Check:** `bash scripts/grade_task2_sniff.sh`

Tool reference: [tcpdump](https://www.tcpdump.org/manpages/tcpdump.1.html)

---

### 3. Hash cracking with John the Ripper (2 pts)

**Objective:** Recover the password stored in `hash.txt` using the wordlist `passwords.txt`.

**Hints:**

- Point John at `hash.txt` with `--wordlist`.
- Display cracked credentials after the run.

Example against other files (adapt the names):

```sh
john --wordlist=wordlist.txt hashes.txt
john --show hashes.txt
```

**Deliverables:**

- Screenshot of the cracked `username:password` line.
- Two to three sentences in `yourAnswers.md` on what the `$6$` prefix means (SHA-512 crypt).

**Check:** `bash scripts/grade_task3_hash.sh`

Tool reference: [John the Ripper](https://www.openwall.com/john/)

---

### 4. SSH dictionary attack with Hydra (2 pts)

**Objective:** Recover a valid SSH login on localhost using `users.txt` and `passwords.txt`.

**Hints:**

- Use Hydra against **SSH on localhost**.
- Look for a valid `login` and `password` in the output.

Example against another host (do not use this target):

```sh
hydra -L users.txt -P passwords.txt ssh://10.0.0.8
```

If you see `connection refused`, SSH is not running. Start it with `sudo service ssh start`, or restart every lab service:

```sh
bash scripts/start_services.sh
```

**Deliverables:**

- Screenshot of Hydra reporting the valid login.
- Two to three sentences in `yourAnswers.md` comparing this *online* attack with the *offline* crack in Task 3 (rate limits, lockouts, network noise).

**Check:** `bash scripts/grade_task4_hydra.sh`

Tool reference: [Hydra](https://www.kali.org/tools/hydra/)

---

### 5. Denial-of-service simulation (2 pts)

**Objective:** Send a high volume of HTTP requests to the local test app and record the impact.

The Flask app on port 8080 counts requests. Useful paths: `/` (counted), `/stats` (JSON totals), `/reset` (clears the counter).

**Hints:**

- Reset the counter before a scored run so your numbers are clean.
- Use ApacheBench (`ab`) to send on the order of **1000** requests with many concurrent connections. The grader expects a high request count (well above a handful of manual `curl`s).
- Save the `/stats` JSON as `dos_report.json` in the repository root.

Example against another URL (adapt host, count, and concurrency):

```sh
ab -n 500 -c 10 http://10.0.0.8/
```

**Deliverables:**

- `dos_report.json` at the repository root (auto-graded).
- Screenshot of `ab` output.
- Two to three sentences in `yourAnswers.md` relating this HTTP flood to SYN or ICMP floods, and one reason a real DoS is harder to stop.

**Check:** `bash scripts/grade_task5_dos.sh`

---

### 6. Session hijacking via cookie replay (3 pts)

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

**Check:** `bash scripts/grade_task6_session.sh`

---

### 7. Web server reconnaissance (2 pts)

**Objective:** Find an unlisted resource on the local web server.

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

**Deliverables:**

- `web_recon_flag.txt` at the repository root (auto-graded).
- Screenshot of Nikto or Dirb output showing the discovered directory.
- Two to three sentences in `yourAnswers.md` explaining why an unlinked directory is still a risk.

**Check:** `bash scripts/grade_task7_webrecon.sh`

---

### 8. SQL injection and credential cracking (3 pts)

**Objective:** Exploit a vulnerable query to dump hashes, then crack the admin password.

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

- `sqli_extracted_hash.txt` and `sqli_cracked_password.txt` at the repository root (auto-graded).
- Two to three sentences in `yourAnswers.md` describing one SQL injection defence (for example parameterized queries).

**Check:** `bash scripts/grade_task8_sqli.sh`

---

### 9. Cryptography: encoding and hashing (2 pts)

**Objective:** Decode a Base64 ciphertext and crack a raw MD5 hash (CEH Module 20).

Setup creates two files in the repository root:

- `cipher_b64.txt`: a single Base64 line
- `md5_hash.txt`: a raw MD5 digest of a word from `passwords.txt`

**Hints:**

- Decode the Base64 file and save the plaintext flag as `crypto_b64_flag.txt`.
- The MD5 file is a **raw MD5** of one word in `passwords.txt`. Hash each candidate (for example with `openssl dgst -md5`) until the digest matches `md5_hash.txt`.
- Save the matching word as `crypto_md5.txt` (the password word only).

Example decode and hash against other files (adapt names):

```sh
base64 -d encoded.txt > decoded.txt
echo -n "secret" | openssl dgst -md5
```

**Deliverables:**

- `crypto_b64_flag.txt` and `crypto_md5.txt` at the repository root (auto-graded).
- Two to three sentences in `yourAnswers.md` on why Base64 is encoding, not encryption, and why unsalted MD5 is a weak password hash.

Both parts must succeed for the 2 points.

**Check:** `bash scripts/grade_task9_crypto.sh`

---

### 10. Stolen Bearer token replay (2 pts)

**Objective:** Recover a live API access token and reuse it as a Bearer credential (modern analogue of cookie theft / OAuth token leak).

The API on port **5003** issues tokens at `/oauth/token` over plaintext HTTP. A background job requests a token about every 15 seconds and appends the JSON to `/tmp/oauth_debug.log`. The protected resource is `/api/me`.

**Hints:**

- Recover an `access_token` from the debug log or from an ASCII packet capture on port 5003.
- Send that value in an `Authorization: Bearer ...` header. You should not need a password.
- Save the API response as `bearer_flag.txt`.

Example of sending a Bearer token to another API (adapt URL and token):

```sh
curl -s -H "Authorization: Bearer 00deadbeef" http://10.0.0.8/api/profile -o response.txt
```

If you get `invalid token`, the token expired. Capture or read the log again.

**Deliverables:**

- `bearer_flag.txt` at the repository root (auto-graded).
- Two to three sentences in `yourAnswers.md` on why leaking Bearer tokens (logs, CI output, or HTTP) is as serious as leaking a password, and one control (short expiry, TLS, sender-constrained tokens).

**Check:** `bash scripts/grade_task10_bearer.sh`

---

### 11. API IDOR (2 pts)

**Objective:** Abuse broken object-level authorization on a user API (OWASP API Top 10).

The same API on port 5003 exposes `/api/users/<id>` **without** checking who is asking. A low-privilege record is id `1`. Other numeric ids exist.

**Hints:**

- Request the guest/user object you are expected to see first, then change only the object id.
- Look for a `FLAG{...}` in another user's `notes` field.
- Save that flag as `idor_flag.txt`.

Example against another API (adapt host and id):

```sh
curl -s http://10.0.0.8/api/orders/1001
curl -s http://10.0.0.8/api/orders/1002
```

**Deliverables:**

- `idor_flag.txt` at the repository root (auto-graded).
- Two to three sentences in `yourAnswers.md` on why APIs must enforce authorization per object, not only "the request looks authenticated."

**Check:** `bash scripts/grade_task11_idor.sh`

---

### 12. Cloud IAM misconfiguration (1 pt)

**Objective:** Find credentials that were committed by mistake and name the IAM statement that grants every action on every resource.

This is a **local simulation** of a cloud IAM incident. There is no real AWS/Azure account. Inspect the `cloud_lab/` folder.

**Hints:**

- Treat `cloud_lab/` as a leaked developer backup (env file plus a policy document).
- Save the access key id as `cloud_access_key.txt`.
- In `iam_risk.txt`, quote the policy `Action` that is a wildcard (`*`). Include the word `Action` and `*`.

**Deliverables:**

- `cloud_access_key.txt` and `iam_risk.txt` at the repository root (auto-graded).
- Two to three sentences in `yourAnswers.md` on why secrets belong in a vault (not git) and why `Action: *` on `Resource: *` is dangerous.

**Check:** `bash scripts/grade_task12_iam.sh`

---

## Submission

Complete every section of `yourAnswers.md`, then commit and push **before** you stop the Codespace:

```sh
git add .
git commit -m "Complete lab tasks and answers"
git push
```

Confirm these files appear on GitHub: `yourAnswers.md`, screenshots, `nmap_scan.txt`, `sniff_flag.txt`, `dos_report.json`, `session_hijack_flag.txt`, `web_recon_flag.txt`, `sqli_extracted_hash.txt`, `sqli_cracked_password.txt`, `crypto_b64_flag.txt`, `crypto_md5.txt`, `bearer_flag.txt`, `idor_flag.txt`, `cloud_access_key.txt`, and `iam_risk.txt`.
