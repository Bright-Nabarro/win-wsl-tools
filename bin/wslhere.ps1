[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Path,

    [string] $Profile = $env:WSLHERE_PROFILE,

    [string] $Distro = $env:WSLHERE_DISTRO,

    [switch] $NewWindow,

    [switch] $DryRun,

    [switch] $Help
)

function Show-Usage {
    @'
Usage:
  wslhere [PATH] [-Profile NAME] [-Distro NAME] [-NewWindow] [-DryRun]

Opens WSL2 in Windows Terminal at the current Windows directory, or PATH if provided.

Selection order:
  1. -Profile or WSLHERE_PROFILE
  2. -Distro or WSLHERE_DISTRO
  3. Windows Terminal default profile, if it is a WSL profile
  4. First WSL-looking profile in Windows Terminal settings
  5. Plain wsl.exe fallback

Examples:
  wslhere
  wslhere C:\Projects\demo
  wslhere -Profile Ubuntu-24.04
  wslhere -Distro Ubuntu-24.04
  wslhere -DryRun
'@
}

function Join-CommandLine {
    param([string[]] $Parts)

    @($Parts | ForEach-Object {
        if ($_ -match '[\s"]') {
            '"' + ($_ -replace '"', '\"') + '"'
        }
        else {
            $_
        }
    }) -join ' '
}

function Resolve-DirectoryPath {
    param([string] $InputPath)

    if ([string]::IsNullOrWhiteSpace($InputPath)) {
        return (Get-Location).ProviderPath
    }

    $resolved = (Resolve-Path -LiteralPath $InputPath -ErrorAction Stop).ProviderPath
    if (-not (Test-Path -LiteralPath $resolved -PathType Container)) {
        throw "Path is not a directory: $resolved"
    }

    return $resolved
}

function Get-WindowsTerminalSettingsPath {
    $localAppData = [Environment]::GetFolderPath('LocalApplicationData')
    $candidates = @(
        'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json',
        'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json',
        'Microsoft\Windows Terminal\settings.json'
    )

    foreach ($candidate in $candidates) {
        $path = Join-Path $localAppData $candidate
        if (Test-Path -LiteralPath $path) {
            return $path
        }
    }

    return $null
}

function ConvertFrom-JsonWithComments {
    param([string] $Text)

    try {
        return $Text | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        try {
            Add-Type -AssemblyName System.Text.Json -ErrorAction Stop
            $options = [System.Text.Json.JsonDocumentOptions]::new()
            $options.CommentHandling = [System.Text.Json.JsonCommentHandling]::Skip
            $options.AllowTrailingCommas = $true
            $document = [System.Text.Json.JsonDocument]::Parse($Text, $options)
            return $document.RootElement.GetRawText() | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            return $null
        }
    }
}

function Get-WindowsTerminalSettings {
    $settingsPath = Get-WindowsTerminalSettingsPath
    if (-not $settingsPath) {
        return $null
    }

    $text = Get-Content -Raw -LiteralPath $settingsPath
    return ConvertFrom-JsonWithComments -Text $text
}

function Test-WslProfile {
    param($TerminalProfile)

    $source = [string] $TerminalProfile.source
    $commandLine = [string] $TerminalProfile.commandline

    return (
        $source -match 'Wsl' -or
        $commandLine -match '(?i)(^|\s|\\)wsl(\.exe)?(\s|$)' -or
        $commandLine -match '(?i)\\wsl\.exe(\s|$)'
    )
}

function Find-WslProfileName {
    param(
        $Settings,
        [string] $RequestedProfile,
        [string] $RequestedDistro
    )

    if (-not $Settings -or -not $Settings.profiles -or -not $Settings.profiles.list) {
        if (-not [string]::IsNullOrWhiteSpace($RequestedProfile)) {
            return $RequestedProfile
        }
        return $null
    }

    $profiles = @($Settings.profiles.list)

    if (-not [string]::IsNullOrWhiteSpace($RequestedProfile)) {
        $match = $profiles | Where-Object {
            $_.name -ieq $RequestedProfile -or $_.guid -ieq $RequestedProfile
        } | Select-Object -First 1

        if ($match) {
            return [string] $match.name
        }

        return $RequestedProfile
    }

    if (-not [string]::IsNullOrWhiteSpace($RequestedDistro)) {
        $escapedDistro = [regex]::Escape($RequestedDistro)
        $match = $profiles | Where-Object {
            $_.name -ieq $RequestedDistro -or
            ([string] $_.commandline) -match "(?i)(--distribution|-d)\s+[`"']?$escapedDistro[`"']?"
        } | Select-Object -First 1

        if ($match) {
            return [string] $match.name
        }
    }

    $defaultProfile = [string] $Settings.defaultProfile
    if (-not [string]::IsNullOrWhiteSpace($defaultProfile)) {
        $match = $profiles | Where-Object {
            ($_.guid -ieq $defaultProfile -or $_.name -ieq $defaultProfile) -and (Test-WslProfile $_)
        } | Select-Object -First 1

        if ($match) {
            return [string] $match.name
        }
    }

    $firstWslProfile = $profiles | Where-Object { Test-WslProfile $_ } | Select-Object -First 1
    if ($firstWslProfile) {
        return [string] $firstWslProfile.name
    }

    return $null
}

function Get-DefaultWslDistro {
    try {
        $status = & wsl.exe --status 2>$null
        foreach ($line in $status) {
            if ($line -match 'Default\s+(Distribution|Distro):\s*(.+)$') {
                return $Matches[2].Trim()
            }
        }
    }
    catch {
    }

    try {
        $distros = & wsl.exe -l -q 2>$null
        foreach ($line in $distros) {
            $name = ($line -replace "`0", '').Trim()
            if (-not [string]::IsNullOrWhiteSpace($name)) {
                return $name
            }
        }
    }
    catch {
    }

    return $null
}

if ($Help -or $Path -in @('-h', '--help', '/?')) {
    Show-Usage
    exit 0
}

try {
    $targetPath = Resolve-DirectoryPath -InputPath $Path
    $settings = Get-WindowsTerminalSettings

    if ([string]::IsNullOrWhiteSpace($Distro)) {
        $Distro = Get-DefaultWslDistro
    }

    $terminalProfile = Find-WslProfileName -Settings $settings -RequestedProfile $Profile -RequestedDistro $Distro
    $wt = Get-Command wt.exe -ErrorAction SilentlyContinue

    if ($wt) {
        $wtArgs = @()
        if (-not $NewWindow) {
            $wtArgs += @('-w', '0')
        }

        $wtArgs += @('new-tab')

        if (-not [string]::IsNullOrWhiteSpace($terminalProfile)) {
            $wtArgs += @('--profile', $terminalProfile)
        }

        $wtArgs += @('--startingDirectory', $targetPath)

        if ([string]::IsNullOrWhiteSpace($terminalProfile)) {
            $wtArgs += @('wsl.exe')

            if (-not [string]::IsNullOrWhiteSpace($Distro)) {
                $wtArgs += @('-d', $Distro)
            }

            $wtArgs += @('--cd', $targetPath)
        }

        if ($DryRun) {
            Join-CommandLine -Parts (@($wt.Source) + $wtArgs)
            exit 0
        }

        & $wt.Source @wtArgs
        exit $LASTEXITCODE
    }

    $wslArgs = @()
    if (-not [string]::IsNullOrWhiteSpace($Distro)) {
        $wslArgs += @('-d', $Distro)
    }
    elseif (-not [string]::IsNullOrWhiteSpace($Profile)) {
        $wslArgs += @('-d', $Profile)
    }

    $wslArgs += @('--cd', $targetPath)

    if ($DryRun) {
        Join-CommandLine -Parts (@('wsl.exe') + $wslArgs)
        exit 0
    }

    Start-Process -FilePath 'wsl.exe' -ArgumentList $wslArgs
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
