#!/usr/bin/env bash
# Runs every task check and prints a total score summary (maximum 25).
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

run_check grade_task1_scan.sh 2
run_check grade_task2_sniff.sh 2
run_check grade_task3_hash.sh 2
run_check grade_task4_hydra.sh 2
run_check grade_task5_dos.sh 2
run_check grade_task6_session.sh 3
run_check grade_task7_webrecon.sh 2
run_check grade_task8_sqli.sh 3
run_check grade_task9_crypto.sh 2
run_check grade_task10_bearer.sh 2
run_check grade_task11_idor.sh 2
run_check grade_task12_iam.sh 1

echo "==================================================="
echo "Score: ${TOTAL}/25"
