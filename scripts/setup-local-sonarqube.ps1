# Setup local SonarQube with Docker Compose (PowerShell version)
# This script starts a local SonarQube instance for development and testing

Write-Host "Starting local SonarQube server..."
docker-compose up -d

Write-Host ""
Write-Host "Waiting for SonarQube to be ready..."

# Wait for SonarQube to be healthy
$maxAttempts = 60
for ($i = 1; $i -le $maxAttempts; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:9000/api/system/health" -UseBasicParsing -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "SonarQube is ready!"
            break
        }
    }
    catch {
        if ($i -eq $maxAttempts) {
            Write-Host "SonarQube failed to start within $maxAttempts seconds"
            exit 1
        }
        Write-Host "Waiting... ($i/$maxAttempts)"
        Start-Sleep -Seconds 1
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "SonarQube Server Started Successfully!"
Write-Host "========================================"
Write-Host ""
Write-Host "Access SonarQube at: http://localhost:9000"
Write-Host "Default credentials:"
Write-Host "  Username: admin"
Write-Host "  Password: admin"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Login with admin/admin"
Write-Host "2. Generate a token: Administration > Security > Users > Tokens"
Write-Host "3. Set the SONAR_LOGIN environment variable:"
Write-Host "   `$env:SONAR_LOGIN = 'your-generated-token'"
Write-Host "4. Run: .\scripts\run-sonarqube-scan.ps1"
Write-Host ""
Write-Host "To stop SonarQube:"
Write-Host "  docker-compose down"
Write-Host ""
