#!/bin/sh
set -e

echo "Installing dependencies..."
pnpm install

echo "Generating Prisma client..."
npx prisma generate

echo "Applying database migrations..."
npx prisma migrate deploy

echo "Starting Next.js..."
pnpm dev
