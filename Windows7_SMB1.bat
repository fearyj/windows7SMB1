:: Run as administrator
@echo off
setlocal EnableDelayedExpansion

echo Checking OS version...

:: Get OS version using ver command and parse it
for /f "tokens=4-5 delims=. " %%i in ('ver') do ( 
    :: Then set the variable Major to have value of 4th str, Minor to have value of 5th str
    set "Major=%%i"
    set "Minor=%%j"
)

:: Remove any brackets from Major version (e.g., [6.1.xxx] becomes 6)
set "Major=!Major:[=!"
set "Major=!Major:]=!"

:: Check for Windows 7 (Major 6, Minor 1)
if "!Major!"=="6" if "!Minor!"=="1" (
    echo Detected Windows 7. Disabling SMBv1...
    :: Modify registry to disable SMBv1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 0 /f >nul 2>&1
    if errorlevel 1 (
        echo Error disabling SMBv1.
    ) else (
        :: Restart LanmanServer service
        net stop lanmanserver /y >nul 2>&1
        net start lanmanserver >nul 2>&1
        echo LanmanServer restarted
        if errorlevel 1 (
            echo Error restarting SMB service.
        ) else (
            echo SMBv1 has been successfully disabled on Windows 7.
        )
    )
) else (
    echo This is not Windows 7.
)
