#!/usr/bin/env bash
# Auto-grades Task 4 from the student's saved Hydra output (does not run hydra).
set -uo pipefail
POINTS=2
FILE="hydra_ssh.txt"

if [[ ! -f "${FILE}" ]]; then
  echo "FAIL Task4 (0/${POINTS}): ${FILE} not found. Save Hydra's stdout to hydra_ssh.txt"
  exit 1
fi

if grep -q "login: testuser" "${FILE}" && grep -q "password: testpass" "${FILE}"; then
  echo "PASS Task4 (${POINTS}/${POINTS}): Hydra output in ${FILE} shows valid SSH credentials"
  exit 0
fi

echo "FAIL Task4 (0/${POINTS}): ${FILE} must contain Hydra's successful login and password lines"
exit 1
