<#
.SYNOPSIS
    Builds the project and updates YOUR local database to match it.
    Run this after every "git pull" and after you change any .sql file.

.EXAMPLE
    .\scripts\Publish-Local.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Assert-SqlPackage
$dacpac = Build-Dacpac -Configuration Debug

Write-Host 'Publishing to local database ...' -ForegroundColor Cyan
& sqlpackage /Action:Publish `
    /SourceFile:"$dacpac" `
    /Profile:"$ProfilesDir\Local.publish.xml"
if ($LASTEXITCODE -ne 0) { throw "Publish failed (exit code $LASTEXITCODE)." }

Write-Host 'Local database is up to date.' -ForegroundColor Green
