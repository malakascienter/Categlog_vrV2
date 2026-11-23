<#
.SYNOPSIS
    Connects to an existing SQL Server database (SQL login + password) and imports
    all its objects (tables, views, procedures, functions...) into the AppDb project,
    one .sql file per object:  dbo\Tables\Users.sql, dbo\Views\..., etc.

.EXAMPLE
    .\scripts\Import-Database.ps1 -Server "192.168.1.50" -Database "ShopDb" -User "sa"
    (asks for the password securely)

.EXAMPLE
    .\scripts\Import-Database.ps1 -Server "myserver,1433" -Database "ShopDb" -User "dev" -OnlyDbo

.EXAMPLE
    .\scripts\Import-Database.ps1 -Server "localhost" -Database "ShopDb" -WindowsAuth
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Server,
    [Parameter(Mandatory)] [string] $Database,
    [string] $User,
    [SecureString] $Password,
    [switch] $WindowsAuth,
    # Import only the dbo schema folder (skip other schemas and Security).
    [switch] $OnlyDbo,
    # Also import database users, roles, role membership and GRANT/DENY permissions.
    [switch] $IncludeSecurity,
    # Skip the "are you sure" prompt.
    [switch] $Force
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Assert-SqlPackage

# ---- Build the connection string -------------------------------------------
if ($WindowsAuth) {
    $auth = 'Integrated Security=True'
} else {
    if (-not $User)     { $User = Read-Host 'SQL login' }
    if (-not $Password) { $Password = Read-Host "Password for $User" -AsSecureString }
    $plain = [System.Net.NetworkCredential]::new('', $Password).Password
    $auth  = "User ID=$User;Password=$plain"
}
$connection = "Server=$Server;Database=$Database;$auth;Encrypt=True;TrustServerCertificate=True"

# ---- Extract every object into a temp folder (one file per object) ----------
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("AppDbImport_" + [guid]::NewGuid().ToString('N'))

# By default users/permissions are skipped: they differ per server and need logins that
# don't exist on developers' LocalDB. Use -IncludeSecurity to import them as well.
$skipSecurity = (-not $IncludeSecurity).ToString()

Write-Host "Reading schema from [$Server].[$Database] ..." -ForegroundColor Cyan
& sqlpackage /Action:Extract `
    /SourceConnectionString:"$connection" `
    /TargetFile:"$temp" `
    /p:ExtractTarget=SchemaObjectType `
    /p:IgnorePermissions=$skipSecurity `
    /p:IgnoreUserLoginMappings=$skipSecurity `
    /p:ExtractApplicationScopedObjectsOnly=$skipSecurity
if ($LASTEXITCODE -ne 0) { throw "sqlpackage extract failed (exit code $LASTEXITCODE)." }

$extracted = Get-ChildItem $temp -Directory
if ($OnlyDbo) { $extracted = $extracted | Where-Object Name -eq 'dbo' }
if (-not $extracted) { throw "Nothing was extracted. Check the database name and permissions." }

# ---- Replace matching folders in the project --------------------------------
Write-Host ''
Write-Host 'These project folders will be REPLACED with the database version:' -ForegroundColor Yellow
$extracted | ForEach-Object { Write-Host "   AppDb\$($_.Name)\" }
Write-Host '(Scripts\, PublishProfiles\, app\ and AppDb.sqlproj are never touched.)'

if (-not $Force) {
    $answer = Read-Host 'Continue? (y/n)'
    if ($answer -ne 'y') { Remove-Item $temp -Recurse -Force; Write-Host 'Cancelled.'; return }
}

foreach ($folder in $extracted) {
    if ($folder.Name -in $ProtectedFolders) { continue }
    $target = Join-Path $ProjectDir $folder.Name
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    Copy-Item $folder.FullName $target -Recurse
}
Remove-Item $temp -Recurse -Force

$count = (Get-ChildItem $ProjectDir -Recurse -Filter *.sql |
          Where-Object { $_.FullName -notmatch '\\(Scripts|bin|obj)\\' }).Count
Write-Host ''
Write-Host "Done. Project now has $count object files." -ForegroundColor Green
Write-Host 'Next steps:'
Write-Host '  1. Build the project (Ctrl+Shift+B) and fix any errors it reports.'
Write-Host '  2. Update Scripts\PostDeploy\LookupData.sql and DevSampleData.sql for your real tables.'
Write-Host '  3. git add . ; git commit -m "Import schema from $Database"'
