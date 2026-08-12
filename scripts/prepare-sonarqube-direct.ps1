# Prepare folders for a direct, no-Docker SonarQube setup.
# This script does not install system-wide applications.

param(
    [string]$ToolsDirectory = ".tools",
    [string]$SonarQubeZipPath,
    [string]$JavaHome
)

$ErrorActionPreference = "Stop"

function Resolve-FullPath([string]$Path) {
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return Join-Path (Get-Location) $Path
}

$toolsPath = Resolve-FullPath $ToolsDirectory
New-Item -ItemType Directory -Path $toolsPath -Force | Out-Null

Write-Host "Direct SonarQube local tools folder: $toolsPath"

if ($SonarQubeZipPath) {
    $zipPath = Resolve-FullPath $SonarQubeZipPath
    if (-not (Test-Path $zipPath)) {
        Write-Host "SonarQube ZIP was not found: $zipPath"
        exit 1
    }

    $extractPath = Join-Path $toolsPath "sonarqube-extract"
    $targetPath = Join-Path $toolsPath "sonarqube"

    if (Test-Path $extractPath) {
        Remove-Item $extractPath -Recurse -Force
    }

    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    $extractedRoot = Get-ChildItem $extractPath -Directory | Select-Object -First 1
    if (-not $extractedRoot) {
        Write-Host "Could not find extracted SonarQube folder inside: $extractPath"
        exit 1
    }

    if (Test-Path $targetPath) {
        Remove-Item $targetPath -Recurse -Force
    }

    Move-Item $extractedRoot.FullName $targetPath
    Remove-Item $extractPath -Recurse -Force

    Write-Host "SonarQube extracted to: $targetPath"
}
else {
    Write-Host "No SonarQube ZIP path was provided."
    Write-Host "Download SonarQube Community Build ZIP from https://www.sonarsource.com/products/sonarqube/downloads/"
    Write-Host "Then run: .\scripts\prepare-sonarqube-direct.ps1 -SonarQubeZipPath '<path-to-zip>'"
}

if ($JavaHome) {
    $resolvedJavaHome = Resolve-FullPath $JavaHome
    if (-not (Test-Path $resolvedJavaHome)) {
        Write-Host "JAVA_HOME path was not found: $resolvedJavaHome"
        exit 1
    }

    Write-Host "Use this Java runtime for direct startup:"
    Write-Host "`$env:JAVA_HOME = '$resolvedJavaHome'"
}
else {
    $javaCommand = Get-Command java -ErrorAction SilentlyContinue
    if ($javaCommand) {
        Write-Host "Java found on PATH: $($javaCommand.Source)"
    }
    else {
        Write-Host "Java was not found on PATH. Direct SonarQube startup requires Java."
        Write-Host "Use a system JDK or a portable JDK and set JAVA_HOME before starting SonarQube."
    }
}

Write-Host ""
Write-Host "Start SonarQube directly with:"
Write-Host ".\scripts\start-sonarqube-direct.ps1"
