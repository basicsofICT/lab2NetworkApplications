#!/usr/bin/env bash
# Auto-grades Task 5: Web reconnaissance and SQL injection (1 pt)
# Both the hidden-directory flag and the cracked SQLi password must be present.
set -uo pipefail
POINTS=1
RECON_FILE="web_recon_flag.txt"
RECON_FLAG="FLAG{w3b_r3c0n_h1dd3n_admin}"
SQLI_FILE="sqli_cracked_password.txt"
SQLI_PASSWORD="Dragon2024!"

if [[ ! -f "${RECON_FILE}" ]] || ! grep -q "${RECON_FLAG}" "${RECON_FILE}"; then
  echo "FAIL Task5 (0/${POINTS}): expected web recon flag not found in ${RECON_FILE}"
  exit 1
fi

if [[ -f "${SQLI_FILE}" ]] && grep -qF "${SQLI_PASSWORD}" "${SQLI_FILE}"; then
  echo "PASS Task5 (${POINTS}/${POINTS}): web recon flag and cracked SQLi password found"
  exit 0
else
  echo "FAIL Task5 (0/${POINTS}): expected cracked SQLi password not found in ${SQLI_FILE}"
  exit 1
fi
