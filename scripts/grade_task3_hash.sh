#!/usr/bin/env bash
# Auto-grades Task 3 from the student's john --show output (does not run john).
set -uo pipefail
POINTS=2
FILE="cracked_hash.txt"

if [[ ! -f "${FILE}" ]]; then
  echo "FAIL Task3 (0/${POINTS}): ${FILE} not found. Save john --show output to cracked_hash.txt"
  exit 1
fi

if grep -q "testuser:password" "${FILE}"; then
  echo "PASS Task3 (${POINTS}/${POINTS}): cracked credentials found in ${FILE}"
  exit 0
fi

echo "FAIL Task3 (0/${POINTS}): ${FILE} must contain the cracked username:password line from john --show"
exit 1
