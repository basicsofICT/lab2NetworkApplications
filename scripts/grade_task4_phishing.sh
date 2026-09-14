#!/usr/bin/env bash
# Auto-grades Task 4: Phishing Email Red-Flags (2 pts)
# Heuristic keyword check against the student's write-up in yourAnswers.md.
set -uo pipefail
POINTS=2
FILE="yourAnswers.md"

if [[ ! -f "${FILE}" ]]; then
  echo "FAIL Task4 (0/${POINTS}): ${FILE} not found"
  exit 1
fi

KEYWORDS=("greeting" "link" "urgent" "sender" "grammar" "attachment" "deactivat" "verify" "threat")
COUNT=0
for kw in "${KEYWORDS[@]}"; do
  if grep -qi "${kw}" "${FILE}"; then
    COUNT=$((COUNT + 1))
  fi
done

if [[ ${COUNT} -ge 4 ]]; then
  echo "PASS Task4 (${POINTS}/${POINTS}): found ${COUNT} phishing red-flag keywords in ${FILE}"
  exit 0
else
  echo "FAIL Task4 (0/${POINTS}): only found ${COUNT} phishing red-flag keywords (need >= 4)"
  exit 1
fi
