[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Path,

    [switch] $Help
)

function Show-Usage {
    @'
Usage:
  mpath [PATH]

Converts the current Windows directory, or PATH if provided, to an MSYS2 path.

Examples:
  mpath
  mpath E:\Projects\demo
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

function ConvertTo-Msys2Path {
    param([string] $WindowsPath)

    if ($WindowsPath -notmatch '^[A-Za-z]:[\\/]?') {
        throw "Only drive-letter paths can be converted to MSYS2 paths: $WindowsPath"
    }

    $drive = $WindowsPath.Substring(0, 1).ToLowerInvariant()
    $rest = $WindowsPath.Substring(2).TrimStart('\', '/') -replace '\\', '/'

    if ([string]::IsNullOrEmpty($rest)) {
        return "/$drive"
    }

    return "/$drive/$rest"
}

if ($Help -or $Path -in @('-h', '--help', '/?')) {
    Show-Usage
    exit 0
}

try {
    $resolvedPath = Resolve-WindowsPath -InputPath $Path
    ConvertTo-Msys2Path -WindowsPath $resolvedPath
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
