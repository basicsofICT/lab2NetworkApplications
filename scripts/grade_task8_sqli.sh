#!/usr/bin/env bash
# Auto-grades Task 8: SQL Injection Exploitation & Credential Cracking (3 pts)
set -uo pipefail
POINTS=3
FILE="sqli_cracked_password.txt"
EXPECTED="Dragon2024!"

if [[ -f "${FILE}" ]] && grep -qF "${EXPECTED}" "${FILE}"; then
  echo "PASS Task8 (${POINTS}/${POINTS}): correct cracked SQLi password found in ${FILE}"
  exit 0
else
  echo "FAIL Task8 (0/${POINTS}): expected cracked password not found in ${FILE}"
  exit 1
fi
