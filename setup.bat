@echo off
setlocal
title Claude Code Docker Setup

echo.
echo  ============================================================
echo   Claude Code in Docker — First-Time Setup
echo  ============================================================
echo.
echo  This will:
echo    1. Check that Docker is installed and running
echo    2. Ask for your Anthropic API key
echo    3. Build the Claude Code container
echo    4. Start it and launch Claude Code
echo.
pause

:: ── Step 1: Check Docker ────────────────────────────────────────
echo.
echo [1/4] Checking Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo.
    echo  ERROR: Docker is not running or not installed.
    echo.
    echo  Please install Docker Desktop from https://www.docker.com/products/docker-desktop/
    echo  then start it and run this script again.
    echo.
    pause
    exit /b 1
)
echo  Docker is running.

:: ── Step 2: API key ─────────────────────────────────────────────
echo.
echo [2/4] Setting up your API key...
echo.

if exist ".env" (
    echo  Found existing .env file. Skipping key setup.
    echo  To change your key, edit .env manually.
    goto build
)

echo  You need an Anthropic API key to use Claude Code.
echo  Get one at: https://console.anthropic.com/
echo.
set /p APIKEY=" Enter your Anthropic API key: "

if "%APIKEY%"=="" (
    echo.
    echo  ERROR: No API key entered. Aborting.
    pause
    exit /b 1
)

echo ANTHROPIC_API_KEY=%APIKEY%> .env
echo.
echo  API key saved to .env

:: ── Step 3: Build ───────────────────────────────────────────────
:build
echo.
echo [3/4] Building the Claude Code container...
echo  (This takes a few minutes the first time — downloads ~1 GB)
echo.
docker compose build
if errorlevel 1 (
    echo.
    echo  ERROR: Docker build failed. Check the output above for details.
    pause
    exit /b 1
)

:: ── Step 4: Start and launch ────────────────────────────────────
echo.
echo [4/4] Starting container...
docker compose up -d
if errorlevel 1 (
    echo.
    echo  ERROR: Could not start container.
    pause
    exit /b 1
)

echo.
echo  ============================================================
echo   Setup complete!
echo  ============================================================
echo.
echo   Your workspace folder is: %~dp0workspace\
echo   Put your project files there — they appear at /workspace
echo   inside the container.
echo.
echo   To launch Claude Code any time: double-click claude.bat
echo.
echo  ============================================================
echo.

set /p LAUNCH=" Launch Claude Code now? (y/n): "
if /i "%LAUNCH%"=="y" (
    start "Claude Code" cmd /k "docker exec -it claude-code claude"
)

:end
endlocal
pause
