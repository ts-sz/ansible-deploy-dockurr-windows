@echo off
REM ============================================================================
REM OEM Installation Script
REM This script executes all PowerShell scripts in C:\OEM during Windows setup
REM ============================================================================

echo.
echo ============================================================================
echo Starting OEM Configuration Scripts
echo ============================================================================
echo.

REM Set execution policy for PowerShell scripts
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force"

REM Change to the OEM directory
cd /d C:\OEM

REM Create log file
set LOGFILE=C:\OEM\install.log
echo Installation started at %date% %time% > "%LOGFILE%"
echo. >> "%LOGFILE%"

REM Execute PowerShell scripts in order
echo [1/18] Removing default apps (v2)...
echo [1/18] Removing default apps (v2)... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\remove-default-apps-v2.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: remove-default-apps-v2.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [2/18] Installing Chocolatey...
echo [2/18] Installing Chocolatey... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\chocolatey.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: chocolatey.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [3/18] Disabling advertising ID...
echo [3/18] Disabling advertising ID... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-advid.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-advid.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [4/18] Disabling app suggestions...
echo [4/18] Disabling app suggestions... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-appsuggest.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-appsuggest.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [5/18] Disabling autologin...
echo [5/18] Disabling autologin... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-autologin.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-autologin.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [6/18] Disabling consumer features...
echo [6/18] Disabling consumer features... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-consumer-features.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-consumer-features.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [7/18] Disabling Cortana...
echo [7/18] Disabling Cortana... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-cortana.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-cortana.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [8/18] Disabling error reporting...
echo [8/18] Disabling error reporting... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-errorreporting.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-errorreporting.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [9/18] Disabling feedback...
echo [9/18] Disabling feedback... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-feedback.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-feedback.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [10/18] Disabling maps updates...
echo [10/18] Disabling maps updates... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-maps-updates.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-maps-updates.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [11/18] Disabling quick access...
echo [11/18] Disabling quick access... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-quickaccess.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-quickaccess.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [12/18] Disabling telemetry...
echo [12/18] Disabling telemetry... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-telemetry.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-telemetry.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [13/18] Disabling web search in start menu...
echo [13/18] Disabling web search in start menu... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-web-search-start-menu.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-web-search-start-menu.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [14/18] Disabling Xbox features...
echo [14/18] Disabling Xbox features... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\disable-xbox.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: disable-xbox.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [15/18] Removing shortcuts from public desktop...
echo [15/18] Removing shortcuts from public desktop... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\remove-shorcuts-public-desktop.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: remove-shorcuts-public-desktop.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [16/18] Installing Chocolatey packages...
echo [16/18] Installing Chocolatey packages... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\chocopacks.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: chocopacks.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [17/18] Setting up SSH server...
echo [17/18] Setting up SSH server... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\setup-ssh-server.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: setup-ssh-server.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo [18/18] Running cleanup and compact...
echo [18/18] Running cleanup and compact... >> "%LOGFILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\cleanup-compact-v2.ps1" >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 echo WARNING: cleanup-compact-v2.ps1 failed with error %errorlevel% >> "%LOGFILE%"

echo.
echo ============================================================================
echo OEM Configuration Complete
echo ============================================================================
echo Installation completed at %date% %time% >> "%LOGFILE%"
echo.
echo Log file saved to: %LOGFILE%
echo.

REM Optional: Uncomment the line below to restart after installation
REM shutdown /r /t 30 /c "OEM configuration complete. System will restart in 30 seconds."

exit /b 0
