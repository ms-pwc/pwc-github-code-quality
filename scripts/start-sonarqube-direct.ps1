# Start SonarQube directly from a local extracted SonarQube folder.
# This does not require Docker and does not install SonarQube as a Windows service.

param(
    [string]$SonarQubeHome = ".tools\sonarqube",
    [string]$JavaHome = $env:JAVA_HOME,
    [int]$Port = 9000
)

$ErrorActionPreference = "Stop"

function Resolve-FullPath([string]$Path) {
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return Join-Path (Get-Location) $Path
}

$resolvedSonarHome = Resolve-FullPath $SonarQubeHome

if (-not (Test-Path $resolvedSonarHome)) {
    Write-Host "SonarQube was not found at: $resolvedSonarHome"
    Write-Host "Download SonarQube Community Build ZIP from https://www.sonarsource.com/products/sonarqube/downloads/"
    Write-Host "Extract it to .tools\sonarqube or pass -SonarQubeHome '<path-to-extracted-folder>'."
    exit 1
}

$startScript = Join-Path $resolvedSonarHome "bin\windows-x86-64\StartSonar.bat"
if (-not (Test-Path $startScript)) {
    Write-Host "Could not find StartSonar.bat at: $startScript"
    Write-Host "Make sure -SonarQubeHome points to the extracted SonarQube root folder."
    exit 1
}

if (-not $JavaHome) {
    $javaCommand = Get-Command java -ErrorAction SilentlyContinue
    if (-not $javaCommand) {
        Write-Host "Java is required for direct SonarQube startup and was not found on PATH."
        Write-Host "Install Temurin JDK 17/21 or use a portable JDK, then set JAVA_HOME before running this script."
        Write-Host "Example: `$env:JAVA_HOME = 'C:\tools\jdk-17'"
        exit 1
    }
}
else {
    $resolvedJavaHome = Resolve-FullPath $JavaHome
    if (-not (Test-Path $resolvedJavaHome)) {
        Write-Host "JAVA_HOME path was not found: $resolvedJavaHome"
        exit 1
    }

    $env:JAVA_HOME = $resolvedJavaHome
    $env:PATH = "$resolvedJavaHome\bin;$env:PATH"
}

$existingListener = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($existingListener) {
    Write-Host "Port $Port is already in use. Stop the process using this port or change SonarQube's port in conf\sonar.properties."
    $existingListener | Select-Object LocalAddress,LocalPort,State,OwningProcess
    exit 1
}

Write-Host "Starting SonarQube directly from: $resolvedSonarHome"
Write-Host "When startup finishes, open: http://localhost:$Port"
Write-Host "Default credentials: admin / admin"
Write-Host "Press Ctrl+C in the SonarQube console window to stop it."

Push-Location $resolvedSonarHome
try {
    & $startScript
}
finally {
    Pop-Location
}
