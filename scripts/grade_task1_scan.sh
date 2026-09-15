#!/usr/bin/env bash
# Auto-grades Task 1 from the student's nmap_scan.txt (does not re-scan).
set -uo pipefail
POINTS=2
FILE="nmap_scan.txt"

if [[ ! -f "${FILE}" ]]; then
  echo "FAIL Task1 (0/${POINTS}): ${FILE} not found"
  exit 1
fi

REQUIRED_PORTS=(22 5001 5002 5003 8000 8080 8081)
MISSING=()
for port in "${REQUIRED_PORTS[@]}"; do
  if grep -Eq "(^|[[:space:]])${port}/tcp[[:space:]]+open|[[:space:]]${port}/open/tcp" "${FILE}"; then
    continue
  fi
  MISSING+=("${port}")
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "PASS Task1 (${POINTS}/${POINTS}): nmap_scan.txt lists all required open lab ports"
  exit 0
fi

echo "FAIL Task1 (0/${POINTS}): missing open ports in ${FILE}: ${MISSING[*]}"
echo "Hint: run bash scripts/start_services.sh in the Codespace, wait until it says all ports are listening,"
echo "then scan a wide range (not 1-1000): nmap -sT -sV -p 1-10000 127.0.0.1 -oN nmap_scan.txt"
exit 1
