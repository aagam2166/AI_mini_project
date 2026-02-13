@echo off
REM Smart Home Energy Management System - Startup Script
REM This script starts both the Flask backend and opens the frontend

echo.
echo ========================================
echo  Smart Home Energy Manager - Starting
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://www.python.org/
    pause
    exit /b 1
)

REM Check if required packages are installed
echo [1/3] Checking dependencies...
pip show flask >nul 2>&1
if errorlevel 1 (
    echo [*] Installing dependencies...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo ERROR: Failed to install dependencies
        pause
        exit /b 1
    )
)

REM Start Flask backend
echo [2/3] Starting backend server...
start "Flask Backend" cmd /k "python app.py"
echo [+] Backend server is starting...

REM Wait for backend to start
timeout /t 3 /nobreak

REM Open frontend in default browser
echo [3/3] Opening frontend...
start "" index.html

echo.
echo ========================================
echo  ✓ System started successfully!
echo  Backend: http://localhost:5000
echo  Frontend: index.html
echo ========================================
echo.
pause
