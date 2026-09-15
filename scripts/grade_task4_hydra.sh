#!/usr/bin/env bash
# Auto-grades Task 4 from the student's Hydra output (does not run hydra).
set -uo pipefail
POINTS=2
FILE="hydra_ssh.txt"
USERS="users.txt"
PASSES="passwords.txt"

if [[ ! -f "${USERS}" ]]; then
  echo "FAIL Task4 (0/${POINTS}): ${USERS} not found (needed for Hydra -L)"
  exit 1
fi

if [[ ! -f "${PASSES}" ]]; then
  echo "FAIL Task4 (0/${POINTS}): ${PASSES} not found (needed for Hydra -P)"
  exit 1
fi

if ! grep -qx "testuser" "${USERS}"; then
  echo "FAIL Task4 (0/${POINTS}): ${USERS} must contain the lab SSH username"
  exit 1
fi

if ! grep -qx "password" "${PASSES}"; then
  echo "FAIL Task4 (0/${POINTS}): ${PASSES} must contain the lab SSH password candidates"
  exit 1
fi

if [[ ! -f "${FILE}" ]]; then
  echo "FAIL Task4 (0/${POINTS}): hydra_ssh.txt not found. Hydra does not create this file; save its output yourself, e.g. hydra ... 2>&1 | tee hydra_ssh.txt"
  exit 1
fi

if grep -q "login: testuser" "${FILE}" && grep -q "password: password" "${FILE}"; then
  echo "PASS Task4 (${POINTS}/${POINTS}): users.txt, passwords.txt, and Hydra output are present"
  exit 0
fi

echo "FAIL Task4 (0/${POINTS}): ${FILE} must contain Hydra's successful login and password lines"
exit 1
