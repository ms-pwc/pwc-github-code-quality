<#
.SYNOPSIS
    Merges the per-project Roslyn analyzer SARIF files into a single SARIF run.

.DESCRIPTION
    GitHub code scanning rejects a SARIF file that contains multiple runs under
    the same category:
        "The CodeQL Action does not support uploading multiple SARIF runs with
         the same category."

    The C# compiler emits one SARIF file per project (see Directory.Build.props),
    so this script combines them into a single run before upload.

    Rule metadata from every project is concatenated and de-duplicated by rule
    id. Each result's `ruleIndex`/`rule` fields are removed because those are
    positional references into the ORIGINAL per-run rules array and would point
    at the wrong rule after merging. SARIF consumers fall back to matching on
    `ruleId`, which is preserved, so no information is lost.
#>
[CmdletBinding()]
param(
    # Directory containing the per-project *.sarif files produced by the build.
    [Parameter(Mandatory = $true)]
    [string] $InputDirectory,

    # Path of the merged SARIF file to write.
    [Parameter(Mandatory = $true)]
    [string] $OutputPath
)

$ErrorActionPreference = 'Stop'

$sarifFiles = @(Get-ChildItem -Path $InputDirectory -Filter '*.sarif' -File)
if ($sarifFiles.Count -eq 0) {
    throw "No SARIF files were found in '$InputDirectory'. Did the build run with -p:SarifOutputDir?"
}

$documents = foreach ($file in $sarifFiles) {
    Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
}

$allRuns = foreach ($document in $documents) { $document.runs }

# De-duplicate rule definitions by id so the merged run keeps full descriptions.
$rulesById = [ordered]@{}
foreach ($run in $allRuns) {
    foreach ($rule in @($run.tool.driver.rules)) {
        if ($null -ne $rule -and -not $rulesById.Contains($rule.id)) {
            $rulesById[$rule.id] = $rule
        }
    }
}

# Strip positional rule references that are invalid after merging.
$mergedResults = foreach ($run in $allRuns) {
    foreach ($result in @($run.results)) {
        if ($null -eq $result) { continue }
        $result.PSObject.Properties.Remove('ruleIndex')
        $result.PSObject.Properties.Remove('rule')
        $result
    }
}

$firstDriver = $allRuns[0].tool.driver

$merged = [ordered]@{
    '$schema' = 'https://json.schemastore.org/sarif-2.1.0.json'
    version   = '2.1.0'
    runs      = @(
        [ordered]@{
            tool = [ordered]@{
                driver = [ordered]@{
                    name           = $firstDriver.name
                    version        = $firstDriver.version
                    semanticVersion = $firstDriver.semanticVersion
                    rules          = @($rulesById.Values)
                }
            }
            results = @($mergedResults)
        }
    )
}

$merged | ConvertTo-Json -Depth 100 | Set-Content -Path $OutputPath -Encoding utf8

Write-Host "Merged $($sarifFiles.Count) SARIF file(s) into '$OutputPath': $(@($mergedResults).Count) result(s), $($rulesById.Count) rule definition(s)."
