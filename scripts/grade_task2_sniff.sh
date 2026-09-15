#!/usr/bin/env bash
# Auto-grades Task 2: Packet sniffing (2 pts)
set -uo pipefail
POINTS=2
FILE="sniff_flag.txt"
EXPECTED="FLAG{tr4ff1c_sn1ff_2026}"

if [[ -f "${FILE}" ]] && grep -q "${EXPECTED}" "${FILE}"; then
  echo "PASS Task2 (${POINTS}/${POINTS}): sniff flag found in ${FILE}"
  exit 0
else
  echo "FAIL Task2 (0/${POINTS}): expected flag not found in ${FILE}"
  exit 1
fi
