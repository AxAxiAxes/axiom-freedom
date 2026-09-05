# 🤖 AXIOM Complete Automation

**One-click setup for Windows, Linux, and macOS.**

---

## Windows Setup

### Step 1: Download Script

Download `setup-axiom-windows.bat` from:
```
https://github.com/AxAxiAxes/axiom-freedom/blob/main/setup-axiom-windows.bat
```

Or create it yourself:
- Right-click Desktop → New → Text Document
- Name: `setup-axiom.bat`
- Copy the entire script from GitHub

### Step 2: Run It

**Right-click `setup-axiom.bat` → Run as administrator**

**The script does everything:**
- ✅ Checks Docker is running
- ✅ Clones AXIOM repository
- ✅ Creates `.env` with secure password
- ✅ Creates directories
- ✅ Pulls Docker images
- ✅ Starts all services
- ✅ Shows your Local IP
- ✅ Shows your External IP
- ✅ Creates desktop shortcuts

**Total time: ~5 minutes**

---

## Linux/macOS Setup

### Step 1: Download Script

```bash
cd ~
curl -O https://raw.githubusercontent.com/AxAxiAxes/axiom-freedom/main/setup-axiom-linux.sh
chmod +x setup-axiom-linux.sh
```

### Step 2: Run It

```bash
./setup-axiom-linux.sh
```

**The script does everything automatically.**

**Total time: ~5 minutes**

---

## After Setup

### Desktop Shortcuts Created (Windows)

✅ **AXIOM.url** — Opens https://xiiom.com  
✅ **AXIOM Logs.bat** — View live logs  
✅ **Restart AXIOM.bat** — Restart services  

### Your IPs Shown

The script displays:
- **Local IP:** Your machine's private IP (192.168.X.X)
- **External IP:** Your home internet IP (XXX.XXX.XXX.XXX)

### Next Steps

1. **Update DNS** (in domain registrar):
   ```
   Domain: xiiom.com
   A Record: [Your External IP]
   TTL: 3600
   ```

2. **Configure Router Port Forwarding**:
   ```
   Port 80 -> [Your Local IP]:80
   Port 443 -> [Your Local IP]:443
   ```

3. **Access AXIOM**:
   ```
   https://xiiom.com
   ```
   (Wait 5-30 minutes for DNS to propagate)

---

## What Gets Installed

```
Docker Containers:
✅ axiom-web      (Node.js application)
✅ axiom-db       (PostgreSQL 15)
✅ axiom-proxy    (Nginx reverse proxy)

Directories:
✅ data/          (Application data)
✅ logs/          (Log files)
✅ postgres_data/ (Database storage)
✅ ssl/           (SSL certificates)

Configuration:
✅ .env           (Environment variables)
✅ docker-compose.yml (Service configuration)
✅ nginx.conf     (Reverse proxy config)
```

---

## Manage AXIOM After Setup

### View Status
```bash
docker-compose ps
```

### View Logs
```bash
docker-compose logs -f axiom-web
```

### Stop
```bash
docker-compose down
```

### Start
```bash
docker-compose up -d
```

### Restart
```bash
docker-compose restart
```

### Update
```bash
git pull
docker-compose restart
```

---

## Troubleshooting

### Docker not running
```
Start Docker Desktop/daemon and try again
```

### Git not installed
```
Windows: https://git-scm.com/download/win
Linux: sudo apt install git
macOS: brew install git
```

### Port already in use
Edit `docker-compose.yml` and change port numbers:
```yaml
axiom-web:
  ports:
    - "8080:8080"  # Change first 8080 to different port
```

### DNS not resolving
```bash
nslookup xiiom.com
dig xiiom.com
```
DNS takes 5-30 minutes to propagate.

### Can't access after setup
```bash
# Check services running
docker-compose ps

# View logs for errors
docker-compose logs axiom-web

# Restart
docker-compose restart
```

---

## Automation Complete ✅

Just run the one script — everything else is automated!

**Windows:** `setup-axiom.bat`  
**Linux/macOS:** `./setup-axiom-linux.sh`

🤖
