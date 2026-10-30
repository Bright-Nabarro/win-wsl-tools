if ($env:WT_SESSION -or $env:TERM_PROGRAM -eq 'WezTerm') {
    $ConsoleEncoding = [System.Text.UTF8Encoding]::new($false)
    [Console]::InputEncoding = $ConsoleEncoding
    [Console]::OutputEncoding = $ConsoleEncoding
    $OutputEncoding = $ConsoleEncoding
}

function Add-PathEntry {
    param([Parameter(Mandatory)][string]$Entry)

    if (-not (Test-Path -LiteralPath $Entry)) {
        return
    }

    $current = $env:PATH -split ';' | Where-Object { $_ }
    if ($current -notcontains $Entry) {
        $env:PATH = (@($Entry) + $current) -join ';'
    }
}

$ompExecutable = $null
foreach ($candidate in @(
    (Get-Command oh-my-posh -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1),
    (Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\bin\oh-my-posh.exe'),
    (Join-Path $env:ProgramFiles 'oh-my-posh\bin\oh-my-posh.exe')
)) {
    if ($candidate -and (Test-Path -LiteralPath $candidate)) {
        $ompExecutable = $candidate
        break
    }
}

$ompConfig = Join-Path $PSScriptRoot 'fish-vim.omp.json'
if ($ompExecutable -and (Test-Path -LiteralPath $ompConfig)) {
    & $ompExecutable init pwsh --config $ompConfig | Invoke-Expression
}

if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    if ($env:DSH_SESSION_ID) {
        Set-PSReadLineOption -HistorySaveStyle SaveNothing
    }

    $psrlOptions = @{
        EditMode                      = 'Vi'
        HistoryNoDuplicates           = $true
        HistorySearchCursorMovesToEnd = $true
        BellStyle                     = 'None'
    }

    try {
        $psrlOptions.PredictionSource = 'HistoryAndPlugin'
        $psrlOptions.PredictionViewStyle = 'InlineView'
        Set-PSReadLineOption @psrlOptions
    }
    catch {
        $psrlOptions.Remove('PredictionSource')
        $psrlOptions.Remove('PredictionViewStyle')
        Set-PSReadLineOption @psrlOptions
    }

    Set-PSReadLineOption -Colors @{
        InlinePrediction = '#6B7089'
    }

    $global:__ViCursorStyleInitialized = $false
    Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler {
        param($mode)
        if (-not $global:__ViCursorStyleInitialized) {
            $global:__ViCursorStyleInitialized = $true
            return
        }

        if ($mode -eq 'Command') {
            [Console]::Write("`e[2 q")
        }
        else {
            [Console]::Write("`e[6 q")
        }
    }

    Set-PSReadLineKeyHandler -ViMode Insert -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -ViMode Insert -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -ViMode Command -Key k -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -ViMode Command -Key j -Function HistorySearchForward
    Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+a -Function BeginningOfLine
    Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+e -Function AcceptSuggestion
    Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+w -Function BackwardKillWord
    Set-PSReadLineKeyHandler -ViMode Insert -Key Tab -Function MenuComplete
}

function ep { explorer.exe . }
