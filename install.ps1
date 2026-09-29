[CmdletBinding()]
param(
    [string] $InstallDir = (Join-Path $HOME 'bin'),
    [switch] $AddToPath
)

$ErrorActionPreference = 'Stop'

$sourceDir = Join-Path $PSScriptRoot 'bin'
$files = @(
    'msyspath.cmd',
    'msyspath.ps1',
    'wslpath.cmd',
    'wslpath.ps1',
    'wslhere.cmd',
    'wslhere.ps1'
)

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

foreach ($file in $files) {
    Copy-Item -LiteralPath (Join-Path $sourceDir $file) -Destination $InstallDir -Force
}

if ($AddToPath) {
    $resolvedInstallDir = (Resolve-Path -LiteralPath $InstallDir).ProviderPath
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $parts = @($userPath -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $alreadyInPath = $parts | Where-Object {
        $_.TrimEnd('\') -ieq $resolvedInstallDir.TrimEnd('\')
    }

    if (-not $alreadyInPath) {
        $newPath = if ([string]::IsNullOrWhiteSpace($userPath)) {
            $resolvedInstallDir
        }
        else {
            $userPath.TrimEnd(';') + ';' + $resolvedInstallDir
        }

        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    }
}

Write-Host "Installed Windows tools to $InstallDir"
