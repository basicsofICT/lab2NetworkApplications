#!/usr/bin/env bash
# Auto-grades Task 4: Session hijacking via cookie replay (1 pt)
set -uo pipefail
POINTS=1
FILE="session_hijack_flag.txt"
EXPECTED="FLAG{s3ss10n_hijack_2026}"

if [[ -f "${FILE}" ]] && grep -q "${EXPECTED}" "${FILE}"; then
  echo "PASS Task4 (${POINTS}/${POINTS}): valid session hijack flag found in ${FILE}"
  exit 0
else
  echo "FAIL Task4 (0/${POINTS}): expected flag not found in ${FILE}"
  exit 1
fi
