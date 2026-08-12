param(
    [string]$SonarQubeVersion = "10.6.0.92116",
    [int]$Port = 9000
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$toolsPath = Join-Path $repoRoot ".tools"
$javaPath = Join-Path $toolsPath "java17"
$sonarPath = Join-Path $toolsPath "sonarqube-$SonarQubeVersion"
$downloadsPath = Join-Path $toolsPath "downloads"
$javaZip = Join-Path $downloadsPath "temurin-jre17.zip"
$sonarZip = Join-Path $downloadsPath "sonarqube-$SonarQubeVersion.zip"
$sonarUrl = "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SonarQubeVersion.zip"
$javaUrl = "https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jre/hotspot/normal/eclipse?project=jdk"

New-Item -ItemType Directory -Force -Path $toolsPath, $downloadsPath | Out-Null

if (-not (Test-Path $javaPath)) {
    Write-Host "Downloading portable Java 17 runtime..."
    Invoke-WebRequest -Uri $javaUrl -OutFile $javaZip
    Expand-Archive -Path $javaZip -DestinationPath $toolsPath -Force
    $expandedJava = Get-ChildItem $toolsPath -Directory | Where-Object { $_.Name -like "jdk-17*" -or $_.Name -like "jre-17*" } | Select-Object -First 1
    if (-not $expandedJava) {
        throw "Portable Java extraction did not produce a jdk-17 or jre-17 folder."
    }
    Rename-Item -Path $expandedJava.FullName -NewName "java17"
}

if (-not (Test-Path $sonarPath)) {
    Write-Host "Downloading SonarQube Community $SonarQubeVersion..."
    Invoke-WebRequest -Uri $sonarUrl -OutFile $sonarZip
    Expand-Archive -Path $sonarZip -DestinationPath $toolsPath -Force
}

$env:JAVA_HOME = $javaPath
$env:Path = "$(Join-Path $javaPath 'bin');$env:Path"

$configPath = Join-Path $sonarPath "conf\sonar.properties"
$config = Get-Content $configPath -Raw
$config = $config -replace "#?sonar.web.port=.*", "sonar.web.port=$Port"
Set-Content -Path $configPath -Value $config -Encoding UTF8

Write-Host "Starting portable SonarQube on http://localhost:$Port"
Write-Host "This local demo uses SonarQube embedded storage. Do not use this mode for production."

Push-Location (Join-Path $sonarPath "bin\windows-x86-64")
try {
    .\StartSonar.bat
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "SonarQube is starting. It can take 1-2 minutes before the page opens."
Write-Host "Link: http://localhost:$Port"
Write-Host "Default login: admin / admin"