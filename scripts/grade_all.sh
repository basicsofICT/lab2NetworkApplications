#!/usr/bin/env bash
# Runs every task check and prints a total score summary (maximum 5).
set -uo pipefail
cd "$(dirname "$0")/.."

echo "================ Lab Auto-Grader ================"
TOTAL=0

run_check() {
  local script="$1"
  local points="$2"
  if bash "scripts/${script}"; then
    TOTAL=$((TOTAL + points))
  fi
}

run_check grade_task1_scan.sh 1
run_check grade_task2_creds.sh 1
run_check grade_task3_dos.sh 1
run_check grade_task4_session.sh 1
run_check grade_task5_web.sh 1

echo "==================================================="
echo "Score: ${TOTAL}/5"
