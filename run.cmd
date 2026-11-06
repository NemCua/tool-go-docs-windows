@echo off
setlocal
cd /d "%~dp0"

set "DOTNET_EXE=dotnet"
if exist "%USERPROFILE%\.dotnet\dotnet.exe" (
    set "DOTNET_EXE=%USERPROFILE%\.dotnet\dotnet.exe"
    set "DOTNET_ROOT=%USERPROFILE%\.dotnet"
) else (
    where dotnet >nul 2>nul
    if errorlevel 1 (
        echo Khong tim thay .NET SDK. Chay lenh cai dat trong windows\CAI-DAT-MAY-MOI.md truoc.
        exit /b 1
    )
)

"%DOTNET_EXE%" run --project windows -- %*
exit /b %ERRORLEVEL%
