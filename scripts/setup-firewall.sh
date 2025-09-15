#!/bin/bash
# UFW Firewall Setup for Raspberry Pi Production
# This script configures a secure firewall for our Pi infrastructure

set -e

echo "🔥 Setting up UFW Firewall for Raspberry Pi"
echo "==========================================="

# Check if UFW is installed
if ! command -v ufw &> /dev/null; then
    echo "📦 Installing UFW..."
    sudo apt update
    sudo apt install -y ufw
else
    echo "✅ UFW is already installed"
fi

echo ""
echo "🔧 Configuring firewall rules..."
echo ""

# Reset UFW to defaults (clean slate)
echo "🔄 Resetting UFW to defaults..."
sudo ufw --force reset

# Set default policies
echo "📋 Setting default policies..."
echo "   ❌ Default INCOMING: DENY (block everything by default)"
echo "   ✅ Default OUTGOING: ALLOW (allow all outbound traffic)"
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (current session protection)
echo "🔑 Allowing SSH access (port 22)..."
echo "   Why: Without this, you'll be locked out of your Pi!"
sudo ufw allow 22/tcp comment 'SSH access'

# Allow local network access to database (for development/debugging)
echo "🏠 Allowing local network access to PostgreSQL (port 5432)..."
echo "   Why: Your development machine can connect to database locally"
echo "   Scope: Only from local network (192.168.x.x, 10.x.x.x, 172.16-31.x.x)"
sudo ufw allow from 192.168.0.0/16 to any port 5432 comment 'PostgreSQL local network'
sudo ufw allow from 10.0.0.0/8 to any port 5432 comment 'PostgreSQL local network'
sudo ufw allow from 172.16.0.0/12 to any port 5432 comment 'PostgreSQL local network'

# Allow FastAPI backend (for Cloudflare Tunnel)
echo "🌐 Allowing FastAPI backend (port 8000)..."
echo "   Why: Cloudflare Tunnel will connect to this port"
echo "   Note: Only accessible through Cloudflare, not directly from internet"
sudo ufw allow 8000/tcp comment 'FastAPI backend for Cloudflare Tunnel'

# Allow HTTP/HTTPS (optional - for direct web access if needed)
echo "🌍 Allowing HTTP/HTTPS (ports 80, 443) - optional..."
echo "   Why: In case you want direct web access (not just through tunnel)"
read -p "   Allow direct HTTP/HTTPS access? (y/N): " allow_web
if [[ $allow_web =~ ^[Yy]$ ]]; then
    sudo ufw allow 80/tcp comment 'HTTP direct access'
    sudo ufw allow 443/tcp comment 'HTTPS direct access'
    echo "   ✅ HTTP/HTTPS allowed"
else
    echo "   ⏭️  HTTP/HTTPS skipped (tunnel-only access)"
fi

echo ""
echo "📊 Current firewall rules:"
sudo ufw show added

echo ""
echo "⚠️  IMPORTANT: About to enable firewall..."
echo "   ✅ SSH (port 22) is allowed - you won't be locked out"
echo "   ✅ Database (port 5432) allowed from local network only"
echo "   ✅ FastAPI (port 8000) allowed for Cloudflare Tunnel"
echo ""

read -p "Enable firewall now? (y/N): " enable_fw
if [[ $enable_fw =~ ^[Yy]$ ]]; then
    echo "🔥 Enabling UFW firewall..."
    sudo ufw --force enable
    echo ""
    echo "✅ Firewall is now active and enabled on boot"
    echo ""
    echo "📋 Final firewall status:"
    sudo ufw status verbose
else
    echo "⏸️  Firewall configured but not enabled"
    echo "   To enable later: sudo ufw enable"
fi

echo ""
echo "🎉 Firewall setup complete!"
echo ""
echo "📋 What was configured:"
echo "   ✅ SSH access (port 22) - for remote management"
echo "   ✅ PostgreSQL (port 5432) - local network only"
echo "   ✅ FastAPI (port 8000) - for Cloudflare Tunnel"
echo "   ❌ All other ports blocked by default"
echo ""
echo "🔒 Security notes:"
echo "   • Database is NOT accessible from internet"
echo "   • Only FastAPI will be exposed via Cloudflare Tunnel"
echo "   • SSH remains accessible for management"
echo "   • All other services are blocked"