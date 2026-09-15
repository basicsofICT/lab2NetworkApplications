#!/usr/bin/env bash
# Auto-grades Task 5: Denial-of-service simulation (2 pts)
set -uo pipefail
POINTS=2
FILE="dos_report.json"
THRESHOLD=900

if [[ ! -f "${FILE}" ]]; then
  echo "FAIL Task5 (0/${POINTS}): ${FILE} not found. Run the flood test and save /stats output."
  exit 1
fi

COUNT=$(python3 -c "import json; print(json.load(open('${FILE}')).get('count', 0))" 2>/dev/null || echo 0)

if [[ "${COUNT}" =~ ^[0-9]+$ ]] && [[ "${COUNT}" -ge "${THRESHOLD}" ]]; then
  echo "PASS Task5 (${POINTS}/${POINTS}): dos_report.json shows count=${COUNT} (>= ${THRESHOLD})"
  exit 0
else
  echo "FAIL Task5 (0/${POINTS}): dos_report.json count=${COUNT}, expected >= ${THRESHOLD}"
  exit 1
fi
