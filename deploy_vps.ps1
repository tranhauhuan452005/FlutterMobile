$ErrorActionPreference = "Stop"

# Configuration
$VpsIp = "103.77.173.6"
$VpsUser = "root" 
$RemotePath = "/var/www/backend"
$LocalPath = "c:\Users\Admin\Downloads\mobile_flutter\PCM.Backend"

Write-Host "====== DEPLOYMENT STARTED ======" -ForegroundColor Green

# 1. Build Project
Write-Host "1. Building Backend (Target: .NET 9)..." -ForegroundColor Cyan
Set-Location $LocalPath

# Cleanup old builds to avoid path collisions (MSB3030 errors)
if (Test-Path "./publish_vps") { Remove-Item -Recurse -Force "./publish_vps" }

# Build with clean output directory
dotnet publish -c Release -r linux-x64 -f net9.0 --self-contained true -o ./publish_vps
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed!"
    exit
}

# 2. Upload Files
Write-Host "2. Uploading files to VPS ($VpsIp)..." -ForegroundColor Cyan
Write-Host "   (VPS password: manhduy1107@ )" -ForegroundColor Yellow

# Step A: Setup remote directory, Firewall, and Install standard .NET dependencies for Linux
Write-Host "   -> A: Preparing VPS environment..."
$EnvPrep = "sudo mkdir -p ${RemotePath}; sudo chown ${VpsUser}:${VpsUser} ${RemotePath}; sudo ufw allow 5244/tcp; sudo apt-get update && sudo apt-get install -y libicu-dev libssl-dev"
ssh "${VpsUser}@${VpsIp}" $EnvPrep

# Step B: Upload App Files and Database
Write-Host "   -> B: Uploading binaries and database..."
scp -r "$LocalPath\publish_vps\*" "$LocalPath\PCMBackend.db" "${VpsUser}@${VpsIp}:${RemotePath}/"

Write-Host "   -> C: Uploading service configuration..."
scp "$LocalPath\backend.service" "${VpsUser}@${VpsIp}:/tmp/backend.service"

# 3. Setup Service & Restart
Write-Host "3. Configuring & Restarting Service..." -ForegroundColor Cyan

# Step D: Move service file, reload, make executable, and restart
$RemoteCommands = "sudo mv /tmp/backend.service /etc/systemd/system/backend.service; sudo chmod +x ${RemotePath}/PCM.Backend; sudo systemctl daemon-reload; sudo systemctl enable backend; sudo systemctl restart backend; sleep 5; sudo systemctl status backend --no-pager"

ssh "${VpsUser}@${VpsIp}" $RemoteCommands

Write-Host "====== DEPLOYMENT COMPLETED! ======" -ForegroundColor Green
Write-Host "API URL: http://${VpsIp}:5244/api/Booking/courts"
