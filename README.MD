# Lab 2: Scanning, Exploitation, and Web Attacks (25 Points)

This lab is a hands-on exercise in selected **CEH v13** techniques and current incident patterns: network scanning, packet sniffing, password cracking, online brute force, denial of service, session hijacking, web reconnaissance, SQL injection, cryptography, stolen API tokens, API object-level access control, and cloud IAM mistakes.

You complete all work in a GitHub Codespace. The required tools are already installed, and the target services start on **localhost only**.

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
2. Make the lab scripts executable:

	```sh
	chmod +x scripts/*.sh apps/*.sh
	```

3. Start all lab services:

	```sh
	bash scripts/start_services.sh
	```

	The script should report that every lab port is listening. After that, open the **Ports** tab in Codespaces (or VS Code) and use **Open in Browser** on 8000, 8080, 8081, 5001, 5002, or 5003 to view those pages. Keep those ports **private**; do not make them public.

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

**How to read the tasks.** Each task explains the idea, then what you do. **Deliverable filenames** are required (the auto-grader looks for those exact names). Worked commands are **examples against a different host**. Adapt the tool, flags, and target to this lab. Use `--help` or the linked man page if a flag is unclear. 

---

## Tasks

### 1. Network scanning and enumeration (2 pts)

**Objective:** Discover which TCP services are listening on localhost.

**What is going on.** Before exploiting anything, an ethical hacker **scans** the target: which ports are open, and what is speaking on them. Nmap sends TCP connection attempts (a **TCP connect** scan, `-sT`) and can probe for **service/version** banners (`-sV`). The result is a map of the attack surface.

In this lab you scan **127.0.0.1 only**, and only from the **GitHub Codespace terminal**. A scan of your laptop’s localhost will usually show port 22 and miss the lab apps. Start the listeners first (`bash scripts/start_services.sh`). Several lab HTTP services use ports **above 1000** (all below 10000), so a default or `1-1000` range is not enough.

Python/Flask apps often make Nmap print `service unrecognized despite returning data`. That is normal. The grader only requires the ports to be **open**, not a named fingerprint.

**`nmap_scan.txt` is not created for you.** Nmap prints to the terminal unless you save **normal** output with `-oN`. The grader does not run Nmap.

**What you do.** Scan `127.0.0.1` with a TCP connect scan, version detection, and a port range that covers the lab services. Save the report as `nmap_scan.txt` in the repository root.

Example against another host (keep a wide port range and `-oN` when you adapt it):

```sh
nmap -sT -sV -p 1-10000 10.0.0.5 -oN example_scan.txt
```

**Deliverables:**

- `nmap_scan.txt` at the repository root, created by you from Nmap (auto-graded). Every lab TCP port must appear as `open`.
- Short port-to-service list in `yourAnswers.md`.
- Two to three sentences on why ethical hackers scan before exploitation.

**Check:** `bash scripts/grade_task1_scan.sh`

Tool reference: [Nmap](https://nmap.org/book/man.html)

---

### 2. Packet sniffing (2 pts)

**Objective:** Capture plaintext HTTP on loopback and recover a secret from the traffic.

**What is going on.** **Sniffing** means recording packets on a network interface and reading their contents. If an application uses **plaintext HTTP** (no TLS), anyone who can see the path can read URLs, cookies, and response bodies. Defenders use the same technique to troubleshoot and to detect leaks.

This lab has a small HTTP service on **port 8081**. A normal request returns a confidential `FLAG{...}` in the body. You capture that traffic on the **loopback** interface (`lo`) only. Do not send test traffic to external websites.

**`sniff_capture.log` and `sniff_flag.txt` are not created for you.** tcpdump prints packets (or writes a file you name). You must save an ASCII capture and extract the flag. The grader does not run tcpdump or curl.

**What you do.**

1. In one terminal, capture loopback traffic for port 8081 in ASCII (`tcpdump -A`) and write it to `sniff_capture.log`.
2. In a second terminal, request `http://localhost:8081/` so packets appear in the capture.
3. Copy the `FLAG{...}` value out of the capture into `sniff_flag.txt`. The grader checks **both** files.

Example of an ASCII capture on another interface (adapt interface and port):

```sh
sudo tcpdump -i eth0 -A -s 0 -c 20 'tcp port 80'
```

**Deliverables:**

- `sniff_capture.log` and `sniff_flag.txt` at the repository root, created by you (auto-graded).
- Screenshot of the capture showing the token in transit.
- Two to three sentences in `yourAnswers.md` on why plaintext HTTP exposes secrets to anyone on the path.

**Check:** `bash scripts/grade_task2_sniff.sh`

Tool reference: [tcpdump](https://www.tcpdump.org/manpages/tcpdump.1.html)

---

### 3. Hash cracking with John the Ripper (2 pts)

**Objective:** Recover the Unix password that produced the hash in `hash.txt`.

**What is going on.** `hash.txt` is a stolen `/etc/shadow`-style hash. The `$6$` prefix means SHA-512 crypt: a one-way function, so you cannot “decrypt” it. You guess a password, hash the guess the same way, and see if the results match.

Attackers almost never try every possible string. They use a **dictionary attack**: a list of likely passwords (leaks, defaults, and common choices). John the Ripper reads each line of a wordlist, hashes it, and compares it with `hash.txt` until one guess hits.

This lab already includes that dictionary. **`wordlist.txt`** in the repository root has 20 candidate passwords, one per line. One of them is the password that matches `hash.txt`. You do not need to create or download a wordlist.

**`cracked_hash.txt` is not created for you.** John prints results in the terminal. You must save `john --show` yourself. The grader does not run John.

**What you do.** Point John at `hash.txt` using `wordlist.txt`. When it finishes, save `john --show` output as `cracked_hash.txt`.

Example against other files (adapt the names):

```sh
john --wordlist=wordlist.txt hashes.txt
john --show hashes.txt > cracked.txt
```

**Deliverables:**

- `cracked_hash.txt` at the repository root, created by you from `john --show` (auto-graded; must contain the `username:password` line).
- Screenshot of the cracked `username:password` line.
- Two to three sentences in `yourAnswers.md` on what the `$6$` prefix means (SHA-512 crypt) and why a short wordlist still works against weak passwords.

**Check:** `bash scripts/grade_task3_hash.sh`

Tool reference: [John the Ripper](https://www.openwall.com/john/)

---

### 4. SSH dictionary attack with Hydra (2 pts)

**Objective:** Find a valid SSH username and password on the local SSH service.

**What is going on.** Task 3 was **offline**: you already had the hash, so John never talked to a server. This task is **online**. The password is stored on the SSH service. Each guess is a real login attempt: Hydra opens a connection to SSH, tries a username and password, and reads whether the server accepts or rejects it.

That difference matters. An online attack is slower, shows up in logs, and can trigger lockouts or rate limits. It also works when you do *not* have a stolen hash, only a reachable login service. Hydra is a common tool for that: it takes a list of usernames (`-L`) and a list of passwords (`-P`) and tries combinations against a protocol such as SSH.

In this lab the target is **SSH on localhost only** (the service you started in Getting started). **`users.txt`** and **`passwords.txt`** are already in the repository root (usernames and password guesses). They are separate from Task 3’s `wordlist.txt`. One username and one password in those files form a valid SSH login. Do not point Hydra at any host other than localhost.

**`hydra_ssh.txt` is not created for you.** Hydra only prints results in the terminal. You must save that output yourself (the grader does not run Hydra).

**What you do.** Run Hydra against `ssh://localhost` using `users.txt` (`-L`) and `passwords.txt` (`-P`). Redirect **stdout and stderr** into `hydra_ssh.txt` in the repository root. The saved file must still show Hydra’s successful `login` and `password` lines.

Example against another host (adapt the target; note how the output is saved):

```sh
hydra -L users.txt -P passwords.txt ssh://10.0.0.8 2>&1 | tee hydra_out.txt
```

If you see `connection refused`, SSH is not running. Start it with `sudo service ssh start`, or restart every lab service:

```sh
bash scripts/start_services.sh
```

**Deliverables:**

- `hydra_ssh.txt` at the repository root, created by you from Hydra’s output (auto-graded).
- Screenshot of Hydra reporting the valid login.
- Two to three sentences in `yourAnswers.md` comparing this *online* attack with the *offline* crack in Task 3 (network traffic, logs, lockouts, and speed).

**Check:** `bash scripts/grade_task4_hydra.sh`

Tool reference: [Hydra](https://www.kali.org/tools/hydra/)

---

### 5. Denial-of-service simulation (2 pts)

**Objective:** Measure what happens when a local web service is flooded with HTTP requests.

**What is going on.** A denial-of-service (DoS) attack tries to make a service slow or unavailable by exhausting something it needs: CPU, memory, sockets, or bandwidth. A **volumetric HTTP flood** does that at the application layer: many clients (or one tool pretending to be many) send a large number of HTTP requests at once. That is different from a SYN flood (half-open TCP handshakes) or an ICMP flood (ping packets), but the idea is the same: more work than the target can finish.

This lab uses a small app on **port 8080** only. It is not the public internet. Each request to `/` increments a counter and waits a short time, like a busy backend. `/stats` returns JSON with how many requests arrived. `/reset` clears the counter so you can start a clean run.

ApacheBench (`ab`) is a load-testing tool. Attackers use similar “many requests, many connections” patterns; here you use it against localhost so you can read the impact from `/stats`.

**`dos_report.json` is not created for you.** `/stats` only prints JSON in the terminal (or browser). You must save that JSON yourself. The grader does not run the flood.

**What you do.**

1. Reset the counter on the local app so old traffic is not counted.
2. Use `ab` to send on the order of **1000** requests with many concurrent connections to `http://localhost:8080/` (the grader expects a high count, not a few manual `curl`s).
3. Fetch `/stats` and save the JSON as `dos_report.json` in the repository root.

Example against another URL (adapt host, count, and concurrency; note saving output):

```sh
ab -n 500 -c 10 http://10.0.0.8/
curl -s http://10.0.0.8/stats -o stats.json
```

If the app does not respond, start lab services:

```sh
bash scripts/start_services.sh
```

**Deliverables:**

- `dos_report.json` at the repository root, created by you from `/stats` (auto-graded).
- Screenshot of your `ab` output.
- Two to three sentences in `yourAnswers.md` relating this HTTP flood to SYN or ICMP floods, and one reason a real DoS is harder to stop.

**Check:** `bash scripts/grade_task5_dos.sh`

Tool reference: [ApacheBench (ab)](https://httpd.apache.org/docs/2.4/programs/ab.html)

---

### 6. Session hijacking via cookie replay (3 pts)

**Objective:** Capture another user’s session cookie in transit and reuse it to open a protected page without logging in.

**What is going on.** After login, many web apps send a **session cookie** (`Set-Cookie`) so the browser can prove who it is on later requests. If that cookie travels over **plaintext HTTP**, a sniffer can copy it. **Replaying** the cookie (sending it on your own request) is application-level session hijacking: the server treats you as that user because it only checks the cookie, not a password.

In this lab a background job logs in as `admin` about every 15 seconds on **port 5001**. `/login` issues the cookie; `/account` is protected. Capture long enough to see one login.

**`session_capture.log` and `session_hijack_flag.txt` are not created for you.** You must save the tcpdump output and the replay response. The grader does not steal a cookie for you.

**What you do.**

1. Capture loopback traffic on port 5001 in ASCII (`tcpdump -A`) for about 20 seconds. Save it as `session_capture.log`.
2. Find `Set-Cookie` / `session=` in the capture.
3. Replay that cookie to `/account` **without logging in**. Save the response as `session_hijack_flag.txt`.

Example of sending a cookie to another site (adapt URL, cookie name, and value):

```sh
curl -s -b "session=00deadbeef" http://10.0.0.8/profile -o response.txt
```

If the response is `Access denied`, the cookie expired. Capture again and replay a fresh value.

**Deliverables:**

- `session_capture.log` and `session_hijack_flag.txt` at the repository root, created by you (auto-graded).
- Two to three sentences in `yourAnswers.md` on how HTTPS and short-lived session tokens would prevent this attack.

**Check:** `bash scripts/grade_task6_session.sh`

Tool reference: [tcpdump](https://www.tcpdump.org/manpages/tcpdump.1.html)

---

### 7. Web server reconnaissance (2 pts)

**Objective:** Find a web directory that is not linked from the site, then retrieve the flag inside it.

**What is going on.** Sites often hide admin panels, backups, or tools by simply **not linking** them from the homepage. Search engines and casual users never see them; scanners still find them. **Nikto** checks a web server for common misconfigurations. **Dirb** brute-forces directory names from a wordlist. An unlisted path is still a risk if the server returns it to anyone who asks.

The lab site is `http://localhost:8000`. The hidden path is **not** in the homepage HTML. **`scripts/web_wordlist.txt`** is already in the repo; you do not need to build a directory list.

**`web_recon_flag.txt` is not created for you.** You must discover the directory and save the flag file’s contents. The grader does not run Nikto or Dirb.

**What you do.** Run a web-server check (Nikto) against the local site. Brute-force directories with Dirb and `scripts/web_wordlist.txt`. When you find a directory that is not the site root, retrieve the flag file inside it and save it as `web_recon_flag.txt`.

Example against another site (adapt the URL and wordlist):

```sh
nikto -h http://10.0.0.8
dirb http://10.0.0.8/ wordlist.txt
```

**Deliverables:**

- `web_recon_flag.txt` at the repository root, created by you (auto-graded).
- Screenshot of Nikto or Dirb output showing the discovered directory.
- Two to three sentences in `yourAnswers.md` explaining why an unlinked directory is still a risk.

**Check:** `bash scripts/grade_task7_webrecon.sh`

Tool references: [Nikto](https://github.com/sullo/nikto), [Dirb](https://www.kali.org/tools/dirb/)

---

### 8. SQL injection and credential cracking (3 pts)

**Objective:** Abuse a vulnerable query to dump password hashes, then crack the admin password.

**What is going on.** The app on **port 5002** builds SQL by **concatenating** the `id` query parameter into the statement. If `id` is not treated as data only, you can change the meaning of the query. A common technique is a **UNION SELECT**: you add extra rows from another table (here, `users`) so the JSON includes `admin` and `password_hash`.

That hash is the same *kind* of hash as Task 3. After you extract it, crack it offline with John and the provided list **`scripts/sqli_wordlist.txt`**.

**`sqli_extracted_hash.txt` and `sqli_cracked_password.txt` are not created for you.** You must write them. The grader does not inject SQL or run John for this task.

**What you do.** Start with a normal request (`id=1`) and inspect the JSON fields. Then inject a UNION (or use sqlmap on the `id` parameter once you understand the injection point) so every user row appears. Save the admin hash as `sqli_extracted_hash.txt` in the form `admin:<hash>`. Crack it with John and `scripts/sqli_wordlist.txt`, then save `sqli_cracked_password.txt` as `admin:<password>`.

Example UNION against another app (adapt columns and URL to what this lab returns):

```sh
curl "http://10.0.0.8/item?id=0 UNION SELECT id,name,price FROM catalogue--"
```

Example sqlmap against another URL:

```sh
sqlmap -u "http://10.0.0.8/item?id=1" --batch --dump
```

**Deliverables:**

- `sqli_extracted_hash.txt` and `sqli_cracked_password.txt` at the repository root, created by you (auto-graded).
- Two to three sentences in `yourAnswers.md` describing one SQL injection defence (for example parameterized queries).

**Check:** `bash scripts/grade_task8_sqli.sh`

Tool reference: [sqlmap](https://sqlmap.org/)

---

### 9. Cryptography: encoding and hashing (2 pts)

**Objective:** Decode a Base64 string and recover the plaintext of a raw MD5 hash.

**What is going on.** **Encoding** (Base64) is a reversible way to write bytes as text. It is **not** encryption: anyone who sees the string can decode it with no key. **Hashing** (MD5) is one-way, but unsalted MD5 of a common password is easy to recover by hashing candidates until one matches, the same idea as Task 3.

Codespace setup writes two files in the repository root (they appear after setup finishes):

- `cipher_b64.txt`: one Base64 line
- `md5_hash.txt`: a raw MD5 digest of a word from `passwords.txt`

**`crypto_b64_flag.txt` and `crypto_md5.txt` are not created for you.** You must write the decoded flag and the cracked MD5 word. The grader does not decode or hash for you.

**What you do.** Decode the Base64 file and save the plaintext flag as `crypto_b64_flag.txt`. For the MD5 digest, hash each candidate in `passwords.txt` (for example with `openssl dgst -md5`) until one matches `md5_hash.txt`. Save that word only as `crypto_md5.txt`. Both parts are required for the 2 points.

Example against other files (adapt names):

```sh
base64 -d encoded.txt > decoded.txt
echo -n "secret" | openssl dgst -md5
```

**Deliverables:**

- `crypto_b64_flag.txt` and `crypto_md5.txt` at the repository root, created by you (auto-graded).
- Two to three sentences in `yourAnswers.md` on why Base64 is encoding, not encryption, and why unsalted MD5 is a weak password hash.

**Check:** `bash scripts/grade_task9_crypto.sh`

Tool reference: [openssl dgst](https://www.openssl.org/docs/man3.0/man1/openssl-dgst.html)

---

### 10. Stolen Bearer token replay (2 pts)

**Objective:** Recover a live API access token and call a protected endpoint without a password.

**What is going on.** Modern APIs often use **OAuth-style Bearer tokens** instead of session cookies. The client sends `Authorization: Bearer <token>`. If that token leaks (HTTP, CI logs, debug files), anyone can **replay** it, the same idea as Task 6 but with a header instead of a cookie.

The API on **port 5003** issues tokens at `/oauth/token` over plaintext HTTP. A background job requests a token about every 15 seconds and appends the JSON to `/tmp/oauth_debug.log`. `/api/me` is protected.

**`bearer_flag.txt` is not created for you.** You must recover a token and save the `/api/me` response. The grader does not call the API for you.

**What you do.** Recover an `access_token` from `/tmp/oauth_debug.log` or from an ASCII capture on port 5003. Send it as a Bearer header to `/api/me` (no password). Save the response as `bearer_flag.txt`. If you get `invalid token`, the token expired; read the log again.

Example of sending a Bearer token to another API (adapt URL and token):

```sh
curl -s -H "Authorization: Bearer 00deadbeef" http://10.0.0.8/api/profile -o response.txt
```

**Deliverables:**

- `bearer_flag.txt` at the repository root, created by you (auto-graded).
- Two to three sentences in `yourAnswers.md` on why leaking Bearer tokens is as serious as leaking a password, and one control (short expiry, TLS, or sender-constrained tokens).

**Check:** `bash scripts/grade_task10_bearer.sh`

Tool reference: [RFC 6750 Bearer tokens](https://datatracker.ietf.org/doc/html/rfc6750)

---

### 11. API IDOR (2 pts)

**Objective:** Access another user’s record by changing an object id in the API URL.

**What is going on.** **IDOR** (insecure direct object reference), also called **broken object-level authorization**, is OWASP API Top 10 issue A01. The API trusts an id in the URL (`/api/users/1`) without checking whether *you* are allowed to see that object. Changing the id can expose someone else’s data even if you never “hacked” authentication.

The same API on **port 5003** exposes `/api/users/<id>` with **no** per-object check. Id `1` is a low-privilege record. Other numeric ids exist. Look in the `notes` field for a `FLAG{...}`.

**`idor_flag.txt` is not created for you.** You must fetch the other object and save the response. The grader does not enumerate ids for you.

**What you do.** Request the guest record first, then change only the object id. Save the response that contains the flag as `idor_flag.txt`.

Example against another API (adapt host and id):

```sh
curl -s http://10.0.0.8/api/orders/1001
curl -s http://10.0.0.8/api/orders/1002
```

**Deliverables:**

- `idor_flag.txt` at the repository root, created by you (auto-graded).
- Two to three sentences in `yourAnswers.md` on why APIs must authorize each object, not only “the client called an API.”

**Check:** `bash scripts/grade_task11_idor.sh`

Tool reference: [OWASP API Security: broken object-level authorization](https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/)

---

### 12. Cloud IAM misconfiguration (1 pt)

**Objective:** Find cloud credentials that were committed by mistake, and name the IAM statement that grants every action on every resource.

**What is going on.** Real incidents often start with **secrets in git** (access keys in `.env` files) and **overbroad IAM** (`Action: *` and `Resource: *`, sometimes called “break-glass” that never got tightened). Anyone with the repo can use the key; a wildcard policy lets that key do almost anything in the account.

This is a **local simulation**. There is no real AWS or Azure account. The leaked backup is the **`cloud_lab/`** folder already in the repository (an env file and a policy JSON).

**`cloud_access_key.txt` and `iam_risk.txt` are not created for you.** You must write them. The grader does not parse `cloud_lab/` into those filenames.

**What you do.** Inspect `cloud_lab/`. Save the access key id as `cloud_access_key.txt`. In `iam_risk.txt`, quote the policy `Action` that is a wildcard (`*`). Include the word `Action` and `*`.

**Deliverables:**

- `cloud_access_key.txt` and `iam_risk.txt` at the repository root, created by you (auto-graded).
- Two to three sentences in `yourAnswers.md` on why secrets belong in a vault (not git) and why `Action: *` on `Resource: *` is dangerous.

**Check:** `bash scripts/grade_task12_iam.sh`

Tool reference: [AWS IAM security best practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

---

## Submission

Complete every section of `yourAnswers.md`, then commit and push **before** you stop the Codespace:

```sh
git add .
git commit -m "Complete lab tasks and answers"
git push
```

Confirm these files appear on GitHub: `yourAnswers.md`, screenshots, `nmap_scan.txt`, `sniff_capture.log`, `sniff_flag.txt`, `cracked_hash.txt`, `hydra_ssh.txt`, `dos_report.json`, `session_capture.log`, `session_hijack_flag.txt`, `web_recon_flag.txt`, `sqli_extracted_hash.txt`, `sqli_cracked_password.txt`, `crypto_b64_flag.txt`, `crypto_md5.txt`, `bearer_flag.txt`, `idor_flag.txt`, `cloud_access_key.txt`, and `iam_risk.txt`.
