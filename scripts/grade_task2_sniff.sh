#!/usr/bin/env bash
# Auto-grades Task 2 from student capture + extracted flag (does not curl the target).
set -uo pipefail
POINTS=2
FLAG_FILE="sniff_flag.txt"
CAPTURE="sniff_capture.log"
EXPECTED="FLAG{tr4ff1c_sn1ff_2026}"

if [[ ! -f "${CAPTURE}" ]] || ! grep -q "${EXPECTED}" "${CAPTURE}"; then
  echo "FAIL Task2 (0/${POINTS}): ${CAPTURE} must exist and contain the sniffed FLAG from tcpdump ASCII output"
  exit 1
fi

if [[ -f "${FLAG_FILE}" ]] && grep -q "${EXPECTED}" "${FLAG_FILE}"; then
  echo "PASS Task2 (${POINTS}/${POINTS}): capture log and sniff_flag.txt contain the traffic flag"
  exit 0
fi

echo "FAIL Task2 (0/${POINTS}): expected flag not found in ${FLAG_FILE}"
exit 1
