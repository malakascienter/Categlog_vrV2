<#
.SYNOPSIS
    Creates (does NOT run) the SQL change script for a server, plus a report of
    what will change. Use this before every Prod release and let someone review it.

.EXAMPLE
    .\scripts\New-DeployScript.ps1 -Environment Prod -Server "prod-sql01" -User "deploy"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [ValidateSet('Dev', 'Test', 'Prod')] [string] $Environment,
    [Parameter(Mandatory)] [string] $Server,
    [string] $Database = 'AppDb',
    [string] $User,
    [SecureString] $Password,
    [switch] $WindowsAuth
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Assert-SqlPackage
$dacpac = Build-Dacpac -Configuration Release

if ($WindowsAuth) {
    $auth = 'Integrated Security=True'
} else {
    if (-not $User)     { $User = Read-Host 'SQL login' }
    if (-not $Password) { $Password = Read-Host "Password for $User" -AsSecureString }
    $auth = "User ID=$User;Password=$([System.Net.NetworkCredential]::new('', $Password).Password)"
}
$connection = "Server=$Server;Database=$Database;$auth;Encrypt=True;TrustServerCertificate=True"
$profile    = "$ProfilesDir\$Environment.publish.xml"

$outDir = Join-Path $RepoRoot 'deploy-output'
New-Item $outDir -ItemType Directory -Force | Out-Null
$stamp  = Get-Date -Format 'yyyyMMdd_HHmm'
$script = Join-Path $outDir "AppDb_${Environment}_$stamp.sql"
$report = Join-Path $outDir "AppDb_${Environment}_$stamp.report.xml"

& sqlpackage /Action:Script /SourceFile:"$dacpac" /Profile:"$profile" `
    /TargetConnectionString:"$connection" /OutputPath:"$script"
if ($LASTEXITCODE -ne 0) { throw 'Script generation failed.' }

& sqlpackage /Action:DeployReport /SourceFile:"$dacpac" /Profile:"$profile" `
    /TargetConnectionString:"$connection" /OutputPath:"$report"
if ($LASTEXITCODE -ne 0) { throw 'Report generation failed.' }

Write-Host ''
Write-Host "Change script : $script" -ForegroundColor Green
Write-Host "Change report : $report" -ForegroundColor Green
Write-Host 'Review both files before deploying.'
