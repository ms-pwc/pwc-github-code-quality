param(
    [string]$SonarQubeVersion = "10.6.0.92116"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sonarPath = Join-Path $repoRoot ".tools\sonarqube-$SonarQubeVersion"
$stopScript = Join-Path $sonarPath "bin\windows-x86-64\StopSonar.bat"

if (-not (Test-Path $stopScript)) {
    Write-Host "Portable SonarQube was not found at $sonarPath"
    exit 0
}

Push-Location (Split-Path $stopScript)
try {
    .\StopSonar.bat
}
finally {
    Pop-Location
}

Write-Host "Portable SonarQube stop command sent."