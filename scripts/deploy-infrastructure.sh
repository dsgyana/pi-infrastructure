#!/bin/bash
# Infrastructure deployment script for Raspberry Pi

set -e

echo "🚀 Deploying Pi Shared Infrastructure..."

# Check if .env exists
if [ ! -f shared-services/.env ]; then
    echo "❌ .env file not found. Copy .env.template to .env and configure it first."
    exit 1
fi

# Deploy shared services
cd shared-services
echo "📦 Starting shared services..."
docker-compose up -d

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 15

# Check health
if docker-compose ps | grep -q "Up (healthy)"; then
    echo "✅ Infrastructure deployed successfully!"
    echo "📊 PostgreSQL available at: localhost:5432"
    echo "🔍 Check status: docker-compose ps"
else
    echo "❌ Deployment failed. Check logs:"
    docker-compose logs
fi