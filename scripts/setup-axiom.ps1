$ErrorActionPreference = 'Stop'

$RootDir = (Resolve-Path "$PSScriptRoot/..").Path
$EnvFile = Join-Path $RootDir '.env'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw 'Docker CLI is required.'
}

docker info | Out-Null
if ($LASTEXITCODE -ne 0) {
  throw 'Docker daemon is not running.'
}

$drive = (Get-Item $RootDir).PSDrive
if (($drive.Free / 1GB) -lt 2) {
  throw 'At least 2GB of free disk space is required.'
}

New-Item -ItemType Directory -Force -Path (Join-Path $RootDir 'postgres_data') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $RootDir 'logs') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $RootDir 'ssl') | Out-Null

if (-not (Test-Path $EnvFile)) {
  $bytes = New-Object byte[] 24
  [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
  $dbPassword = [Convert]::ToBase64String($bytes).Replace('/','a').Replace('+','b').Substring(0,24)

  @"
AXIOM_PORT=8080
AXIOM_ENV=production
AXIOM_LOG_LEVEL=info
POSTGRES_USER=axiom
POSTGRES_PASSWORD=$dbPassword
POSTGRES_DB=axiom
DATABASE_URL=postgresql://axiom-db:5432/axiom
AXIOM_INTERNAL_URL=http://axiom-web:8080
DOMAIN=localhost
SSL_CERT_PATH=/etc/nginx/ssl/cert.pem
SSL_KEY_PATH=/etc/nginx/ssl/key.pem
"@ | Set-Content -Encoding UTF8 $EnvFile

  Write-Host 'Created .env with generated credentials.'
}

$certPath = Join-Path $RootDir 'ssl/cert.pem'
$keyPath = Join-Path $RootDir 'ssl/key.pem'
if ((-not (Test-Path $certPath)) -or (-not (Test-Path $keyPath))) {
  docker run --rm -v "${RootDir}/ssl:/ssl" alpine/openssl req -x509 -newkey rsa:2048 -sha256 -days 365 -nodes -keyout /ssl/key.pem -out /ssl/cert.pem -subj '/CN=localhost' | Out-Null
  Write-Host 'Generated local self-signed TLS certificate in ssl/.'
}

Push-Location $RootDir
try {
  docker compose up -d --build

  Write-Host 'Waiting for AXIOM to become healthy...'
  [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
  $healthy = $false
  for ($i = 0; $i -lt 30; $i++) {
    try {
      Invoke-WebRequest -Uri 'https://localhost/health' -UseBasicParsing | Out-Null
      $healthy = $true
      break
    } catch {
      Start-Sleep -Seconds 2
    }
  }

  if (-not $healthy) {
    throw 'AXIOM health check did not pass in time.'
  }

  $localIp = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {$_.IPAddress -notlike '127.*'} | Select-Object -First 1 -ExpandProperty IPAddress)
  $externalIp = try { (Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 5) } catch { 'unavailable' }

  Write-Host 'AXIOM is running.'
  Write-Host 'Local URL: https://localhost'
  Write-Host "Local IP: $localIp"
  Write-Host "External IP: $externalIp"
  Write-Host 'Verification checklist:'
  Write-Host '[x] Docker daemon running'
  Write-Host '[x] .env configured'
  Write-Host '[x] Containers started'
  Write-Host '[x] Health check passed'
}
finally {
  Pop-Location
}
