#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:3000}"

echo "Testing health endpoint at $BASE_URL/api/health..."
echo ""

response=$(curl -s -w "\n%{http_code}" "$BASE_URL/api/health" 2>/dev/null)
http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | head -1)

if [ "$http_code" = "200" ]; then
  echo "Status: OK ($http_code)"
  echo "Response: $body"
else
  echo "Status: FAILED ($http_code)"
  echo "Response: $body"
  exit 1
fi
