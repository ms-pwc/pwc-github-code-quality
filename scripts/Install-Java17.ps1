#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Downloads and installs OpenJDK 17 LTS required by SonarQube 10.7+

.DESCRIPTION
    Installs Java 17 LTS from Adoptium, sets JAVA_HOME, and adds to PATH.
    Required by SonarQube 10.7 and later versions.

.EXAMPLE
    .\Install-Java17.ps1
#>

param()

$ErrorActionPreference = "Stop"

# Setup paths
$javaPath = "C:\Java"
$jdkVersion = "17.0.13_11"
$jdkName = "jdk-$jdkVersion"

Write-Host "==============================================="
Write-Host "Installing OpenJDK 17 LTS for SonarQube"
Write-Host "==============================================="
Write-Host ""

# Create directory
if (-not (Test-Path $javaPath)) {
    Write-Host "Creating directory: $javaPath"
    New-Item -ItemType Directory -Path $javaPath -Force | Out-Null
}

# Download OpenJDK 17 from Adoptium
$url = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_x64_windows_hotspot_17.0.13_11.zip"
$zipPath = Join-Path $javaPath "openjdk17.zip"

Write-Host "Downloading OpenJDK 17 LTS..."
Write-Host "Source: https://adoptium.net/"
Write-Host ""

try {
    Invoke-WebRequest -Uri $url -OutFile $zipPath -ProgressAction Continue
    Write-Host ""
    Write-Host "✓ Download complete"
}
catch {
    Write-Host "✗ Failed to download: $_"
    exit 1
}

# Extract
Write-Host ""
Write-Host "Extracting OpenJDK..."
try {
    Expand-Archive -Path $zipPath -DestinationPath $javaPath -Force
    Write-Host "✓ Extraction complete"
}
catch {
    Write-Host "✗ Failed to extract: $_"
    Remove-Item $zipPath -Force
    exit 1
}

# Clean up zip
Remove-Item $zipPath -Force
Write-Host "✓ Cleaned up temporary files"

# Find the extracted directory
$jdkDir = Get-ChildItem $javaPath -Directory | Where-Object { $_.Name -match '^jdk' } | Select-Object -First 1

if ($null -eq $jdkDir) {
    Write-Host "✗ Failed to find extracted JDK directory"
    exit 1
}

$javaHome = $jdkDir.FullName
Write-Host ""
Write-Host "Java installed at: $javaHome"

# Set environment variables for current session
$env:JAVA_HOME = $javaHome
$env:PATH = "$javaHome\bin;$env:PATH"

# Verify installation
Write-Host ""
Write-Host "Verifying installation..."
& "$javaHome\bin\java" -version
Write-Host ""

Write-Host "======================================================="
Write-Host "OpenJDK 17 LTS installed successfully!"
Write-Host "======================================================="
Write-Host ""
Write-Host "To persist environment variables, add to profile:"
Write-Host "  `$env:JAVA_HOME = '$javaHome'"
Write-Host ""
Write-Host "Or set system-wide via:"
Write-Host "  [Environment]::SetEnvironmentVariable('JAVA_HOME', '$javaHome', 'User')"
Write-Host ""
