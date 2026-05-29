# Local Development Guide

## Prerequisites

- Node.js 20+
- pnpm 9+
- Docker and Docker Compose
- (Optional) LocalStack for Terraform testing

## Quick Start

```bash
# From the repository root
./scripts/setup.sh
```

This will:
1. Install Node.js dependencies
2. Generate the Prisma client
3. Start PostgreSQL via Docker Compose
4. Run database migrations
5. Seed the database with sample data

## Manual Setup

```bash
# Install dependencies
cd app
pnpm install

# Start PostgreSQL
cd ..
docker compose up -d postgres

# Set up the database
cd app
cp .env.example .env
npx prisma migrate dev --name init
npx prisma db seed

# Start the dev server
pnpm dev
```

## Common Commands

```bash
# Development server (with hot reload)
cd app && pnpm dev

# Run linting
cd app && pnpm lint

# Generate Prisma client after schema changes
cd app && npx prisma generate

# Create a new migration
cd app && npx prisma migrate dev --name <description>

# Reset the database
cd app && npx prisma migrate reset --force

# Build for production
cd app && pnpm build

# Run production build locally
cd app && pnpm start
```

## Docker

```bash
# Build and run everything
docker compose up --build

# Rebuild just the app
docker compose up --build app

# View logs
docker compose logs -f app

# Stop everything
docker compose down

# Stop and remove volumes (resets database)
docker compose down -v
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://opsboard:opsboard@localhost:5432/opsboard?schema=public` |
| `NODE_ENV` | Environment (development/production/test) | `development` |

## Database

The database schema is managed with Prisma migrations in `app/prisma/migrations/`.

To inspect the database directly:
```bash
docker compose exec postgres psql -U opsboard
```
