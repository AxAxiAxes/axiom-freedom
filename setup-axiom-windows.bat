@echo off
setlocal enabledelayedexpansion

cd /d %~dp0

docker --version >nul 2>&1
if errorlevel 1 (
  echo Docker is required. Install Docker Desktop first.
  exit /b 1
)

docker compose version >nul 2>&1
if errorlevel 1 (
  echo Docker Compose plugin is required.
  exit /b 1
)

if exist .git (
  echo Pulling latest code...
  git pull --ff-only
)

if not exist .env (
  echo Creating .env from template...
  copy /Y .env.example .env >nul
  for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "$chars='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray(); -join (1..24|%%{$chars | Get-Random})"`) do set DB_PASSWORD=%%P
  powershell -NoProfile -Command "(Get-Content '.env') -replace '^AXIOM_DB_PASSWORD=.*','AXIOM_DB_PASSWORD=%DB_PASSWORD%' | Set-Content '.env'"
)

echo Pulling images...
docker compose pull

echo Starting AXIOM containers...
docker compose up -d axiom-web axiom-db axiom-proxy

for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr /R /C:"IPv4 Address"') do (
  set LOCAL_IP=%%I
  goto :localdone
)
:localdone
set LOCAL_IP=%LOCAL_IP: =%
if "%LOCAL_IP%"=="" set LOCAL_IP=127.0.0.1

for /f %%I in ('powershell -NoProfile -Command "try {(Invoke-RestMethod https://api.ipify.org).ToString()} catch {'unavailable'}"') do set EXTERNAL_IP=%%I

echo AXIOM is running
echo - Local URL: http://localhost:8080
echo - Local IP: %LOCAL_IP%
echo - External IP: %EXTERNAL_IP%
echo - Stop/remove: uninstall-axiom-windows.bat

set DESKTOP_DIR=%USERPROFILE%\Desktop
(
  echo [InternetShortcut]
  echo URL=http://localhost:8080
  echo IconFile=%SystemRoot%\System32\SHELL32.dll
  echo IconIndex=220
) > "%DESKTOP_DIR%\AXIOM Local.url"

echo Desktop shortcut created: %DESKTOP_DIR%\AXIOM Local.url
