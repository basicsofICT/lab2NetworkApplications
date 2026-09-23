# Lab 2 optional write-up (3 bonus points)

This file is **optional**. Completing it is worth a **3-point bonus**. You can skip it and still earn the full **25** for the practical task files.

If you do the bonus, write two to three sentences for each task. Where a screenshot is listed, take it, save it in `screenshots/`, and embed it here. Example:

```md
![tcpdump capture showing the token](screenshots/task2.png)
```

---

## 1. Network scanning and enumeration (optional)

**Open ports:** List each open TCP port and the lab service that uses it.

**Explanation:** Why do ethical hackers scan and enumerate before attempting exploitation?

---

## 2. Packet sniffing (optional)

**Screenshot:** tcpdump output showing the confidential token in transit.

```md
![tcpdump capture showing the token](screenshots/task2.png)
```

**Explanation:** Why does plaintext HTTP expose secrets to anyone who can observe the path?

---

## 3. Hash cracking with John the Ripper (optional)

**Screenshot:** John showing the cracked `username:password` line.

```md
![John showing the cracked username:password](screenshots/task3.png)
```

**Explanation:** What does the `$6$` prefix in `hash.txt` mean, and why can a short wordlist still recover a weak password?

---

## 4. SSH dictionary attack with Hydra (optional)

**Screenshot:** Hydra output showing the valid login and password.

```md
![Hydra showing the valid SSH login](screenshots/task4.png)
```

**Explanation:** How does this *online* Hydra attack differ from the *offline* John crack in Task 3 (logs, lockouts, speed, need for a live service)?

---

## 5. Denial-of-service simulation (optional)

**Screenshot:** `ab` output.

```md
![ApacheBench ab output](screenshots/task5.png)
```

**Explanation:** How does this HTTP flood relate to SYN or ICMP floods, and why is a real DoS harder to stop?

---

## 6. Session hijacking via cookie replay (optional)

**Explanation:** How would HTTPS and short-lived session tokens prevent this attack?

---

## 7. Web server reconnaissance (optional)

**Screenshot:** Nikto or Dirb output showing the discovered directory.

```md
![Nikto or Dirb showing the hidden directory](screenshots/task7.png)
```

**Explanation:** Why is an unlinked directory still a security risk?

---

## 8. SQL injection and credential cracking (optional)

**Explanation:** Describe one countermeasure that would prevent this SQL injection.

---

## 9. Cryptography: encoding and hashing (optional)

**Explanation:** Why is Base64 encoding, not encryption? Why is unsalted MD5 a weak password hash?

---

## 10. Stolen Bearer token replay (optional)

**Explanation:** Why is a stolen Bearer token as serious as a stolen password today, and where must tokens not be stored (git, CI logs, chat)? Name one better control.

---

## 11. API IDOR (optional)

**Explanation:** Why is hiding an id or shipping the API only in a mobile app not enough? What must the server check on every object?

---

## 12. Cloud IAM misconfiguration (optional)

**Explanation:** What does least privilege mean in this IAM policy? Why is a key in git plus `Action: *` worse than either mistake alone?
