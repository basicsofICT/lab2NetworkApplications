# Lab 2: Scanning, Exploitation, and Web Attacks Answers

Complete every section. Embed screenshots from a `screenshots/` folder, for example:

`![Description](screenshots/task1.png)`

---

## 1. Network scanning and enumeration (2 pts)

**Files:** `nmap_scan.txt` is not generated automatically. Save Nmap output with `-oN`.

**Open ports:** List each open TCP port and the lab service that uses it.

**Explanation:** Why do ethical hackers scan and enumerate before attempting exploitation?

---

## 2. Packet sniffing (2 pts)

**Screenshot:** tcpdump output showing the confidential token in transit.

**Files:** `sniff_capture.log` and `sniff_flag.txt` are not generated automatically. Save the capture and extract the flag yourself.

**Explanation:** Why does plaintext HTTP expose secrets to anyone who can observe the path?

---

## 3. Hash cracking with John the Ripper (2 pts)

**Files:** `wordlist.txt` is provided. You must create `cracked_hash.txt` yourself from `john --show` (it is not generated automatically).

**Screenshot:** John showing the cracked `username:password` line.

**Explanation:** What does the `$6$` prefix in `hash.txt` mean, and why can a short wordlist still recover a weak password?

---

## 4. SSH dictionary attack with Hydra (2 pts)

**Files:** `users.txt` and `passwords.txt` are provided. You must create `hydra_ssh.txt` yourself by saving Hydra’s terminal output (it is not generated automatically).

**Screenshot:** Hydra output showing the valid login and password.

**Explanation:** How does this *online* Hydra attack differ from the *offline* John crack in Task 3 (logs, lockouts, speed, need for a live service)?

---

## 5. Denial-of-service simulation (2 pts)

**Files:** `dos_report.json` is not generated automatically. Save the `/stats` JSON yourself after the flood.

**Screenshot:** `ab` output.

**Explanation:** How does this HTTP flood relate to SYN or ICMP floods, and why is a real DoS harder to stop?

---

## 6. Session hijacking via cookie replay (3 pts)

**Files:** `session_capture.log` and `session_hijack_flag.txt` are not generated automatically. Save the capture and the replay response yourself.

**Explanation:** How would HTTPS and short-lived session tokens prevent this attack?

---

## 7. Web server reconnaissance (2 pts)

**Screenshot:** Nikto or Dirb output showing the discovered directory.

**Files:** `web_recon_flag.txt` is not generated automatically. Save the flag after you find the hidden directory.

**Explanation:** Why is an unlinked directory still a security risk?

---

## 8. SQL injection and credential cracking (3 pts)

**Files:** `sqli_extracted_hash.txt` and `sqli_cracked_password.txt` are not generated automatically. Write them after you dump and crack the hash.

**Explanation:** Describe one countermeasure that would prevent this SQL injection.

---

## 9. Cryptography: encoding and hashing (2 pts)

**Files:** `cipher_b64.txt` and `md5_hash.txt` are provided after setup. You must create `crypto_b64_flag.txt` and `crypto_md5.txt` yourself.

**Explanation:** Why is Base64 encoding, not encryption? Why is unsalted MD5 a weak password hash?

---

## 10. Stolen Bearer token replay (2 pts)

**Files:** `bearer_flag.txt` is not generated automatically. Save the `/api/me` response after you replay a token.

**Explanation:** Why is a leaked Bearer token as serious as a leaked password? Name one control that would reduce the impact.

---

## 11. API IDOR (2 pts)

**Files:** `idor_flag.txt` is not generated automatically. Save the other user’s API response yourself.

**Explanation:** Why must an API check authorization for each object id, not only that the client called an API?

---

## 12. Cloud IAM misconfiguration (1 pt)

**Files:** `cloud_lab/` is provided. You must create `cloud_access_key.txt` and `iam_risk.txt` yourself.

**Explanation:** Why should cloud keys not live in git, and why is `Action: *` on `Resource: *` dangerous?
