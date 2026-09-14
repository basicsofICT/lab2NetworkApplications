#!/usr/bin/env bash
# Auto-grades Task 7: Web Server & Web App Reconnaissance (2 pts)
set -uo pipefail
POINTS=2
FILE="web_recon_flag.txt"
EXPECTED="FLAG{w3b_r3c0n_h1dd3n_admin}"

if [[ -f "${FILE}" ]] && grep -q "${EXPECTED}" "${FILE}"; then
  echo "PASS Task7 (${POINTS}/${POINTS}): hidden directory flag found in ${FILE}"
  exit 0
else
  echo "FAIL Task7 (0/${POINTS}): expected flag not found in ${FILE}"
  exit 1
fi
