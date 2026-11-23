<#
.SYNOPSIS
    Drops your local AppDb and rebuilds it from scratch (schema + sample data).
    Use when your local database is in a strange state.

.EXAMPLE
    .\scripts\Reset-Local.ps1
#>
[CmdletBinding()]
param(
    [string] $Instance = '(localdb)\MSSQLLocalDB',
    [string] $Database = 'AppDb'
)

$ErrorActionPreference = 'Stop'

Write-Host "Dropping [$Database] on $Instance ..." -ForegroundColor Yellow
$drop = @"
IF DB_ID(N'$Database') IS NOT NULL
BEGIN
    ALTER DATABASE [$Database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$Database];
END
"@
& sqlcmd -S $Instance -E -b -Q $drop
if ($LASTEXITCODE -ne 0) { throw 'Could not drop the database. Is sqlcmd installed?' }

& "$PSScriptRoot\Publish-Local.ps1"
