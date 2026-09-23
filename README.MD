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
12. Read a simple IAM policy, spot a wildcard that breaks least privilege, and find an access key committed in git.

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

**What is going on.** This is how a common **SQL injection** attack works in practice.

A web app looks up one record, for example “show user 1.” The safe way is to send `1` to the database as **data**. The unsafe way (this lab) is to **glue** the `id` from the URL into the SQL string. The database then runs whatever SQL the URL produced.

Attackers start with a normal request so they can see what a real row looks like. On **port 5002** that URL is `/user?id=`. `id=1` should return JSON with **three** fields: `id`, `username`, and `password_hash` (one guest row). That tells the attacker the original query is a `SELECT` with three columns.

They then change `id` from a number into extra SQL. A frequent technique is **UNION SELECT**: “run the original lookup, **and also** return rows from another query.” The extra query can read the whole `users` table, so `admin` and the stored `password_hash` appear in the same JSON. UNION only works if the extra `SELECT` has the **same number of columns** (here, three). `--` is an SQL comment: it tells the database to ignore the rest of the original `WHERE` clause so the injected SQL is valid.

The response still does **not** give the login password. It gives a hash (`$6$...`, SHA-512 crypt, same idea as Task 3). Attackers copy that hash offline and run a dictionary attack with John. In real incidents this is how a simple “lookup by id” page becomes a full credential dump: inject, extract hashes, crack weak passwords, then log in as that user.

**`sqli_extracted_hash.txt` and `sqli_cracked_password.txt` are not created for you.** You must write them. Crack the hash with John and **`scripts/sqli_wordlist.txt`**.

**What you do.** Use `curl` in the **Codespace terminal** (a browser tab that says Service not found does not mean the app is down).

1. Request `id=1` and read the JSON. Confirm there are three fields. That is the attacker’s reconnaissance step.
2. Inject a UNION that selects **three** columns from the `users` table so every user row (including `admin` and `password_hash`) appears. Do **not** put raw spaces in the URL: use `curl -G` with `--data-urlencode`, or replace each space with `%20`.
3. Copy the admin hash (the `$6$...` value) into `sqli_extracted_hash.txt` as `admin:<hash>`. Use **single quotes** around that line so the shell does not eat `$`.
4. Point John at that file with **`scripts/sqli_wordlist.txt`**. When it finishes, run `john --show` and save `sqli_cracked_password.txt` as `admin:<password>`.

Example against another app (adapt host, path, column names, table, wordlist, and filenames; keep `-G --data-urlencode`, the three-column UNION, and `admin:` files):

```sh
curl "http://10.0.0.8/item?id=1"
# normal request: note how many JSON fields come back

curl -G "http://10.0.0.8/item" --data-urlencode "id=0 UNION SELECT id,name,price FROM catalogue--"
# UNION with the same column count; -G --data-urlencode encodes spaces (a quoted URL with spaces is rejected)

echo 'admin:$6$examplehash' > extracted.txt
# save username:hash; single quotes so the shell does not eat $6$

john --wordlist=scripts/wordlist.txt extracted.txt
# crack the hash with a wordlist

john --show extracted.txt
# print the cracked username:password line

echo "admin:ExamplePass1!" > cracked.txt
# save username:password
```

Optional, after you understand the injection point:

```sh
sqlmap -u "http://10.0.0.8/item?id=1" --batch --dump
# dump data from a URL with an injectable id parameter
```

**Deliverables:**

- `sqli_extracted_hash.txt` at the repository root: `admin:<hash>` (must include `$6$`).
- `sqli_cracked_password.txt` at the repository root: `admin:<password>`.

**Optional bonus:** Two to three sentences in `yourAnswers.md` describing one SQL injection defence (for example parameterized queries).

**Check:** `bash scripts/grade_task8_sqli.sh`

Tool reference: [sqlmap](https://sqlmap.org/)

---

### 9. Cryptography: encoding and hashing (2 pts)

**Objective:** Decode a Base64 string and recover the plaintext of a raw MD5 hash.

**What is going on.** Attackers often find “secret” strings that look protected but are not.

**Encoding** (Base64) turns bytes into safe text so they can travel in email, JSON, or a config file. Anyone who sees the string can run `base64 -d` and get the original. There is no key. Developers still paste Base64 into apps as if it were encryption; attackers treat it as plaintext with an extra step.

**Hashing** (MD5) is different: it is one-way. You cannot “decrypt” an MD5 digest. What attackers do instead is a **dictionary attack**, the same idea as Task 3: hash likely passwords until one digest matches the stolen value. Unsalted MD5 of a common word is fast to recover. That is why modern systems use a slow salted hash (SHA-512 crypt `$6$`, bcrypt, Argon2), not raw MD5.

In this lab, setup leaves two leaked files in the repository root (they appear after setup finishes):

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

**What is going on.** This is the API version of Task 6 (cookie replay), and it is how many real API breaches start today.

Mobile apps, single-page sites, and backends talk to APIs with **OAuth-style Bearer tokens** instead of a password on every request:

`Authorization: Bearer <token>`

Whoever holds that string **is** the user, until the token expires. Attackers do not need to crack OAuth. They **request or steal a token**, then **replay** it from their own laptop.

That is a security issue when any of these are true (this lab has the first two):

- `/oauth/token` (or a similar “give me a token” URL) has **no login**, no client secret, and no TLS. Anyone who can `curl` it gets a live `access_token`. That is an **unauthenticated token endpoint**.
- The request is **plaintext HTTP**, so a sniffer, proxy, or public Wi-Fi path can copy the same JSON.
- The token is **stored badly**: pasted into a chat, committed in `.env`, printed in GitHub Actions logs, left in a support ticket, or saved in frontend JavaScript. Search engines and leak sites index those.

Once they have the token they call `/api/me` (or your bank/export API) with no password. Short-lived tokens, TLS, a real client secret, and **not** logging or committing tokens limit the damage. Store API keys and tokens in a **secrets vault** or the platform’s secret store (GitHub Actions secrets, AWS Secrets Manager), not in the repo and not in chat.

In this lab, **port 5003** `/oauth/token` returns a token to anyone who asks. Copy `access_token` and replay it to `/api/me`. If you get `invalid token`, request a new one.

**`bearer_flag.txt` is not created for you.** You must save the `/api/me` response.

**What you do.** Use the **Codespace terminal** and `127.0.0.1` (not a laptop browser).

1. Request a token from `/oauth/token` on **port 5003**. Read `access_token` in the JSON.
2. Send that value as `Authorization: Bearer ...` to `/api/me` (no password). Save the response as `bearer_flag.txt`.
3. If you get `invalid token`, request a new token and replay again.

Example against another API (adapt host, paths, token, and filename):

```sh
curl -s http://10.0.0.8/oauth/token
# request a token over plaintext HTTP; copy the access_token value

curl -s -H "Authorization: Bearer 00deadbeef" http://10.0.0.8/api/profile -o response.txt
# replay that token as a Bearer header and save the protected response

cat response.txt
# show the saved response
```

**Deliverables:**

- `bearer_flag.txt` at the repository root, created by you.

**Optional bonus:** Two to three sentences in `yourAnswers.md` on why a stolen Bearer token is as serious as a stolen password today, and where tokens must **not** be stored (git, CI logs, chat). Name one better control (vault, short expiry, TLS, or a required client secret).

**Check:** `bash scripts/grade_task10_bearer.sh`

Tool reference: [RFC 6750 Bearer tokens](https://datatracker.ietf.org/doc/html/rfc6750)

---

### 11. API IDOR (2 pts)

**Objective:** Access another user’s record by changing an object id in the API URL.

**What is going on.** A lot of current API abuse needs **no malware and no stolen password**. The attacker only changes a number.

**IDOR** (insecure direct object reference), also called **broken object-level authorization** (BOLA), is still OWASP API Top 10 **A01**. Apps expose objects as `/api/users/1`, `/api/orders/1001`, `/v1/invoices/55`. Mobile apps and SPAs call these URLs all day. If the server checks only “this looks like an API call” (or even “they sent *a* token”) and not “is **this** caller allowed to see **this** id?”, then id `2` returns someone else’s record.

That is how people scrape other customers’ bookings, school grades, or health notes: log in as a normal user (or use no auth at all), walk ids `1, 2, 3, …`, and keep the JSON that is not theirs. 

Defence is **authorization on every object**, not hidden ids and not “the app is only in our mobile client.” Sequential ids are easy to guess; random UUIDs help a little but do not replace a permission check.

The same API on **port 5003** exposes `/api/users/<id>` with **no** per-object check. Id `1` is the guest record you are meant to see. Other numeric ids exist. The confidential value is in another user’s `notes` field as `FLAG{...}`.

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

**Optional bonus:** Two to three sentences in `yourAnswers.md` on why hiding an id or shipping the API only in a mobile app is not enough, and what the server must check on every object.

**Check:** `bash scripts/grade_task11_idor.sh`

Tool reference: [OWASP API Security: broken object-level authorization](https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/)

---

### 12. Cloud IAM misconfiguration (1 pt)

**Objective:** Read a small IAM policy, spot the rule that is too broad, and find the access key that was committed next to it.

**What you learn.** **IAM** (identity and access management) answers three questions: *who* may do *which action* on *which resource*. **Least privilege** means the answer is as small as possible (for example “this app may only `s3:GetObject` on one bucket”). A wildcard `Action: *` on `Resource: *` means “this identity may do everything on everything.” If that identity’s access key is also sitting in git, one leak is a full cloud account, not a single file read.

**What is going on.** Current cloud incidents often start the same week a repo goes public: a **long-lived access key in git** plus an IAM policy that says “this key may do everything.”

Teams still put `CLOUD_ACCESS_KEY_ID` and secrets in `deploy.env` or `.env` so CI and laptops can call AWS or Azure. One `git add .` publishes them. Bots scan GitHub in minutes. The key **is** the login; nobody needs to phish the console. The second failure is **wildcard IAM**: `Action: *` on `Resource: *` (a leftover “make it work” policy). That stolen key can then list buckets, create users, or run crypto-mining, not only the one API it was meant for.

Today the usual advice is: **no long-lived keys in the repo**; use a vault or short-lived roles (for example OIDC from GitHub Actions to AWS). Turn on secret scanning. Give each key **least privilege** (only the actions and resources it needs), not `*`.

The folder **`cloud_lab/`** is a local simulation (no real AWS or Azure). It has two files on purpose:

- `deploy.env`: a long-lived access key (the kind bots scrape from public GitHub)
- `iam_policy.json`: two statements. One is narrow (S3 read). One is “break-glass” (`Action` and `Resource` are `*`). You need to tell them apart.

**`cloud_access_key.txt` and `iam_risk.txt` are not created for you.** You must write them.

**What you do.**

1. Open `cloud_lab/deploy.env` and `cloud_lab/iam_policy.json`.
2. Copy the `CLOUD_ACCESS_KEY_ID` value only into `cloud_access_key.txt`.
3. In the policy, find the statement whose `Action` is `*`. Write that `Action` line into `iam_risk.txt` (it must include the word `Action` and `*`).

```sh
grep CLOUD_ACCESS_KEY_ID cloud_lab/deploy.env
# read the committed access key id

echo "PASTE_THE_KEY_ID_ONLY" > cloud_access_key.txt
# save only the key id, not the whole line

echo '"Action": "*"' > iam_risk.txt
# quote the wildcard Action from the dangerous statement
```

**Deliverables:**

- `cloud_access_key.txt` at the repository root (the key id only).
- `iam_risk.txt` at the repository root (the wildcard `Action`).

**Optional bonus:** Two to three sentences in `yourAnswers.md`: what least privilege means here, and why a key in git plus `Action: *` is worse than either mistake alone.

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
