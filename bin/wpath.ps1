[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Path,

    [string] $MountRoot = $env:WPATH_MOUNT_ROOT,

    [switch] $Help
)

function Show-Usage {
    @'
Usage:
  wpath [PATH]

Converts the current Windows directory, or PATH if provided, to a WSL mount path.

Environment:
  WPATH_MOUNT_ROOT  Override the WSL automount root. Default: /mnt

Examples:
  wpath
  wpath C:\Projects\demo
'@
}

function Resolve-WindowsPath {
    param([string] $InputPath)

    if ([string]::IsNullOrWhiteSpace($InputPath)) {
        return (Get-Location).ProviderPath
    }

    try {
        return (Resolve-Path -LiteralPath $InputPath -ErrorAction Stop).ProviderPath
    }
    catch {
        return [System.IO.Path]::GetFullPath($InputPath)
    }
}

function ConvertTo-WslMountPath {
    param(
        [string] $WindowsPath,
        [string] $Root
    )

    if ($WindowsPath -notmatch '^[A-Za-z]:[\\/]?') {
        throw "Only drive-letter paths can be converted to WSL mount paths: $WindowsPath"
    }

    $normalizedRoot = if ([string]::IsNullOrWhiteSpace($Root)) { '/mnt' } else { $Root }
    $normalizedRoot = '/' + $normalizedRoot.Trim('/')
    $drive = $WindowsPath.Substring(0, 1).ToLowerInvariant()
    $rest = $WindowsPath.Substring(2).TrimStart('\', '/') -replace '\\', '/'

    if ([string]::IsNullOrEmpty($rest)) {
        return "$normalizedRoot/$drive"
    }

    return "$normalizedRoot/$drive/$rest"
}

if ($Help -or $Path -in @('-h', '--help', '/?')) {
    Show-Usage
    exit 0
}

try {
    $resolvedPath = Resolve-WindowsPath -InputPath $Path
    ConvertTo-WslMountPath -WindowsPath $resolvedPath -Root $MountRoot
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
