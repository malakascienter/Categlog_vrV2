# Shared paths and helpers, dot-sourced by the other scripts.

$RepoRoot   = Split-Path $PSScriptRoot -Parent
$ProjectDir = Join-Path $RepoRoot 'AppDb'
$ProjectFile = Join-Path $ProjectDir 'AppDb.sqlproj'
$ProfilesDir = Join-Path $ProjectDir 'PublishProfiles'

# Project folders that Import-Database.ps1 must never overwrite.
$ProtectedFolders = @('Scripts', 'PublishProfiles', 'app', 'bin', 'obj')

function Assert-SqlPackage {
    if (-not (Get-Command sqlpackage -ErrorAction SilentlyContinue)) {
        throw "sqlpackage not found. Install it once with:  dotnet tool install -g microsoft.sqlpackage"
    }
}

function Build-Dacpac {
    param([string] $Configuration = 'Debug')

    Write-Host "Building AppDb ($Configuration) ..." -ForegroundColor Cyan
    & dotnet build $ProjectFile -c $Configuration --nologo -v quiet
    if ($LASTEXITCODE -ne 0) { throw 'Build failed. Fix the errors above first.' }

    return Join-Path $ProjectDir "bin\$Configuration\AppDb.dacpac"
}
