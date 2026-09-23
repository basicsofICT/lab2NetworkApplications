# Lab 2: Scanning, Exploitation, and Web Attacks (25 Points + 3 optional bonus)

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
| Bonus | Optional screenshots and short write-up in `yourAnswers.md` |  | 3 |

---

## Getting started

1. Open this repository in GitHub Codespaces and wait for setup to finish.
2. Make the lab scripts executable:

	```sh
	chmod +x scripts/*.sh apps/*.sh
	# make the lab scripts executable
	```

3. Start all lab services:

	```sh
	bash scripts/start_services.sh
	# start every local lab service
	```

	The script should report that every lab port is listening. After that, open the **Ports** tab in Codespaces and use **Open in Browser** on 8000, 8080, 8081, 5001, 5002, or 5003. Keep those ports **private**; do not make them public.

	If the browser shows **404: Service not found**, the app is still running. That page is the Codespace preview for `/`. Restart the services, then open the port again from the **Ports** tab (do not type `localhost:5001` in your laptop browser). Private preview URLs only work while you are signed in to GitHub. The lab tasks themselves use the **Codespace terminal** (`curl`, `tcpdump`), where `http://localhost:5001` works even if the preview tab does not.

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

## Scoring

The twelve practical tasks are worth **25**, from the files named in each task. Check that score at any time:

```sh
bash scripts/grade_all.sh
# print your score for the twelve practical tasks
```

Screenshots and the two-to-three-sentence explanations in `yourAnswers.md` are **optional**. They are not required to earn the 25. If you complete that write-up (screenshots plus the short answers), you can earn a **3-point bonus** (28 in total).

If you do the bonus, save images in the `screenshots/` folder and embed them in `yourAnswers.md`. Example:

```md
![tcpdump capture showing the token](screenshots/task2.png)
```

**How to read the tasks.** Each task explains the idea, then what you do. Use the **deliverable filenames** given in each task. Worked commands are **examples against a different host**. Adapt the tool, flags, and target to this lab. Use `--help` or the linked man page if a flag is unclear.

---

## Tasks

### 1. Network scanning and enumeration (2 pts)

**Objective:** Discover which TCP services are listening on localhost.

**What is going on.** Before exploiting anything, an ethical hacker **scans** the target: which ports are open, and what is speaking on them. Nmap sends TCP connection attempts (a **TCP connect** scan, `-sT`) and can probe for **service/version** banners (`-sV`). The result is a map of the attack surface.

In this lab you scan **127.0.0.1 only**, and only from the **GitHub Codespace terminal**. A scan of your laptop’s localhost will usually show port 22 and miss the lab apps. Start the listeners first (`bash scripts/start_services.sh`). Several lab HTTP services use ports **above 1000** (all below 10000), so a default or `1-1000` range is not enough.

Python/Flask apps often make Nmap print `service unrecognized despite returning data`. That is normal. You only need the ports to be **open**, not a named fingerprint.

**`nmap_scan.txt` is not created for you.** Nmap prints to the terminal unless you save **normal** output with `-oN`.

**What you do.** Scan `127.0.0.1` with a TCP connect scan, version detection, and a port range that covers the lab services. Save the report as `nmap_scan.txt` in the repository root.

Example against another host (keep a wide port range and `-oN` when you adapt it):

```sh
nmap -sT -sV -p 1-10000 10.0.0.5 -oN example_scan.txt
# TCP connect scan with version detection; save normal output to a file
```

**Deliverables:**

- `nmap_scan.txt` at the repository root, created by you from Nmap. Every lab TCP port must appear as `open`.

**Optional bonus:** In `yourAnswers.md`, list each open port and the lab service, and write two to three sentences on why ethical hackers scan before exploitation.

**Check:** `bash scripts/grade_task1_scan.sh`

Tool reference: [Nmap](https://nmap.org/book/man.html)

---

### 2. Packet sniffing (2 pts)

**Objective:** Capture plaintext HTTP on loopback and recover a secret from the traffic.

**What is going on.** **Sniffing** means recording packets on a network interface and reading their contents. If an application uses **plaintext HTTP** (no TLS), anyone who can see the path can read URLs, cookies, and response bodies. Defenders use the same technique to troubleshoot and to detect leaks.

This lab has a small HTTP service on **port 8081**. A normal request returns a confidential `FLAG{...}` in the body. You capture that traffic on the **loopback** interface (`lo`) only. Do not send test traffic to external websites.

**`sniff_capture.log` and `sniff_flag.txt` are not created for you.** tcpdump prints packets to the terminal, often on **stderr**. A redirect of stdout only can leave an empty log. Stop the capture after a few seconds so you get a finished file.

**What you do.**

1. In one terminal, capture loopback traffic for port 8081 in ASCII (`tcpdump -A`) for a few seconds and write **stdout and stderr** to `sniff_capture.log`.
2. In a second terminal, request `http://localhost:8081/` so packets appear in the capture.
3. Search the capture for `FLAG{...}` (for example with `grep`) and **redirect** the match into `sniff_flag.txt`. You need **both** files.

Example of a timed ASCII capture on another interface (adapt interface, port, and filename; note `timeout` and `2>&1`):

```sh
sudo timeout 10 tcpdump -i eth0 -A -s 0 'tcp port 80' > example.log 2>&1
# timed ASCII capture; save stdout and stderr to a log
```

Example of searching another log for a flag and saving only the first match:

```sh
grep -o 'FLAG{[^}]*}' example.log | head -n 1 > found_flag.txt
# extract the first FLAG{...} match and write it to a file
```

**Deliverables:**

- `sniff_capture.log` and `sniff_flag.txt` at the repository root, created by you.

**Optional bonus:** Screenshot of the capture in `screenshots/`, embedded in `yourAnswers.md`, plus two to three sentences on why plaintext HTTP exposes secrets.

**Check:** `bash scripts/grade_task2_sniff.sh`

Tool reference: [tcpdump](https://www.tcpdump.org/manpages/tcpdump.1.html)

---

### 3. Hash cracking with John the Ripper (2 pts)

**Objective:** Recover the Unix password that produced the hash in `hash.txt`.

**What is going on.** `hash.txt` is a stolen `/etc/shadow`style hash. The `$6$` prefix means SHA-512 crypt: a one-way function, so you cannot “decrypt” it. You guess a password, hash the guess the same way, and see if the results match.

Attackers almost never try every possible string. They use a **dictionary attack**: a list of likely passwords (leaks, defaults, and common choices). John the Ripper reads each line of a wordlist, hashes it, and compares it with `hash.txt` until one guess hits.

This lab already includes that dictionary. **`wordlist.txt`** in the repository root has 20 candidate passwords, one per line. One of them is the password that matches `hash.txt`. 

**`cracked_hash.txt`** John prints results in the terminal. You must save `john --show` yourself.

**What you do.** Point John at `hash.txt` using `wordlist.txt`. When it finishes, save `john --show` output as `cracked_hash.txt`.

Example against other files (adapt the names):

```sh
john --wordlist=wordlist.txt hashes.txt
# try each wordlist password against the hash

john --show hashes.txt > cracked.txt
# print cracked username:password lines and save them
```

**Deliverables:**

- `cracked_hash.txt` at the repository root, created by you from `john --show`. It must contain the `username:password` line.

**Optional bonus:** Screenshot of the cracked `username:password` line in `screenshots/`, embedded in `yourAnswers.md`, plus two to three sentences on what `$6$` means and why a short wordlist still works against weak passwords.

**Check:** `bash scripts/grade_task3_hash.sh`

Tool reference: [John the Ripper](https://www.openwall.com/john/)

---

### 4. SSH dictionary attack with Hydra (2 pts)

**Objective:** Find a valid SSH username and password on the local SSH service.

**What is going on.** Task 3 was **offline**: you already had the hash, so John never talked to a server. This task is **online**. The password is stored on the SSH service. Each guess is a real login attempt: Hydra opens a connection to SSH, tries a username and password, and reads whether the server accepts or rejects it.

That difference matters. An online attack is slower, shows up in logs, and can trigger lockouts or rate limits. It also works when you do *not* have a stolen hash, only a reachable login service. Hydra is a common tool for that: it takes a list of usernames (`-L`) and a list of passwords (`-P`) and tries combinations against a protocol such as SSH.

In this lab the target is **SSH on localhost only** (the service you started in Getting started). **`users.txt`** and **`passwords.txt`** are already in the repository root (usernames and password guesses). They are separate from Task 3’s `wordlist.txt`. One username and one password in those files form a valid SSH login. Do not point Hydra at any host other than localhost.

**`hydra_ssh.txt` is not created for you.** Hydra only prints results in the terminal. You must save that output yourself.

**What you do.** Run Hydra against `ssh://localhost` using `users.txt` (`-L`) and `passwords.txt` (`-P`). Redirect **stdout and stderr** into `hydra_ssh.txt` in the repository root. The saved file must still show Hydra’s successful `login` and `password` lines.

Example against another host (adapt the target; note how the output is saved):

```sh
hydra -L users.txt -P passwords.txt ssh://10.0.0.8 2>&1 | tee hydra_out.txt
# try username and password lists against SSH; save the terminal output
```

If you see `connection refused`, SSH is not running. Start it with `sudo service ssh start`, or restart every lab service:

```sh
bash scripts/start_services.sh
# start every local lab service, including SSH
```

**Deliverables:**

- `hydra_ssh.txt` at the repository root, created by you from Hydra’s output.

**Optional bonus:** Screenshot of Hydra reporting the valid login, embedded in `yourAnswers.md`, plus two to three sentences comparing this *online* attack with the *offline* crack in Task 3.

**Check:** `bash scripts/grade_task4_hydra.sh`

Tool reference: [Hydra](https://www.kali.org/tools/hydra/)

---

### 5. Denial-of-service simulation (2 pts)

**Objective:** Measure what happens when a local web service is flooded with HTTP requests.

**What is going on.** A denial-of-service (DoS) attack tries to make a service slow or unavailable by exhausting something it needs: CPU, memory, sockets, or bandwidth. A **volumetric HTTP flood** does that at the application layer: many clients (or one tool pretending to be many) send a large number of HTTP requests at once. That is different from a SYN flood (half-open TCP handshakes) or an ICMP flood (ping packets), but the idea is the same: more work than the target can finish.

This lab uses a small app on **port 8080** only. It is not the public internet. Each request to `/` increments a counter and waits a short time, like a busy backend. `/stats` returns JSON with how many requests arrived. `/reset` clears the counter so you can start a clean run.

ApacheBench (`ab`) is a load-testing tool. Attackers use similar “many requests, many connections” patterns; here you use it against localhost so you can read the impact from `/stats`.

**`dos_report.json` is not created for you.** `/stats` only prints JSON in the terminal (or browser). You must save that JSON yourself.

**What you do.**

1. Reset the counter on the local app so old traffic is not counted.
2. Use `ab` to send on the order of **1000** requests with many concurrent connections to `http://localhost:8080/` (a high count, not a few manual `curl`s).
3. Fetch `/stats` and save the JSON as `dos_report.json` in the repository root.

Example against another URL (reset first, then flood, then save `/stats`; adapt host, count, and concurrency):

```sh
curl -s http://10.0.0.8/reset
# reset the request counter so old traffic is not counted

ab -n 500 -c 10 http://10.0.0.8/
# send a large number of concurrent HTTP requests

curl -s http://10.0.0.8/stats -o stats.json
# fetch the stats JSON and save it to a file
```

If the app does not respond, start lab services:

```sh
bash scripts/start_services.sh
# start every local lab service
```

**Deliverables:**

- `dos_report.json` at the repository root, created by you from `/stats`.

**Optional bonus:** Screenshot of your `ab` output, embedded in `yourAnswers.md`, plus two to three sentences relating this HTTP flood to SYN or ICMP floods.

**Check:** `bash scripts/grade_task5_dos.sh`

Tool reference: [ApacheBench (ab)](https://httpd.apache.org/docs/2.4/programs/ab.html)

---

### 6. Session hijacking via cookie replay (3 pts)

**Objective:** Capture another user’s session cookie in transit and reuse it to open a protected page without logging in.

**What is going on.** After login, many web apps send a **session cookie** (`Set-Cookie`) so the browser can prove who it is on later requests. If that cookie travels over **plaintext HTTP**, a sniffer can copy it. **Replaying** the cookie (sending it on your own request) is application-level session hijacking: the server treats you as that user because it only checks the cookie, not a password.

In this lab a background job logs in as `admin` about every 15 seconds on **port 5001**. `/login` issues the cookie; `/account` is protected. Capture long enough to see one login. Do this in the **Codespace terminal** (`curl` and `tcpdump`). A Codespace browser tab that says Service not found does not mean the app is down.

**`session_capture.log` and `session_hijack_flag.txt` are not created for you.** You must save the tcpdump output (stdout and stderr) and the replay response.

**What you do.**

1. Capture loopback traffic on port 5001 in ASCII (`tcpdump -A`) for about 20 seconds. Use interface **`lo`** (the example below uses `eth0`; change it). Save **stdout and stderr** as `session_capture.log`.
2. Search the capture for the `session=` cookie value.
3. Replay that cookie to `/account` **without logging in**. Paste the stolen value into `curl -b` and save the response as `session_hijack_flag.txt`.

Example against another interface (in this lab change `eth0` to **`lo`**; also adapt port, cookie, and filenames):

```sh
sudo timeout 20 tcpdump -i eth0 -A -s 0 'tcp port 80' > example.log 2>&1
# capture ASCII HTTP for about 20 seconds; save stdout and stderr to a log

grep -o 'session=[a-f0-9]*' example.log | head -n 1
# print the first session= cookie value from that capture

curl -s -b "session=00deadbeef" http://10.0.0.8/profile -o response.txt
# replay the cookie to a protected page without logging in, and save the response

cat response.txt
# show the saved response
```

If the response is `Access denied`, the cookie expired. Capture again and replay a fresh value.

**Deliverables:**

- `session_capture.log` and `session_hijack_flag.txt` at the repository root, created by you.

**Optional bonus:** Two to three sentences in `yourAnswers.md` on how HTTPS and short-lived session tokens would prevent this attack.

**Check:** `bash scripts/grade_task6_session.sh`

Tool reference: [tcpdump](https://www.tcpdump.org/manpages/tcpdump.1.html)

---

### 7. Web server reconnaissance (2 pts)

**Objective:** Find a web directory that is not linked from the site, then retrieve the flag inside it.

**What is going on.** Sites often hide admin panels, backups, or tools by simply **not linking** them from the homepage. Search engines and casual users never see them; scanners still find them. **Nikto** checks a web server for common misconfigurations. **Dirb** brute-forces directory names from a wordlist. An unlisted path is still a risk if the server returns it to anyone who asks.

The lab site is `http://localhost:8000`. The hidden path is **not** in the homepage HTML. **`scripts/web_wordlist.txt`** is already in the repo; you do not need to build a directory list.

**`web_recon_flag.txt` is not created for you.** You must discover the directory and save the flag file’s contents.

**What you do.**

1. Run a web-server check (Nikto) against `http://localhost:8000`.
2. Brute-force directories with Dirb and **`scripts/web_wordlist.txt`**.
3. When you find a directory that is not the site root, fetch the flag file inside it and save the body as `web_recon_flag.txt`.

Example against another site (adapt the URL, wordlist, and hidden path):

```sh
nikto -h http://10.0.0.8
# check the web server for common misconfigurations

dirb http://10.0.0.8/ wordlist.txt
# brute-force directory names from a wordlist

curl -s http://10.0.0.8/secret-dir/flag.txt -o found_flag.txt
# download the flag file from the directory you discovered

cat found_flag.txt
# show the saved flag
```

**Deliverables:**

- `web_recon_flag.txt` at the repository root, created by you.

**Optional bonus:** Screenshot of Nikto or Dirb output showing the discovered directory, embedded in `yourAnswers.md`, plus two to three sentences on why an unlinked directory is still a risk.

**Check:** `bash scripts/grade_task7_webrecon.sh`

Tool references: [Nikto](https://github.com/sullo/nikto), [Dirb](https://www.kali.org/tools/dirb/)

---

### 8. SQL injection and credential cracking (3 pts)

**Objective:** Abuse a vulnerable query to dump password hashes, then crack the admin password.

**What is going on.** The app on **port 5002** builds SQL by **concatenating** the `id` query parameter into the statement. If `id` is not treated as data only, you can change the meaning of the query. A common technique is a **UNION SELECT**: you add extra rows from another table (`users`) so the JSON includes `admin` and `password_hash`.

That hash is the same *kind* of hash as Task 3. After you extract it, crack it offline with John and the provided list **`scripts/sqli_wordlist.txt`**.

**`sqli_extracted_hash.txt` and `sqli_cracked_password.txt` are not created for you.** You must write them.

**What you do.**

1. Request a normal row (`id=1`) and inspect the JSON field names.
2. Inject a **UNION SELECT** (same number of columns) so extra rows from the `users` table appear, including `admin` and `password_hash`. Comment out the rest of the original query if needed.
3. Save the admin hash as `sqli_extracted_hash.txt` in the form `admin:<hash>`.
4. Crack it with John and **`scripts/sqli_wordlist.txt`**. Save `sqli_cracked_password.txt` as `admin:<password>`.

Do this with `curl` in the **Codespace terminal**. You may use sqlmap on the `id` parameter once you understand the injection point.

Example against another app (adapt host, path, columns, table, and filenames):

```sh
curl "http://10.0.0.8/item?id=1"
# send a normal request and inspect the JSON fields

curl "http://10.0.0.8/item?id=0 UNION SELECT id,name,price FROM catalogue--"
# inject a UNION so extra table rows appear in the response

echo "admin:<paste_password_hash_here>" > extracted.txt
# write the stolen hash in username:hash form

john --wordlist=wordlist.txt extracted.txt
# crack the hash with a wordlist

john --show extracted.txt
# print the cracked username:password line

echo "admin:<paste_password_here>" > cracked.txt
# save the cracked password in username:password form
```

Optional sqlmap against another URL:

```sh
sqlmap -u "http://10.0.0.8/item?id=1" --batch --dump
# automatically dump data from a URL with an injectable id parameter
```

**Deliverables:**

- `sqli_extracted_hash.txt` and `sqli_cracked_password.txt` at the repository root, created by you.

**Optional bonus:** Two to three sentences in `yourAnswers.md` describing one SQL injection defence (for example parameterized queries).

**Check:** `bash scripts/grade_task8_sqli.sh`

Tool reference: [sqlmap](https://sqlmap.org/)

---

### 9. Cryptography: encoding and hashing (2 pts)

**Objective:** Decode a Base64 string and recover the plaintext of a raw MD5 hash.

**What is going on.** **Encoding** (Base64) is a reversible way to write bytes as text. It is **not** encryption: anyone who sees the string can decode it with no key. **Hashing** (MD5) is one-way, but unsalted MD5 of a common password is easy to recover by hashing candidates until one matches, the same idea as Task 3.

Codespace setup writes two files in the repository root (they appear after setup finishes):

- `cipher_b64.txt`: one Base64 line
- `md5_hash.txt`: a raw MD5 digest of a word from `passwords.txt`

**`crypto_b64_flag.txt` and `crypto_md5.txt` are not created for you.** You must write the decoded flag and the cracked MD5 word.

**What you do.**

1. Decode `cipher_b64.txt` and save the plaintext as `crypto_b64_flag.txt`.
2. For each word in `passwords.txt`, compute its raw MD5 digest and compare it with `md5_hash.txt`.
3. Save the matching word only as `crypto_md5.txt`. Both parts are required for the 2 points.

Example against other files (adapt names):

```sh
base64 -d encoded.txt > decoded.txt
# decode a Base64 string and save the plaintext

cat decoded.txt
# show the decoded text

while read -r w; do
  h=$(echo -n "$w" | md5sum | awk '{print $1}')
  if grep -qx "$h" hash.txt; then echo "$w"; fi
done < words.txt > found.txt
# hash each candidate; write the word whose digest matches hash.txt

cat found.txt
# show the recovered word
```

You can also check one candidate with `echo -n "secret" | openssl dgst -md5`.

**Deliverables:**

- `crypto_b64_flag.txt` and `crypto_md5.txt` at the repository root, created by you.

**Optional bonus:** Two to three sentences in `yourAnswers.md` on why Base64 is encoding, not encryption, and why unsalted MD5 is a weak password hash.

**Check:** `bash scripts/grade_task9_crypto.sh`

Tool reference: [openssl dgst](https://www.openssl.org/docs/man3.0/man1/openssl-dgst.html)

---

### 10. Stolen Bearer token replay (2 pts)

**Objective:** Recover a live API access token and call a protected endpoint without a password.

**What is going on.** Modern APIs often use **OAuth-style Bearer tokens** instead of session cookies. The client sends `Authorization: Bearer <token>`. If that token leaks (HTTP, CI logs, debug files), anyone can **replay** it, the same idea as Task 6 but with a header instead of a cookie.

The API on **port 5003** issues tokens at `/oauth/token` over plaintext HTTP. A background job requests a token about every 15 seconds and appends the JSON to `/tmp/oauth_debug.log`. `/api/me` is protected.

**`bearer_flag.txt` is not created for you.** You must recover a token and save the `/api/me` response.

**What you do.**

1. Recover an `access_token` from `/tmp/oauth_debug.log` (or from an ASCII capture on port 5003).
2. Send it as `Authorization: Bearer ...` to `/api/me` (no password). Save the response as `bearer_flag.txt`.
3. If you get `invalid token`, the token expired; read the log again.

Do this with `curl` in the **Codespace terminal**.

Example against another log and API (adapt the log path, token, URL, and filename):

```sh
grep -o '"access_token": "[^"]*"' /tmp/example_oauth.log | tail -n 1
# print the latest access_token line from a debug log

curl -s -H "Authorization: Bearer 00deadbeef" http://10.0.0.8/api/profile -o response.txt
# replay that token as a Bearer header and save the protected response

cat response.txt
# show the saved response
```

**Deliverables:**

- `bearer_flag.txt` at the repository root, created by you.

**Optional bonus:** Two to three sentences in `yourAnswers.md` on why leaking Bearer tokens is as serious as leaking a password, and one control (short expiry, TLS, or sender-constrained tokens).

**Check:** `bash scripts/grade_task10_bearer.sh`

Tool reference: [RFC 6750 Bearer tokens](https://datatracker.ietf.org/doc/html/rfc6750)

---

### 11. API IDOR (2 pts)

**Objective:** Access another user’s record by changing an object id in the API URL.

**What is going on.** **IDOR** (insecure direct object reference), also called **broken object-level authorization**, is OWASP API Top 10 issue A01. The API trusts an id in the URL (`/api/users/1`) without checking whether *you* are allowed to see that object. Changing the id can expose someone else’s data even if you never “hacked” authentication.

The same API on **port 5003** exposes `/api/users/<id>` with **no** per-object check. Id `1` is a low-privilege record. Other numeric ids exist. Look in the `notes` field for a `FLAG{...}`.

**`idor_flag.txt` is not created for you.** You must fetch the other object and save the response.

**What you do.**

1. Request the guest record (`/api/users/1`) and inspect the JSON.
2. Change only the numeric id and request another user. Look for `FLAG{...}` in the `notes` field.
3. Save the response that contains the flag as `idor_flag.txt`.

Do this with `curl` in the **Codespace terminal**.

Example against another API (adapt host, path, and ids):

```sh
curl -s http://10.0.0.8/api/orders/1001
# request the object you are expected to see

curl -s http://10.0.0.8/api/orders/1002 -o other_record.txt
# change only the object id, fetch another record, and save it

cat other_record.txt
# show the saved record
```

**Deliverables:**

- `idor_flag.txt` at the repository root, created by you.

**Optional bonus:** Two to three sentences in `yourAnswers.md` on why APIs must authorize each object, not only that the client called an API.

**Check:** `bash scripts/grade_task11_idor.sh`

Tool reference: [OWASP API Security: broken object-level authorization](https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/)

---

### 12. Cloud IAM misconfiguration (1 pt)

**Objective:** Find cloud credentials that were committed by mistake, and name the IAM statement that grants every action on every resource.

**What is going on.** Real incidents often start with **secrets in git** (access keys in `.env` files) and **overbroad IAM** (`Action: *` and `Resource: *`, sometimes called “break-glass” that never got tightened). Anyone with the repo can use the key; a wildcard policy lets that key do almost anything in the account.

This is a **local simulation**. There is no real AWS or Azure account. The leaked backup is the **`cloud_lab/`** folder already in the repository (an env file and a policy JSON).

**`cloud_access_key.txt` and `iam_risk.txt` are not created for you.** You must write them.

**What you do.**

1. Inspect `cloud_lab/` (the env file and the policy JSON).
2. Find the access key id and save **only that value** as `cloud_access_key.txt`.
3. In `iam_risk.txt`, quote the policy `Action` that is a wildcard (`*`). Include the word `Action` and `*`.

Example against another leaked folder (adapt paths and the value you found):

```sh
grep ACCESS_KEY_ID example_lab/deploy.env
# find the access key line in a committed env file

echo "PASTE_KEY_HERE" > access_key.txt
# save only the key id you found

echo '"Action": "*"' > policy_risk.txt
# record the wildcard Action from the IAM policy
```

**Deliverables:**

- `cloud_access_key.txt` and `iam_risk.txt` at the repository root, created by you.

**Optional bonus:** Two to three sentences in `yourAnswers.md` on why secrets belong in a vault (not git) and why `Action: *` on `Resource: *` is dangerous.

**Check:** `bash scripts/grade_task12_iam.sh`

Tool reference: [AWS IAM security best practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

---

## Submission

Commit and push the practical task files **before** you stop the Codespace:

```sh
git add .
# stage your lab files

git commit -m "Complete lab tasks and answers"
# save a local commit

git push
# upload the commit to GitHub
```

Required on GitHub: `nmap_scan.txt`, `sniff_capture.log`, `sniff_flag.txt`, `cracked_hash.txt`, `hydra_ssh.txt`, `dos_report.json`, `session_capture.log`, `session_hijack_flag.txt`, `web_recon_flag.txt`, `sqli_extracted_hash.txt`, `sqli_cracked_password.txt`, `crypto_b64_flag.txt`, `crypto_md5.txt`, `bearer_flag.txt`, `idor_flag.txt`, `cloud_access_key.txt`, and `iam_risk.txt`.

Optional (3-point bonus): an updated `yourAnswers.md` plus images in `screenshots/`.
