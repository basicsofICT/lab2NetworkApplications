#!/usr/bin/env bash
# Auto-grades Task 8 from extracted hash + cracked password files (does not exploit SQLi).
set -uo pipefail
POINTS=3
HASH_FILE="sqli_extracted_hash.txt"
PASS_FILE="sqli_cracked_password.txt"
EXPECTED_PASSWORD="Dragon2024!"

if [[ ! -f "${HASH_FILE}" ]] || ! grep -q '\$6\$' "${HASH_FILE}"; then
  echo "FAIL Task8 (0/${POINTS}): ${HASH_FILE} must contain the extracted SHA-512 crypt hash (\$6\$)"
  exit 1
fi

if [[ -f "${PASS_FILE}" ]] && grep -qF "${EXPECTED_PASSWORD}" "${PASS_FILE}"; then
  echo "PASS Task8 (${POINTS}/${POINTS}): extracted hash and cracked SQLi password found"
  exit 0
fi

echo "FAIL Task8 (0/${POINTS}): expected cracked password not found in ${PASS_FILE}"
exit 1
