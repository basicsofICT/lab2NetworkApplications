#!/usr/bin/env bash
# Simulates a privileged "admin" user periodically logging into the session
# lab app, generating plaintext HTTP session traffic on port 5001 that
# students can capture with tcpdump for the session hijacking exercise.
while true; do
  curl -s "http://localhost:5001/login?user=admin" -o /dev/null
  sleep 15
done
