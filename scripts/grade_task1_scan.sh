#!/usr/bin/env bash
# Auto-grades Task 1: Scanning and sniffing (1 pt)
# Awards the point from nmap_scan.txt. The tcpdump screenshot is reviewed in yourAnswers.md.
set -uo pipefail
POINTS=1
FILE="nmap_scan.txt"

if [[ ! -f "${FILE}" ]]; then
  echo "FAIL Task1 (0/${POINTS}): ${FILE} not found. Save nmap output with: nmap ... -oN nmap_scan.txt"
  exit 1
fi

REQUIRED_PORTS=(22 5001 5002 8000 8080)
MISSING=()
for port in "${REQUIRED_PORTS[@]}"; do
  if grep -Eq "${port}/tcp[[:space:]]+open|${port}/open/tcp" "${FILE}"; then
    continue
  fi
  MISSING+=("${port}")
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "PASS Task1 (${POINTS}/${POINTS}): nmap_scan.txt lists all required open lab ports"
  exit 0
else
  echo "FAIL Task1 (0/${POINTS}): missing open ports in ${FILE}: ${MISSING[*]}"
  exit 1
fi
