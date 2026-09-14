# Lab 2: Scanning, Exploitation, and Web Attacks Answers

Complete every section. Embed screenshots from a `screenshots/` folder, for example:

`![Description](screenshots/task1.png)`

---

## 1. Scanning and sniffing (1 pt)

**tcpdump screenshot:** Highlight key packet types (TCP handshake, HTTP, and/or SSH).

**Description:** Choose one highlighted packet type. What does it represent, and why would a defender inspect it?

**Scan file:** Confirm `nmap_scan.txt` is saved at the repository root.

**Open ports:** List each open TCP port and the lab service that uses it.

**Explanation:** Why do ethical hackers scan and enumerate before attempting exploitation?

---

## 2. Password cracking and SSH brute force (1 pt)

**Screenshots:** John showing the cracked `username:password` line, and Hydra showing the valid login.

**Explanation:** What does the `$6$` prefix in `hash.txt` mean? How does the online Hydra attack differ from the offline crack?

---

## 3. Denial-of-service simulation (1 pt)

**Screenshot:** `ab` or tcpdump output.

**Explanation:** How does this HTTP flood relate to SYN or ICMP floods, and why is a real DoS harder to stop?

---

## 4. Session hijacking via cookie replay (1 pt)

**Flag file:** Confirm `session_hijack_flag.txt` is saved at the repository root.

**Explanation:** How would HTTPS and short-lived session tokens prevent this attack?

---

## 5. Web reconnaissance and SQL injection (1 pt)

**Screenshot:** Nikto or Dirb output showing the discovered directory.

**Files:** Confirm `web_recon_flag.txt`, `sqli_extracted_hash.txt`, and `sqli_cracked_password.txt` are saved at the repository root.

**Explanation:** Why is an unlinked directory still a security risk? Describe one countermeasure that would prevent this SQL injection.
