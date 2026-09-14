#!/usr/bin/env bash
# Auto-grades Task 6: Session Hijacking via Cookie Theft & Replay (3 pts)
set -uo pipefail
POINTS=3
FILE="session_hijack_flag.txt"
EXPECTED="FLAG{s3ss10n_hijack_2026}"

if [[ -f "${FILE}" ]] && grep -q "${EXPECTED}" "${FILE}"; then
  echo "PASS Task6 (${POINTS}/${POINTS}): valid session hijack flag found in ${FILE}"
  exit 0
else
  echo "FAIL Task6 (0/${POINTS}): expected flag not found in ${FILE}"
  exit 1
fi
