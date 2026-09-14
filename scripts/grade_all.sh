#!/usr/bin/env bash
# Runs every auto-gradable task check and prints a total score summary.
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

run_check grade_task1_hash.sh 2
run_check grade_task2_hydra.sh 3
echo "SKIP Task3 (0/3): Traffic Capture & Analysis requires manual screenshot review"
run_check grade_task4_phishing.sh 2
run_check grade_task5_dos.sh 2
run_check grade_task6_session.sh 3
run_check grade_task7_webrecon.sh 2
run_check grade_task8_sqli.sh 3

echo "==================================================="
echo "Auto-gradable score: ${TOTAL}/17"
echo "Task 3 (3 pts) is graded manually from the submitted screenshot."
echo "Total lab score (with Task 3 reviewed): ${TOTAL}/17 + up to 3 = up to 20"
