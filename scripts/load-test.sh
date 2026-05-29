#!/bin/bash
# Simple load test against the running OpsBoard container.
# Sends sequential requests to /api/health and reports failures.

URL="${1:-http://localhost:3000/api/health}"
COUNT="${2:-600}"

echo "Sending $COUNT requests to $URL..."

for i in $(seq 1 "$COUNT"); do
  status=$(curl -sf -o /dev/null -w "%{http_code}" "$URL" 2>/dev/null)
  if [ $? -ne 0 ] || [ "$status" = "000" ]; then
    echo "Container stopped responding at request $i"
    exit 1
  fi
  if [ $((i % 100)) -eq 0 ]; then
    echo "  $i/$COUNT requests sent (last status: $status)"
  fi
done

echo "Completed $COUNT requests without failure"
