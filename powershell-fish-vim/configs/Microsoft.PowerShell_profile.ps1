# Fish-like PowerShell experience: Oh My Posh prompt + PSReadLine vi mode.

# Prompt ---------------------------------------------------------------------
$ompConfig = Join-Path $PSScriptRoot 'fish-vim.omp.json'
$ompCommand = Get-Command oh-my-posh -ErrorAction SilentlyContinue

if ($ompCommand -and (Test-Path -LiteralPath $ompConfig)) {
    oh-my-posh init pwsh --config $ompConfig | Invoke-Expression
}

# Vi editing and fish-like interactive conveniences -------------------------
Import-Module PSReadLine

Set-PSReadLineOption `
    -EditMode Vi `
    -BellStyle None `
    -HistoryNoDuplicates `
    -HistorySearchCursorMovesToEnd `
    -MaximumHistoryCount 10000 `
    -ContinuationPrompt '  · '

# Normal mode uses a steady block. Insert mode restores Windows Terminal's
# configured cursorShape (currently "emptyBox") instead of forcing underline.
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler {
    param($Mode)

    $cursorSequence = if ($Mode -eq 'Command') {
        "`e[2 q" # Steady block.
    }
    else {
        "`e[0 q" # Terminal default (Windows Terminal cursorShape).
    }

    [Console]::Write($cursorSequence)
}

# Predictive suggestions require an interactive terminal with VT support.
if ($Host.UI.SupportsVirtualTerminal -and -not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption `
        -PredictionSource History `
        -PredictionViewStyle InlineView
}

# Keep suggestions visible but unobtrusive against both dark and light themes.
Set-PSReadLineOption -Colors @{
    InlinePrediction = "`e[38;2;92;106;114m"
    ContinuationPrompt = "`e[38;2;127;187;179m"
}

# Fish-like prefix history search.
Set-PSReadLineKeyHandler -ViMode Insert -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -ViMode Insert -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -ViMode Command -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -ViMode Command -Key DownArrow -Function HistorySearchForward

# Menu completion, similar to fish's interactive completion list.
Set-PSReadLineKeyHandler -ViMode Insert -Key Tab -Function MenuComplete

# Familiar shortcuts remain available while vi is in Insert mode.
Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+p -Function PreviousHistory
Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+n -Function NextHistory
Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+r -Function ReverseSearchHistory
Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+e -Function EndOfLine
Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+u -Function BackwardDeleteLine
Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+k -Function ForwardDeleteLine
Set-PSReadLineKeyHandler -ViMode Insert -Key Ctrl+l -Function ClearScreen

# Small shell conveniences commonly expected by fish users.
Set-Alias which Get-Command
function mkcd {
    param([Parameter(Mandatory, Position = 0)][string] $Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location -LiteralPath $Path
}
