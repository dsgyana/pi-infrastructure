# Pi Infrastructure

## 🏗️ Shared Infrastructure for Raspberry Pi

This repository contains shared infrastructure services for multiple applications running on Raspberry Pi.

### 📦 Services Included:
- **PostgreSQL**: Shared database for all applications
- **Monitoring**: Prometheus + Grafana stack
- **Backup**: Automated database backup system

### 🚀 Quick Start:
```bash
# Deploy infrastructure
cd shared-services
docker-compose up -d

# Check status
docker-compose ps
```

### 📁 Structure:
- `shared-services/` - Docker Compose configurations
- `scripts/` - Setup and maintenance scripts  
- `configs/` - Service configuration files

---
**Infrastructure as Code for Raspberry Pi**