# Lab 2: Scanning, Exploitation, and Web Attacks Answers

Complete every section. Embed screenshots from a `screenshots/` folder, for example:

`![Description](screenshots/task1.png)`

---

## 1. Network scanning and enumeration (2 pts)

**Scan file:** Confirm `nmap_scan.txt` is saved at the repository root.

**Open ports:** List each open TCP port and the lab service that uses it.

**Explanation:** Why do ethical hackers scan and enumerate before attempting exploitation?

---

## 2. Packet sniffing (2 pts)

**Screenshot:** tcpdump output showing the confidential token in transit.

**Files:** Confirm `sniff_capture.log` and `sniff_flag.txt` are saved at the repository root.

**Explanation:** Why does plaintext HTTP expose secrets to anyone who can observe the path?

---

## 3. Hash cracking with John the Ripper (2 pts)

**Files:** Confirm `cracked_hash.txt` is saved at the repository root (`john --show` output).

**Screenshot:** John showing the cracked `username:password` line.

**Explanation:** What does the `$6$` prefix in `hash.txt` mean?

---

## 4. SSH dictionary attack with Hydra (2 pts)

**Files:** Confirm `hydra_ssh.txt` is saved at the repository root (Hydra stdout).

**Screenshot:** Hydra output showing the valid login and password.

**Explanation:** How does this online attack differ from the offline crack in Task 3?

---

## 5. Denial-of-service simulation (2 pts)

**Screenshot:** `ab` output.

**Explanation:** How does this HTTP flood relate to SYN or ICMP floods, and why is a real DoS harder to stop?

---

## 6. Session hijacking via cookie replay (3 pts)

**Files:** Confirm `session_capture.log` and `session_hijack_flag.txt` are saved at the repository root.

**Explanation:** How would HTTPS and short-lived session tokens prevent this attack?

---

## 7. Web server reconnaissance (2 pts)

**Screenshot:** Nikto or Dirb output showing the discovered directory.

**Explanation:** Why is an unlinked directory still a security risk?

---

## 8. SQL injection and credential cracking (3 pts)

**Files:** Confirm `sqli_extracted_hash.txt` and `sqli_cracked_password.txt` are saved at the repository root.

**Explanation:** Describe one countermeasure that would prevent this SQL injection.

---

## 9. Cryptography: encoding and hashing (2 pts)

**Files:** Confirm `crypto_b64_flag.txt` and `crypto_md5.txt` are saved at the repository root.

**Explanation:** Why is Base64 encoding, not encryption? Why is unsalted MD5 a weak password hash?

---

## 10. Stolen Bearer token replay (2 pts)

**Flag file:** Confirm `bearer_flag.txt` is saved at the repository root.

**Explanation:** Why is a leaked Bearer token as serious as a leaked password? Name one control that would reduce the impact.

---

## 11. API IDOR (2 pts)

**Flag file:** Confirm `idor_flag.txt` is saved at the repository root.

**Explanation:** Why must an API check authorization for each object id, not only that the client called an API?

---

## 12. Cloud IAM misconfiguration (1 pt)

**Files:** Confirm `cloud_access_key.txt` and `iam_risk.txt` are saved at the repository root.

**Explanation:** Why should cloud keys not live in git, and why is `Action: *` on `Resource: *` dangerous?

