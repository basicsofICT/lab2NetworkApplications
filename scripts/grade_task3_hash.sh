#!/usr/bin/env bash
# Auto-grades Task 3: Hash cracking with John the Ripper (2 pts)
set -uo pipefail
POINTS=2

if [[ ! -f hash.txt || ! -f passwords.txt ]]; then
  echo "FAIL Task3 (0/${POINTS}): hash.txt or passwords.txt not found"
  exit 1
fi

john --wordlist=passwords.txt hash.txt >/dev/null 2>&1 || true
RESULT=$(john --show hash.txt 2>/dev/null)

if echo "${RESULT}" | grep -q "testuser:testpass"; then
  echo "PASS Task3 (${POINTS}/${POINTS}): password hash cracked successfully"
  exit 0
else
  echo "FAIL Task3 (0/${POINTS}): could not verify cracked password"
  exit 1
fi
