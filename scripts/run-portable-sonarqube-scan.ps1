param(
    [string]$SonarHostUrl = "http://localhost:9000",
    [string]$SonarLogin = $env:SONAR_LOGIN
)

$ErrorActionPreference = "Stop"

if (-not $SonarLogin) {
    Write-Host "Error: SONAR_LOGIN not provided. Generate a token in SonarQube, then run:"
    Write-Host "`$env:SONAR_LOGIN = '<your-token>'"
    Write-Host ".\scripts\run-portable-sonarqube-scan.ps1"
    exit 1
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$toolPath = Join-Path $repoRoot ".tools\dotnet-tools"
$scanner = Join-Path $toolPath "dotnet-sonarscanner.exe"
$portableJava = Join-Path $repoRoot ".tools\java17"
$javaExePath = $null

if (Test-Path $portableJava) {
    $env:JAVA_HOME = $portableJava
    $env:Path = "$(Join-Path $portableJava 'bin');$env:Path"
    $javaExePath = Join-Path $portableJava "bin\java.exe"
}

New-Item -ItemType Directory -Force -Path $toolPath | Out-Null

if (-not (Test-Path $scanner)) {
    dotnet tool install --tool-path $toolPath dotnet-sonarscanner
}

dotnet restore Pwc.GitHubCodeQuality.slnx
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$scannerArguments = @(
    "begin",
    "/k:pwc-github-code-quality",
    "/n:PWC GitHub Code Quality",
    "/d:sonar.host.url=$SonarHostUrl",
    "/d:sonar.login=$SonarLogin",
    "/d:sonar.qualitygate.wait=true"
)

if ($javaExePath -and (Test-Path $javaExePath)) {
    $scannerArguments += "/d:sonar.scanner.javaExePath=$javaExePath"
}

& $scanner @scannerArguments
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

dotnet build Pwc.GitHubCodeQuality.slnx --configuration Release --no-restore
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $scanner end /d:sonar.login="$SonarLogin"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Scan completed. View results at: $SonarHostUrl"