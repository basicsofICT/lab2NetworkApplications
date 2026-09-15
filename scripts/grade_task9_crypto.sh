#!/usr/bin/env bash
# Auto-grades Task 9: Cryptography (2 pts)
# Both the Base64-decoded flag and the cracked MD5 password must be present.
set -uo pipefail
POINTS=2
B64_FILE="crypto_b64_flag.txt"
B64_FLAG="FLAG{b64_d3c0de_ok}"
MD5_FILE="crypto_md5.txt"
MD5_PASSWORD="letmein"

if [[ ! -f "${B64_FILE}" ]] || ! grep -q "${B64_FLAG}" "${B64_FILE}"; then
  echo "FAIL Task9 (0/${POINTS}): expected Base64 flag not found in ${B64_FILE}"
  exit 1
fi

if [[ -f "${MD5_FILE}" ]] && grep -qF "${MD5_PASSWORD}" "${MD5_FILE}"; then
  echo "PASS Task9 (${POINTS}/${POINTS}): Base64 flag and cracked MD5 password found"
  exit 0
else
  echo "FAIL Task9 (0/${POINTS}): expected MD5 plaintext not found in ${MD5_FILE}"
  exit 1
fi
