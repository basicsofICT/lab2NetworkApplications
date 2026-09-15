#!/usr/bin/env bash
# Auto-grades Task 10: Stolen Bearer token replay (2 pts)
set -uo pipefail
POINTS=2
FILE="bearer_flag.txt"
EXPECTED="FLAG{b34r3r_t0k3n_2026}"

if [[ -f "${FILE}" ]] && grep -q "${EXPECTED}" "${FILE}"; then
  echo "PASS Task10 (${POINTS}/${POINTS}): Bearer token flag found in ${FILE}"
  exit 0
else
  echo "FAIL Task10 (0/${POINTS}): expected flag not found in ${FILE}"
  exit 1
fi
