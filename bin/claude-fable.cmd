@echo off
rem claude-fable — Launch Claude Code with Fable-class behavioral discipline
set "PROMPT_FILE=%USERPROFILE%\.claude\fable-emulation-prompt.md"

if not exist "%PROMPT_FILE%" (
    echo Error: %PROMPT_FILE% not found
    exit /b 1
)

claude --append-system-prompt-file "%PROMPT_FILE%" --dangerously-skip-permissions --remote-control %*
exit /b %ERRORLEVEL%
