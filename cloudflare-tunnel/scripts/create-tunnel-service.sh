#!/bin/bash
# Cloudflare Tunnel Systemd Service Creator
# Run as: sudo ./create-tunnel-service.sh
# This creates a systemd service that runs the tunnel as apprunner

set -e

echo "🔧 Creating Cloudflare Tunnel Systemd Service"
echo "=============================================="

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script with sudo"
    echo "Usage: sudo ./create-tunnel-service.sh"
    exit 1
fi

# Check if config exists
CONFIG_FILE="/opt/pi-apps/.cloudflared/config.yml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Tunnel configuration not found: $CONFIG_FILE"
    echo "Please run setup-tunnel.sh first"
    exit 1
fi

echo "📝 Creating systemd service..."

# Create systemd service file
SERVICE_FILE="/etc/systemd/system/cloudflare-tunnel.service"
cat > "$SERVICE_FILE" << 'EOF'
[Unit]
Description=Cloudflare Tunnel for Pi Infrastructure
Documentation=https://developers.cloudflare.com/cloudflare-one/connections/connect-apps
After=network.target
Wants=network.target

[Service]
Type=simple
User=apprunner
Group=cloudflare
ExecStart=/usr/local/bin/cloudflared tunnel --config /opt/pi-apps/.cloudflared/config.yml run
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=cloudflared

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/opt/pi-apps/.cloudflared
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes

# Resource limits
MemoryMax=128M
CPUQuota=50%

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Service file created: $SERVICE_FILE"

# Set correct permissions
chmod 644 "$SERVICE_FILE"

# Reload systemd
echo "🔄 Reloading systemd..."
systemctl daemon-reload

echo ""
echo "✅ Cloudflare Tunnel service created successfully!"
echo ""
echo "📋 Service details:"
echo "   • Service name: cloudflare-tunnel"
echo "   • User: apprunner"
echo "   • Group: cloudflare"
echo "   • Config: /opt/pi-apps/.cloudflared/config.yml"
echo "   • Security: Hardened with systemd security features"
echo ""
echo "🔧 Service management commands:"
echo "   • Start:   sudo systemctl start cloudflare-tunnel"
echo "   • Stop:    sudo systemctl stop cloudflare-tunnel"
echo "   • Status:  sudo systemctl status cloudflare-tunnel"
echo "   • Enable:  sudo systemctl enable cloudflare-tunnel"
echo "   • Logs:    sudo journalctl -u cloudflare-tunnel -f"
echo ""
echo "⚠️  Remember to configure your domain in Cloudflare dashboard!"
echo ""