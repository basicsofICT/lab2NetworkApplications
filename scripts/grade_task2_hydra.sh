#!/usr/bin/env bash
# Auto-grades Task 2: SSH Brute-Force with Hydra (3 pts)
set -uo pipefail
POINTS=3

if [[ ! -f users.txt || ! -f passwords.txt ]]; then
  echo "FAIL Task2 (0/${POINTS}): users.txt or passwords.txt not found"
  exit 1
fi

if ! command -v hydra >/dev/null 2>&1; then
  echo "FAIL Task2 (0/${POINTS}): hydra is not installed"
  exit 1
fi

OUT=$(hydra -L users.txt -P passwords.txt ssh://localhost -t 4 2>/dev/null || true)

if echo "${OUT}" | grep -q "login: testuser"; then
  echo "PASS Task2 (${POINTS}/${POINTS}): SSH brute-force found valid credentials"
  exit 0
else
  echo "FAIL Task2 (0/${POINTS}): brute-force did not confirm valid credentials"
  exit 1
fi
