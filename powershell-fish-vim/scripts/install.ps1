[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSEdition -ne 'Core') {
    throw 'Run this installer with PowerShell 7 (pwsh), not Windows PowerShell.'
}

if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    throw 'oh-my-posh is not installed. Run: winget install --id JanDeDobbeleer.OhMyPosh --exact'
}

$packageRoot = Split-Path -Parent $PSScriptRoot
$configRoot = Join-Path $packageRoot 'configs'
$sourceProfile = Join-Path $configRoot 'Microsoft.PowerShell_profile.ps1'
$sourceTheme = Join-Path $configRoot 'fish-vim.omp.json'
$targetProfile = $PROFILE.CurrentUserCurrentHost
$targetRoot = Split-Path -Parent $targetProfile
$targetTheme = Join-Path $targetRoot 'fish-vim.omp.json'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

[void][scriptblock]::Create((Get-Content -LiteralPath $sourceProfile -Raw))

$omp = (Get-Command oh-my-posh -ErrorAction Stop).Source
& $omp print primary --config $sourceTheme | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Oh My Posh theme validation failed with exit code $LASTEXITCODE."
}

if ($PSCmdlet.ShouldProcess($targetRoot, 'Install PowerShell fish/vim configuration')) {
    New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null

    foreach ($target in @($targetProfile, $targetTheme)) {
        if (Test-Path -LiteralPath $target) {
            Copy-Item -LiteralPath $target -Destination "$target.backup-$stamp"
        }
    }

    Copy-Item -LiteralPath $sourceProfile -Destination $targetProfile -Force
    Copy-Item -LiteralPath $sourceTheme -Destination $targetTheme -Force
}

Write-Host "Installed profile: $targetProfile" -ForegroundColor Green
Write-Host "Installed theme:   $targetTheme" -ForegroundColor Green
Write-Host 'Restart Windows Terminal or run: . $PROFILE' -ForegroundColor Cyan
