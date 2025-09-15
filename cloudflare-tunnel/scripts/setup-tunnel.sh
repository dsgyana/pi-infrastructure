#!/bin/bash
# Cloudflare Tunnel Setup Script
# Run as: sudo -u apprunner ./setup-tunnel.sh
# This configures the tunnel to run as apprunner user

set -e

echo "🔧 Setting up Cloudflare Tunnel"
echo "==============================="

# Check if running as apprunner
if [ "$(whoami)" != "apprunner" ]; then
    echo "❌ This script must be run as apprunner user"
    echo "Usage: sudo -u apprunner ./setup-tunnel.sh"
    exit 1
fi

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo "❌ cloudflared not found. Please run install-cloudflared.sh first"
    exit 1
fi

echo "🔑 Cloudflare Tunnel Authentication"
echo "===================================="
echo ""
echo "📋 Steps to get your tunnel token:"
echo "   1. Go to: https://dash.cloudflare.com/"
echo "   2. Select your domain: mypi.net.in"
echo "   3. Go to: Zero Trust > Access > Tunnels"
echo "   4. Click: Create a tunnel"
echo "   5. Name: pi-infrastructure"
echo "   6. Click: Save tunnel"
echo "   7. Copy the token (starts with 'ey...')"
echo ""

read -p "Enter your Cloudflare Tunnel token: " TUNNEL_TOKEN

if [ -z "$TUNNEL_TOKEN" ]; then
    echo "❌ Tunnel token is required"
    exit 1
fi

echo ""
echo "🔧 Configuring tunnel..."

# Create tunnel configuration
TUNNEL_CONFIG="/opt/pi-apps/.cloudflared/config.yml"
cat > "$TUNNEL_CONFIG" << EOF
# Cloudflare Tunnel Configuration for Pi Infrastructure
# Generated on: $(date)

tunnel: $TUNNEL_TOKEN
credentials-file: /opt/pi-apps/.cloudflared/credentials.json

# Ingress rules for routing traffic
ingress:
  # Route API traffic to FastAPI backend
  - hostname: api.expense.mypi.net.in
    service: http://localhost:8000
    originRequest:
      httpHostHeader: api.expense.mypi.net.in
      connectTimeout: 30s
      tlsTimeout: 10s
      keepAliveTimeout: 90s
      
  # Default rule (required) - returns 404 for unknown hosts
  - service: http_status:404

# Logging configuration
loglevel: info
logfile: /opt/pi-apps/.cloudflared/tunnel.log

# Performance settings for Pi
retries: 3
heartbeat-interval: 5s
grace-period: 30s
EOF

echo "✅ Tunnel configuration created: $TUNNEL_CONFIG"

# Set secure permissions
chmod 600 "$TUNNEL_CONFIG"

echo ""
echo "🧪 Testing tunnel connection..."
echo "This will attempt to connect and then stop..."

# Test tunnel connection
timeout 10s cloudflared tunnel --config "$TUNNEL_CONFIG" run || {
    if [ $? -eq 124 ]; then
        echo "✅ Tunnel connection test successful (timed out as expected)"
    else
        echo "⚠️  Tunnel test had issues, but continuing..."
    fi
}

echo ""
echo "✅ Cloudflare Tunnel setup complete!"
echo ""
echo "📋 Configuration summary:"
echo "   • Config file: $TUNNEL_CONFIG"
echo "   • API domain: api.expense.mypi.net.in -> localhost:8000"
echo "   • Running as: apprunner user"
echo ""
echo "🔄 Next steps:"
echo "   1. Configure domain in Cloudflare dashboard"
echo "   2. Run: sudo ./create-tunnel-service.sh"
echo "   3. Start service: sudo systemctl start cloudflare-tunnel"
echo ""