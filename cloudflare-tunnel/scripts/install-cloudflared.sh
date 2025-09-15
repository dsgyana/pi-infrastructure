#!/bin/bash
# Cloudflare Tunnel Installation Script
# Run as: sudo ./install-cloudflared.sh
# This installs cloudflared system-wide but configures it to run as apprunner

set -e

echo "🌥️  Installing Cloudflare Tunnel (cloudflared)"
echo "=============================================="

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script with sudo"
    echo "Usage: sudo ./install-cloudflared.sh"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
    aarch64|arm64)
        CLOUDFLARED_ARCH="arm64"
        ;;
    armv7l)
        CLOUDFLARED_ARCH="arm"
        ;;
    x86_64)
        CLOUDFLARED_ARCH="amd64"
        ;;
    *)
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "📋 Detected architecture: $ARCH (cloudflared: $CLOUDFLARED_ARCH)"

# Download cloudflared
CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$CLOUDFLARED_ARCH"
TEMP_FILE="/tmp/cloudflared"

echo "📥 Downloading cloudflared..."
curl -L "$CLOUDFLARED_URL" -o "$TEMP_FILE"

# Make executable and move to system location
chmod +x "$TEMP_FILE"
mv "$TEMP_FILE" /usr/local/bin/cloudflared

echo "✅ cloudflared installed to /usr/local/bin/cloudflared"

# Verify installation
echo "🧪 Verifying installation..."
/usr/local/bin/cloudflared version

# Create cloudflare group and ensure apprunner is in it
echo "👥 Setting up user groups..."
groupadd -f cloudflare
usermod -a -G cloudflare apprunner

# Create secure directories for apprunner
echo "📁 Creating configuration directories..."
mkdir -p /opt/pi-apps/.cloudflared
chown apprunner:cloudflare /opt/pi-apps/.cloudflared
chmod 750 /opt/pi-apps/.cloudflared

# Create systemd service directory
mkdir -p /etc/systemd/system

echo ""
echo "✅ Cloudflared installation complete!"
echo ""
echo "📋 Summary:"
echo "   • Binary: /usr/local/bin/cloudflared"
echo "   • Config directory: /opt/pi-apps/.cloudflared (owned by apprunner)"
echo "   • User group: cloudflare (apprunner is member)"
echo ""
echo "🔄 Next steps:"
echo "   1. Login to Cloudflare and get your tunnel token"
echo "   2. Run: sudo -u apprunner ./setup-tunnel.sh"
echo ""