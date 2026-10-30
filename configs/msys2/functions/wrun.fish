function wrun --description '使用 Windows 默认环境运行命令'
    pwsh -NoProfile -cwa '
        $cmd, $rest = $args
        $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
        $p = Start-Process ($cmd ?? "pwsh") -ArgumentList ($rest | % { $_ -match "\s" ? "`"$_`"" : $_ }) -UseNewEnvironment -NoNewWindow -Wait -PassThru
        exit $p.ExitCode
    ' $argv
end
