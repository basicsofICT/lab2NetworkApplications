#!/usr/bin/env bash
# Auto-grades Task 2: Password cracking and SSH brute force (1 pt)
# Both the offline hash crack and the online Hydra attack must succeed.
set -uo pipefail
POINTS=1

if [[ ! -f hash.txt || ! -f passwords.txt ]]; then
  echo "FAIL Task2 (0/${POINTS}): hash.txt or passwords.txt not found"
  exit 1
fi

john --wordlist=passwords.txt hash.txt >/dev/null 2>&1 || true
RESULT=$(john --show hash.txt 2>/dev/null)

if ! echo "${RESULT}" | grep -q "testuser:testpass"; then
  echo "FAIL Task2 (0/${POINTS}): could not verify cracked password from hash.txt"
  exit 1
fi

if [[ ! -f users.txt ]]; then
  echo "FAIL Task2 (0/${POINTS}): users.txt not found"
  exit 1
fi

if ! command -v hydra >/dev/null 2>&1; then
  echo "FAIL Task2 (0/${POINTS}): hydra is not installed"
  exit 1
fi

OUT=$(hydra -L users.txt -P passwords.txt ssh://localhost -t 4 2>/dev/null || true)

if echo "${OUT}" | grep -q "login: testuser"; then
  echo "PASS Task2 (${POINTS}/${POINTS}): hash cracked and SSH brute-force found valid credentials"
  exit 0
else
  echo "FAIL Task2 (0/${POINTS}): brute-force did not confirm valid credentials"
  exit 1
fi
