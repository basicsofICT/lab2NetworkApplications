#!/usr/bin/env bash
# Periodically requests an OAuth-style access token so students can recover
# a live Bearer token from HTTP traffic or /tmp/oauth_debug.log.
while true; do
  curl -s "http://localhost:5003/oauth/token" | tee -a /tmp/oauth_debug.log >/dev/null
  echo "" >> /tmp/oauth_debug.log
  sleep 15
done
