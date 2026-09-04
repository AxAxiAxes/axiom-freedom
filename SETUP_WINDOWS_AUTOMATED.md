# 🤖 AXIOM Automated Windows Setup

**One-click setup for Windows machines.**

---

## What It Does

The `setup-windows.bat` script automates:

✅ Checks Docker Desktop is installed  
✅ Checks WSL2 is installed  
✅ Verifies Docker daemon is running  
✅ Creates `.env` file with secure password  
✅ Creates required directories  
✅ Pulls Docker images  
✅ Starts all services  
✅ Tests application health  
✅ Gets your local and external IP  
✅ Creates desktop shortcuts  

---

## Setup (5 minutes)

### Step 1: Install Docker Desktop

Download: https://www.docker.com/products/docker-desktop

**Install → Restart Windows**

### Step 2: Clone AXIOM Repo

**In PowerShell:**

```powershell
cd C:\Users\YourUsername
git clone https://github.com/AxAxiAxes/axiom-freedom.git
cd axiom-freedom
```

### Step 3: Run Setup Script

**Right-click `setup-windows.bat` → Run as administrator**

The script will:
1. Check Docker/WSL2
2. Generate secure password
3. Pull Docker images
4. Start services
5. Get your IPs
6. Create shortcuts

**Wait ~2 minutes for completion.**

---

## After Setup

### Desktop Shortcuts Created

✅ `AXIOM Web Interface.url` — Opens https://xiiom.com  
✅ `AXIOM Logs.bat` — View live logs  
✅ `Restart AXIOM.bat` — Restart services  

### Next Steps

1. **Update DNS** (in your domain registrar):
   - Domain: `xiiom.com`
   - A Record: `[Your External IP from setup output]`
   - TTL: 3600

2. **Configure Router Port Forwarding**:
   - Port 80 → Your local IP:80
   - Port 443 → Your local IP:443

3. **Access AXIOM** (after DNS propagates):
   ```
   https://xiiom.com
   ```

---

## Manage AXIOM

### View Status
```powershell
docker-compose ps
```

### View Logs
```powershell
docker-compose logs -f axiom-web
```

### Stop
```powershell
docker-compose down
```

### Start
```powershell
docker-compose up -d
```

### Restart
```powershell
docker-compose restart
```

---

## Dynamic DNS (Optional)

If your home IP changes frequently:

### Setup DuckDNS (Free)

1. Go to: https://www.duckdns.org
2. Sign up with any GitHub/Reddit/Discord account
3. Create a domain (e.g., `axiom-freedom.duckdns.org`)
4. Get your token

### Edit DNS Update Script

Edit `dns-update-windows.bat`:

```batch
set DUCKDNS_DOMAIN=axiom-freedom
set DUCKDNS_TOKEN=your_actual_token_here
```

### Run Every 5 Minutes

**Task Scheduler:**

1. Press `Win + R`
2. Type: `taskschd.msc`
3. Right-click → New Basic Task
4. Name: `AXIOM DNS Update`
5. Trigger: Recurring, every 5 minutes
6. Action: Run script `dns-update-windows.bat`

Now your DNS updates automatically!

---

## Troubleshooting

### "Docker not found"
- Docker Desktop not installed
- Docker not in PATH
- Restart computer after Docker install

### "WSL2 not found"
- Run: `wsl --install`
- Restart computer
- Run setup script again

### "Docker daemon not running"
- Open Docker Desktop
- Wait for it to fully start
- Run setup script again

### "Services won't start"
```powershell
docker-compose logs
# Shows error details
```

### Port already in use
Edit `docker-compose.yml`:

```yaml
axiom-web:
  ports:
    - "8080:8080"    # Change first 8080 to different port
```

---

## Keep AXIOM Running 24/7

### Option 1: Keep Machine On

Settings → Power → Sleep → Never

### Option 2: Wake-on-LAN

Configure in BIOS to wake on network activity:
1. Restart, press Delete/F2 (varies by PC)
2. Look for "Wake on LAN"
3. Enable it

### Option 3: Use Scheduled Task

```powershell
# Start Docker at login
$trigger = New-ScheduledTaskTrigger -AtLogon
$action = New-ScheduledTaskAction -Execute "C:\Program Files\Docker\Docker\Docker.exe"
Register-ScheduledTask -TaskName "Start Docker" -Trigger $trigger -Action $action
```

---

## Uninstall

To remove AXIOM:

```powershell
cd C:\Users\YourUsername\axiom-freedom
docker-compose down -v
# Removes containers and data
```

---

## Security Notes

🔐 Database password is random and secure  
🔐 Stored in `.env` (don't commit to GitHub)  
🔐 Change default credentials if needed  
🔐 Keep firewall enabled  
🔐 Only forward ports 80/443  

---

**AXIOM Automated Setup Ready! 🚀**

Just run `setup-windows.bat` as admin.

🤖
