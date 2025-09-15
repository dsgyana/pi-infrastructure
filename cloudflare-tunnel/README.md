# Cloudflare Tunnel Setup for Pi Infrastructure

This directory contains the secure Cloudflare Tunnel setup for exposing the Pi services to the internet via `api.expense.mypi.net.in`.

## 🏗️ Architecture

```
Internet → Cloudflare Edge → Cloudflare Tunnel → Pi (localhost:8000) → FastAPI
```

## 🔐 Security Model

- **Installation**: Runs as `root` (system-level setup)
- **Configuration**: Managed by `apprunner` user
- **Runtime**: Service runs as `apprunner` with restricted permissions
- **Credentials**: Stored in `/opt/pi-apps/.cloudflared/` (apprunner-only access)

## 📁 Directory Structure

```
cloudflare-tunnel/
├── scripts/
│   ├── install-cloudflared.sh      # Install cloudflared binary (sudo)
│   ├── setup-tunnel.sh             # Configure tunnel (apprunner)
│   └── create-tunnel-service.sh    # Create systemd service (sudo)
├── config/
│   └── config.yml.template         # Configuration template
└── README.md                       # This file
```

## 🚀 Setup Process

### Step 1: Install Cloudflared (as root)
```bash
cd /opt/pi-apps/pi-infrastructure/cloudflare-tunnel/scripts
sudo ./install-cloudflared.sh
```

### Step 2: Setup Tunnel (as apprunner)
```bash
sudo -u apprunner ./setup-tunnel.sh
```
You'll need your Cloudflare tunnel token from the dashboard.

### Step 3: Create Service (as root)
```bash
sudo ./create-tunnel-service.sh
```

### Step 4: Start Service
```bash
sudo systemctl enable cloudflare-tunnel
sudo systemctl start cloudflare-tunnel
```

## 🔧 Configuration

### Domain Routing
- `api.expense.mypi.net.in` → `localhost:8000` (FastAPI backend)

### Security Features
- Runs as non-privileged `apprunner` user
- Systemd security hardening enabled
- Resource limits applied (128MB RAM, 50% CPU)
- Protected directories and kernel access

## 📊 Management Commands

```bash
# Service status
sudo systemctl status cloudflare-tunnel

# View logs
sudo journalctl -u cloudflare-tunnel -f

# Restart service
sudo systemctl restart cloudflare-tunnel

# Stop service
sudo systemctl stop cloudflare-tunnel
```

## 🔍 Troubleshooting

### Check Configuration
```bash
sudo -u apprunner cloudflared tunnel --config /opt/pi-apps/.cloudflared/config.yml validate
```

### Test Connection
```bash
sudo -u apprunner cloudflared tunnel --config /opt/pi-apps/.cloudflared/config.yml run
```

### View Service Logs
```bash
sudo journalctl -u cloudflare-tunnel --since "1 hour ago"
```

## 📋 Prerequisites

1. **Cloudflare Account**: Free account at cloudflare.com
2. **Domain**: `mypi.net.in` added to Cloudflare
3. **Tunnel**: Created in Cloudflare Zero Trust dashboard
4. **FastAPI**: Backend service running on localhost:8000

## 🔒 Security Notes

- Tunnel credentials are stored securely with 600 permissions
- Service runs with minimal system access
- All traffic is encrypted end-to-end via Cloudflare
- No inbound ports need to be opened on router/firewall