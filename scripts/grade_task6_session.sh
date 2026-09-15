#!/usr/bin/env bash
# Auto-grades Task 6 from capture evidence plus replayed flag (does not steal a cookie).
set -uo pipefail
POINTS=3
FLAG_FILE="session_hijack_flag.txt"
CAPTURE="session_capture.log"
EXPECTED="FLAG{s3ss10n_hijack_2026}"

if [[ ! -f "${CAPTURE}" ]] || ! grep -q "session=" "${CAPTURE}"; then
  echo "FAIL Task6 (0/${POINTS}): ${CAPTURE} must exist and contain a sniffed session= cookie"
  exit 1
fi

if [[ -f "${FLAG_FILE}" ]] && grep -q "${EXPECTED}" "${FLAG_FILE}"; then
  echo "PASS Task6 (${POINTS}/${POINTS}): capture contains a session cookie and flag file is valid"
  exit 0
fi

echo "FAIL Task6 (0/${POINTS}): expected flag not found in ${FLAG_FILE}"
exit 1
