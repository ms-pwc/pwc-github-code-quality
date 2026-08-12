# Check whether local SonarQube is reachable.

param(
    [string]$SonarHostUrl = "http://localhost:9000"
)

$ErrorActionPreference = "SilentlyContinue"

$uri = "$SonarHostUrl/api/system/status"
Write-Host "Checking SonarQube at $SonarHostUrl ..."

try {
    $response = Invoke-RestMethod -Uri $uri -UseBasicParsing
    Write-Host "SonarQube responded. Status: $($response.status)"
    Write-Host "Open: $SonarHostUrl"
}
catch {
    Write-Host "SonarQube is not reachable at $SonarHostUrl."
    Write-Host "If using direct install, run: .\scripts\start-sonarqube-direct.ps1"
    Write-Host "If using Docker, run: .\scripts\setup-local-sonarqube.ps1"
    exit 1
}
