@echo off
:: claude.bat — Launch Claude Code inside the Docker container.
:: Run setup.bat first if you haven't already.

:: Check setup has been done
if not exist ".env" (
    echo.
    echo  No .env file found. Please run setup.bat first.
    echo.
    pause
    exit /b 1
)

:: Start the container if it isn't already running
docker inspect -f "{{.State.Running}}" claude-code 2>nul | findstr /i "true" >nul
if errorlevel 1 (
    echo Starting container...
    cd /d "%~dp0"
    docker compose up -d
    timeout /t 2 /noisy >nul
)

:: Update Claude Code to the latest version
echo Checking for Claude Code updates...
docker exec claude-code claude update
echo.

:: Open a new terminal window running Claude Code inside the container
start "Claude Code" cmd /k "docker exec -it claude-code claude"
