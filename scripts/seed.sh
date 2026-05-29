#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../app"
npx prisma db seed
echo "Database seeded successfully."
