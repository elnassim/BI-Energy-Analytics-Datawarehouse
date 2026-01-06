@echo off
REM ============================================================
REM ETL Job Runner for DM Impact Environnemental
REM ============================================================

REM Set variables
SET PENTAHO_DIR=C:\Users\moha-\OneDrive\Desktop\BI\data-integration
SET JOB_FILE=C:\Users\moha-\OneDrive\Desktop\BI-Energy-Analytics-Datawarehouse\ETL\Jobs\Load_DM_Impact_Env.kjb
SET LOG_DIR=C:\Users\moha-\OneDrive\Desktop\BI-Energy-Analytics-Datawarehouse\ETL\logs
SET LOG_FILE=%LOG_DIR%\etl_impact_env_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log

REM Create log directory if it doesn't exist
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Start logging
echo ============================================================ >> %LOG_FILE%
echo ETL Job Started at %date% %time% >> %LOG_FILE%
echo ============================================================ >> %LOG_FILE%
echo. >> %LOG_FILE%

REM Check if Pentaho directory exists
if not exist "%PENTAHO_DIR%" (
    echo ERROR: Pentaho directory not found: %PENTAHO_DIR% >> %LOG_FILE%
    echo ERROR: Pentaho directory not found: %PENTAHO_DIR%
    pause
    exit /b 1
)

REM Check if job file exists
if not exist "%JOB_FILE%" (
    echo ERROR: Job file not found: %JOB_FILE% >> %LOG_FILE%
    echo ERROR: Job file not found: %JOB_FILE%
    pause
    exit /b 1
)

REM Change to Pentaho directory
cd /d "%PENTAHO_DIR%"
echo Changed to Pentaho directory: %PENTAHO_DIR% >> %LOG_FILE%
echo. >> %LOG_FILE%

REM Run the Kitchen (Job execution engine)
echo Executing job: %JOB_FILE% >> %LOG_FILE%
echo. >> %LOG_FILE%

Kitchen.bat /file:"%JOB_FILE%" /level:Basic >> %LOG_FILE% 2>&1

REM Check exit code
if %ERRORLEVEL% EQU 0 (
    echo. >> %LOG_FILE%
    echo ============================================================ >> %LOG_FILE%
    echo ETL Job COMPLETED SUCCESSFULLY at %date% %time% >> %LOG_FILE%
    echo ============================================================ >> %LOG_FILE%
    echo.
    echo ETL Job COMPLETED SUCCESSFULLY!
    echo Check log file: %LOG_FILE%
) else (
    echo. >> %LOG_FILE%
    echo ============================================================ >> %LOG_FILE%
    echo ETL Job FAILED with error code %ERRORLEVEL% at %date% %time% >> %LOG_FILE%
    echo ============================================================ >> %LOG_FILE%
    echo.
    echo ETL Job FAILED! Error code: %ERRORLEVEL%
    echo Check log file: %LOG_FILE%
)

pause