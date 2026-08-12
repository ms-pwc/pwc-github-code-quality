# Run SonarQube scan against local or remote SonarQube instance

param(
    [string]$SonarHostUrl = "http://localhost:9000",
    [string]$SonarLogin = $env:SONAR_LOGIN
)

if (-not $SonarLogin) {
    Write-Host "Error: SONAR_LOGIN not provided as parameter or environment variable"
    Write-Host "Usage: .\scripts\run-sonarqube-scan.ps1 -SonarLogin '<token>'"
    Write-Host "Or:    `$env:SONAR_LOGIN = '<token>'; .\scripts\run-sonarqube-scan.ps1"
    exit 1
}

Write-Host "Running SonarQube scan..."
Write-Host "SonarQube Host: $SonarHostUrl"
Write-Host ""

dotnet restore Pwc.GitHubCodeQuality.slnx

dotnet sonarscanner begin `
  /k:"pwc-github-code-quality" `
  /n:"PWC GitHub Code Quality" `
  /d:sonar.host.url="$SonarHostUrl" `
  /d:sonar.login="$SonarLogin"

dotnet build Pwc.GitHubCodeQuality.slnx --configuration Release --no-restore

dotnet sonarscanner end /d:sonar.login="$SonarLogin"

Write-Host ""
Write-Host "Scan completed! View results at: $SonarHostUrl"
Write-Host ""
