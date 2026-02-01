$ErrorActionPreference = "Stop"

# Configuration
$VpsIp = "103.77.173.6"
$VpsUser = "root" 
$RemotePath = "/var/www/backend"
$LocalPath = "c:\Users\Admin\Downloads\mobile_flutter\PCM.Backend"

Write-Host "====== DEPLOYMENT V2 STARTED ======" -ForegroundColor Green

# 1. Clean & Build Project
Write-Host "1. Cleaning and Building Backend (Target: .NET 9)..." -ForegroundColor Cyan
Set-Location $LocalPath

# Stop local running process if it exists (fixes file lock errors like e_sqlite3.dll)
Write-Host "   -> Stopping any local backend processes..."
Get-Process "PCM.Backend" -ErrorAction SilentlyContinue | Stop-Process -Force

# Deep cleanup to fix MSB3030 errors
Write-Host "   -> Deleting old build folders..."
# Using SilentlyContinue because if a file is still locked, we'll try to let dotnet handle it
if (Test-Path "./publish") { Remove-Item -Recurse -Force "./publish" -ErrorAction SilentlyContinue }
if (Test-Path "./publish_vps") { Remove-Item -Recurse -Force "./publish_vps" -ErrorAction SilentlyContinue }
if (Test-Path "./publish_final") { Remove-Item -Recurse -Force "./publish_final" -ErrorAction SilentlyContinue }
if (Test-Path "./bin") { Remove-Item -Recurse -Force "./bin" -ErrorAction SilentlyContinue }
if (Test-Path "./obj") { Remove-Item -Recurse -Force "./obj" -ErrorAction SilentlyContinue }

# Build with clean output directory
Write-Host "   -> Running dotnet publish..."
dotnet publish -c Release -r linux-x64 -f net9.0 --self-contained true -o ./publish_final
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed! Please check the errors above."
    exit
}

# 2. Prepare VPS & Upload Files
Write-Host "2. Preparing VPS and Uploading ($VpsIp)..." -ForegroundColor Cyan
Write-Host "   (VPS password: manhduy1107@ )" -ForegroundColor Yellow

# Step A: Install standard .NET dependencies for Linux
Write-Host "   -> A: Installing Linux dependencies (libicu, libssl)..."
$EnvPrep = "sudo mkdir -p ${RemotePath}; sudo chown ${VpsUser}:${VpsUser} ${RemotePath}; sudo ufw allow 5244/tcp; sudo apt-get update && sudo apt-get install -y libicu-dev libssl-dev"
ssh "${VpsUser}@${VpsIp}" $EnvPrep

# Step B: Upload App Files and Database
Write-Host "   -> B: Uploading binaries and database..."
scp -r "$LocalPath\publish_final\*" "$LocalPath\PCMBackend.db" "${VpsUser}@${VpsIp}:${RemotePath}/"

# Step C: Upload service configuration
Write-Host "   -> C: Uploading service configuration..."
scp "$LocalPath\backend.service" "${VpsUser}@${VpsIp}:/tmp/backend.service"

# 3. Setup Service & Restart
Write-Host "3. Configuring & Restarting Service..." -ForegroundColor Cyan

# Step D: Move service file, reload, make executable, and restart
$RemoteCommands = "sudo mv /tmp/backend.service /etc/systemd/system/backend.service; sudo chmod +x ${RemotePath}/PCM.Backend; sudo systemctl daemon-reload; sudo systemctl enable backend; sudo systemctl restart backend; sleep 5; sudo systemctl status backend --no-pager"

ssh "${VpsUser}@${VpsIp}" $RemoteCommands

Write-Host "====== DEPLOYMENT V2 COMPLETED! ======" -ForegroundColor Green
Write-Host "API URL: http://${VpsIp}:5244/api/Booking/courts"
