[CmdletBinding()]
param(
    [string] $Destination = (Join-Path $HOME 'bin'),
    [switch] $AddToPath,
    [switch] $Profile,
    [switch] $All
)

$ErrorActionPreference = 'Stop'
$sourceDir = Join-Path $PSScriptRoot 'bin'
New-Item -ItemType Directory -Force -Path $Destination | Out-Null

foreach ($file in @('wslpath.ps1', 'wslpath.cmd', 'msyspath.ps1', 'msyspath.cmd', 'wslhere.ps1', 'wslhere.cmd')) {
    Copy-Item -LiteralPath (Join-Path $sourceDir $file) -Destination (Join-Path $Destination $file) -Force
}
Write-Host "Installed CLI tools to $Destination"

if ($AddToPath -or $All) {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $entries = @($userPath -split ';' | Where-Object { $_ })
    if ($entries -notcontains $Destination) {
        [Environment]::SetEnvironmentVariable('Path', (($entries + $Destination) -join ';'), 'User')
        Write-Host "Added $Destination to User PATH"
    }
}

if ($Profile -or $All) {
    $profileDir = Split-Path -Parent $PROFILE
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'configs\powershell\Microsoft.PowerShell_profile.ps1') -Destination $PROFILE -Force
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'configs\powershell\fish-vim.omp.json') -Destination (Join-Path $profileDir 'fish-vim.omp.json') -Force
    Write-Host "Installed PowerShell profile to $profileDir"
}
