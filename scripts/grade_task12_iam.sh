#!/usr/bin/env bash
# Auto-grades Task 12: Leaked cloud credentials and overpermissive IAM (1 pt)
set -uo pipefail
POINTS=1
KEY_FILE="cloud_access_key.txt"
RISK_FILE="iam_risk.txt"
EXPECTED_KEY="L4BCL0UDK3Y2026"

if [[ ! -f "${KEY_FILE}" ]] || ! grep -q "${EXPECTED_KEY}" "${KEY_FILE}"; then
  echo "FAIL Task12 (0/${POINTS}): expected access key not found in ${KEY_FILE}"
  exit 1
fi

if [[ -f "${RISK_FILE}" ]] && grep -q "Action" "${RISK_FILE}" && grep -q "\*" "${RISK_FILE}"; then
  echo "PASS Task12 (${POINTS}/${POINTS}): leaked key and wildcard IAM action identified"
  exit 0
fi

echo "FAIL Task12 (0/${POINTS}): ${RISK_FILE} must identify the IAM Action that is a wildcard (*)"
exit 1
