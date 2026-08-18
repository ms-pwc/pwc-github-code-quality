#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Waits for SonarQube analysis to complete and checks the quality gate status.

.DESCRIPTION
    Polls the SonarQube API until the analysis is complete, then verifies the quality gate result.
    This is used in GitHub Actions workflows to ensure code quality before merging.

.PARAMETER SonarHostUrl
    URL to the SonarQube instance (e.g., http://localhost:9000)

.PARAMETER SonarToken
    Authentication token for SonarQube

.PARAMETER ProjectKey
    SonarQube project key (must match the scanner begin /k: parameter)

.PARAMETER MaxRetries
    Maximum number of retry attempts (default: 60)

.PARAMETER WaitSeconds
    Seconds to wait between retries (default: 5)

.EXAMPLE
    ./Wait-SonarQualityGate.ps1 `
        -SonarHostUrl "http://localhost:9000" `
        -SonarToken "squ_abc123def456" `
        -ProjectKey "pwc-github-code-quality"

.NOTES
    Requires PowerShell 7.0+
    Uses SonarQube REST API v2
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SonarHostUrl,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SonarToken,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectKey,
    
    [ValidateRange(1, 1000)]
    [int]$MaxRetries = 60,
    
    [ValidateRange(1, 60)]
    [int]$WaitSeconds = 5,
    
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Configure headers for SonarQube API
$base64Token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($SonarToken):"))
$headers = @{
    "Authorization" = "Basic $base64Token"
}

Write-Host "🔍 Waiting for SonarQube analysis to complete..."
Write-Host "   Host: $SonarHostUrl"
Write-Host "   Project: $ProjectKey"
Write-Host "   Max retries: $MaxRetries, Wait interval: $WaitSeconds seconds"
Write-Host ""

$retryCount = 0
$analysisComplete = $false
$gateStatus = "UNKNOWN"
$analysisStatus = "PENDING"

try {
    while (-not $analysisComplete -and $retryCount -lt $MaxRetries) {
        $retryCount++
        
        # Wait before checking
        if ($retryCount -gt 1) {
            Start-Sleep -Seconds $WaitSeconds
        }
        
        # Get analysis task status
        try {
            $ceActivityUrl = "$SonarHostUrl/api/ce/activity?component=$ProjectKey"
            
            if ($Verbose) {
                Write-Host "  Request #$retryCount to: $ceActivityUrl"
            }
            
            $response = Invoke-RestMethod -Uri $ceActivityUrl -Headers $headers -ErrorAction Stop
            
            if ($response.tasks -and $response.tasks.Count -gt 0) {
                $task = $response.tasks[0]
                $analysisStatus = $task.status
                $taskId = $task.id
                
                Write-Host "  [$retryCount/$MaxRetries] Status: $analysisStatus (Task: $taskId)"
                
                if ($analysisStatus -eq "SUCCESS") {
                    Write-Host "  ✓ Analysis completed successfully"
                    $analysisComplete = $true
                }
                elseif ($analysisStatus -eq "FAILED") {
                    Write-Host "  ✗ Analysis failed!"
                    throw "SonarQube analysis task failed: $($task.errorMessage)"
                }
                elseif ($analysisStatus -eq "CANCELED") {
                    Write-Host "  ⚠ Analysis was canceled"
                    throw "SonarQube analysis was canceled"
                }
                else {
                    # Still pending, continue polling
                    if ($Verbose) {
                        Write-Host "    Task details: $($task | ConvertTo-Json)"
                    }
                }
            }
            else {
                Write-Host "  [$retryCount/$MaxRetries] No tasks found yet..."
            }
        }
        catch {
            Write-Host "  ⚠ Error checking analysis status (will retry): $_"
            # Continue polling in case of transient errors
            if ($retryCount -ge $MaxRetries) {
                throw
            }
        }
    }
    
    if (-not $analysisComplete) {
        throw "Analysis did not complete within $($MaxRetries * $WaitSeconds) seconds ($MaxRetries retries)"
    }
    
    Write-Host ""
    Write-Host "✓ Analysis completed. Checking Quality Gate..."
    
    # Check quality gate status
    $projectStatusUrl = "$SonarHostUrl/api/qualitygates/project_status?projectKey=$ProjectKey"
    $gateResponse = Invoke-RestMethod -Uri $projectStatusUrl -Headers $headers -ErrorAction Stop
    
    $gateStatus = $gateResponse.projectStatus.status
    $conditions = $gateResponse.projectStatus.conditions
    
    Write-Host ""
    Write-Host "Quality Gate Status: $gateStatus"
    Write-Host ""
    
    if ($conditions) {
        Write-Host "Quality Gate Conditions:"
        foreach ($condition in $conditions) {
            $status = $condition.status
            $metricKey = $condition.metricKey
            $value = $condition.value
            $comparator = $condition.comparator
            $errorThreshold = $condition.errorThreshold
            
            $statusSymbol = switch ($status) {
                "OK" { "✓" }
                "WARN" { "⚠" }
                default { "✗" }
            }
            
            Write-Host "  $statusSymbol $metricKey=$value ($comparator $errorThreshold) [$status]"
        }
    }
    
    Write-Host ""
    
    if ($gateStatus -eq "OK") {
        Write-Host "✓ Quality Gate PASSED"
        Write-Host ""
        Write-Host "📊 View results at: $SonarHostUrl/dashboard?id=$ProjectKey"
        exit 0
    }
    else {
        Write-Host "✗ Quality Gate FAILED (Status: $gateStatus)"
        Write-Host ""
        Write-Host "📊 View results at: $SonarHostUrl/dashboard?id=$ProjectKey"
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "❌ Error waiting for SonarQube analysis: $_"
    Write-Host ""
    Write-Host "Troubleshooting:"
    Write-Host "1. Verify SONAR_HOST_URL and SONAR_TOKEN are set correctly"
    Write-Host "2. Check SonarQube is running and accessible"
    Write-Host "3. Confirm project key matches: $ProjectKey"
    Write-Host "4. Check SonarQube logs for analysis errors"
    exit 1
}
