@echo off
REM ==============================================================
REM SonarQube 10.7 LTS Quick Install Script for Windows
REM ==============================================================
REM This script downloads and installs Java 17 and SonarQube
REM Run as Administrator

setlocal enabledelayedexpansion

echo.
echo ==============================================================
echo SonarQube 10.7 LTS Installation Script
echo ==============================================================
echo.

REM Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: This script should be run as Administrator
    echo Please run this batch file as Administrator
    echo.
)

REM Check if Java is installed
java -version >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Java is already installed
    java -version
    echo.
) else (
    echo Installing Java 17 LTS...
    echo.
    REM Create Java directory
    if not exist C:\Java (
        mkdir C:\Java
    )
    
    REM Download Java
    echo Downloading OpenJDK 17 LTS from Adoptium...
    powershell -Command ^
        "Invoke-WebRequest -Uri 'https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%%2B11/OpenJDK17U-jdk_x64_windows_hotspot_17.0.13_11.zip' -OutFile 'C:\Java\openjdk17.zip'" ^
        2>nul
    
    if exist C:\Java\openjdk17.zip (
        echo ✓ Download complete
        echo.
        echo Extracting Java...
        powershell -Command "Expand-Archive -Path 'C:\Java\openjdk17.zip' -DestinationPath 'C:\Java' -Force"
        del C:\Java\openjdk17.zip
        echo ✓ Java extracted
        echo.
        
        REM Set JAVA_HOME
        for /d %%D in (C:\Java\jdk-*) do (
            setx JAVA_HOME %%D
            set "JAVA_HOME=%%D"
            echo ✓ JAVA_HOME set to %%D
        )
    ) else (
        echo ✗ Failed to download Java
        echo Please download manually from https://adoptium.net/temurin/releases/
        pause
        exit /b 1
    )
)

echo.
echo ==============================================================
echo.

REM Check if SonarQube is installed
if exist C:\SonarQube\sonarqube-10.7.0.96680 (
    echo ✓ SonarQube 10.7 already installed
    echo.
) else (
    echo Installing SonarQube 10.7 LTS...
    echo.
    
    REM Create SonarQube directory
    if not exist C:\SonarQube (
        mkdir C:\SonarQube
    )
    
    REM Download SonarQube
    echo Downloading SonarQube 10.7 LTS...
    powershell -Command ^
        "Invoke-WebRequest -Uri 'https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.7.0.96680.zip' -OutFile 'C:\SonarQube\sonarqube-10.7.0.zip'" ^
        2>nul
    
    if exist C:\SonarQube\sonarqube-10.7.0.zip (
        echo ✓ Download complete
        echo.
        echo Extracting SonarQube...
        powershell -Command "Expand-Archive -Path 'C:\SonarQube\sonarqube-10.7.0.zip' -DestinationPath 'C:\SonarQube' -Force"
        del C:\SonarQube\sonarqube-10.7.0.zip
        echo ✓ SonarQube extracted
        echo.
        echo SonarQube installed at: C:\SonarQube\sonarqube-10.7.0.96680
    ) else (
        echo ✗ Failed to download SonarQube
        echo Please download manually from https://www.sonarqube.org/downloads/
        pause
        exit /b 1
    )
)

echo.
echo ==============================================================
echo Installation Complete!
echo ==============================================================
echo.
echo Next steps:
echo.
echo 1. Start SonarQube:
echo    C:\SonarQube\sonarqube-10.7.0.96680\bin\windows-x86-64\StartSonar.bat
echo.
echo 2. Open in browser:
echo    http://localhost:9000
echo.
echo 3. Login with default credentials:
echo    Username: admin
echo    Password: admin
echo.
echo 4. Create project and generate token
echo    (See SONARQUBE_INSTALLATION.md for detailed steps)
echo.
echo 5. Push code to sonarqube-latest branch:
echo    git push origin sonarqube-latest
echo.
echo ==============================================================
echo.
pause
