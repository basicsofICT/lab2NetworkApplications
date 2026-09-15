#!/usr/bin/env bash
# Auto-grades Task 11: API IDOR / broken object-level auth (2 pts)
set -uo pipefail
POINTS=2
FILE="idor_flag.txt"
EXPECTED="FLAG{1d0r_b0la_2026}"

if [[ -f "${FILE}" ]] && grep -q "${EXPECTED}" "${FILE}"; then
  echo "PASS Task11 (${POINTS}/${POINTS}): IDOR flag found in ${FILE}"
  exit 0
else
  echo "FAIL Task11 (0/${POINTS}): expected flag not found in ${FILE}"
  exit 1
fi
