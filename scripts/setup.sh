#!/usr/bin/env bash
set -euo pipefail

echo "=== OpsBoard Setup ==="
echo ""

# Check dependencies
command -v docker >/dev/null 2>&1 || { echo "Error: docker is required but not installed."; exit 1; }
command -v node >/dev/null 2>&1 || { echo "Error: node is required but not installed."; exit 1; }
command -v pnpm >/dev/null 2>&1 || { echo "Error: pnpm is required. Install with: npm install -g pnpm"; exit 1; }

# Navigate to app directory
cd "$(dirname "$0")/../app"

# Install dependencies
echo "[1/5] Installing dependencies..."
pnpm install --frozen-lockfile

# Generate Prisma client
echo "[2/5] Generating Prisma client..."
npx prisma generate

# Start PostgreSQL
echo "[3/5] Starting PostgreSQL..."
cd ..
docker compose up -d postgres
echo "Waiting for PostgreSQL to be ready..."
sleep 3

# Run migrations
echo "[4/5] Running database migrations..."
cd app
npx prisma migrate dev --name init

# Seed database
echo "[5/5] Seeding database..."
npx prisma db seed

echo ""
echo "=== Setup Complete ==="
echo "Run 'cd app && pnpm dev' to start the development server."
echo "The application will be available at http://localhost:3000"
