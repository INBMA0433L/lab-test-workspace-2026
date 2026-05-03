@echo off

REM === configuration ===
SET "ORIG_EXT_DIR=%USERPROFILE%\.vscode\extensions"

REM === get paths ===
set "SCRIPT_PATH=%~dp0"
set "SCRIPT_PATH=%SCRIPT_PATH:~0,-1%"
for %%A in ("%SCRIPT_PATH%") do (
    for %%B in ("%%~dpA") do set "HOME_DIR=%%~fB"
)
for %%A in ("%SCRIPT_PATH%") do set "WORKSPACE_NAME=%%~nxA"

SET "WORKSPACE_DIR=%HOME_DIR%\%WORKSPACE_NAME%"
SET "CUSTOM_EXT_DIR=%WORKSPACE_DIR%\extensions"
SET "WORKSPACE_FILE=%WORKSPACE_DIR%\%WORKSPACE_NAME%.code-workspace"
SET "VS_CODE_FOLDER=%WORKSPACE_DIR%\.vscode"
SET "SQL_DEVELOPER_FOLDER=c:\Users\tothr\AppData\Roaming\DBTools"

echo Home directory: "%HOME_DIR%"
echo Workspace: "%WORKSPACE_NAME%"

REM === Ensure workspace folder exists ===
IF NOT EXIST "%WORKSPACE_DIR%" (
    echo Workspace folder "%WORKSPACE_DIR%" does not exist.
    exit /b 1
)

REM === Ensure .vscode folder exists ===
IF NOT EXIST "%VS_CODE_FOLDER%" (
    echo .vscode folder "%VS_CODE_FOLDER%" does not exist.
    exit /b 1
)

REM === Clean and prepare custom extension dir ===
IF EXIST "%CUSTOM_EXT_DIR%" (
    rd /s /q "%CUSTOM_EXT_DIR%"
)
mkdir "%CUSTOM_EXT_DIR%"

REM === Create the .code-workspace file ===
(
    echo {
    echo   "folders": [
    echo     {
    echo       "path": "."
    echo     }
    echo   ],
    echo   "settings": {
    echo     "extensions.ignoreRecommendations": true
    echo   }
    echo }
) > "%WORKSPACE_FILE%"

REM === Create the .settings file ===
(
    echo  {
    echo  }
) > "%VS_CODE_FOLDER%\settings.json"

REM === Removing connections ===

if exist "%SQL_DEVELOPER_FOLDER%" (
    echo Clearing subfolders in %SQL_DEVELOPER_FOLDER%...
    pushd "%SQL_DEVELOPER_FOLDER%"
    for /d %%i in (*) do rd /s /q "%%i"
    popd
    echo Cleanup complete.
) else (
    echo Directory not found.
)
popd


REM === Launch VS Code ===
pushd "%WORKSPACE_DIR%"
SET "COMMAND=code --extensions-dir extensions --user-data-dir user-data --install-extension oracle.sql-developer --force"
echo %COMMAND%
call %COMMAND%

REM === Create the .settings file ===
(
    echo  {
    echo      "extensions.allowed": {
    echo        "oracle.sql-developer": true
    echo      },
    echo      "editor.fontSize": 14,
    echo      "editor.mouseWheelZoom": true,
    echo      "editor.formatOnType": true,
    echo      "security.workspace.trust.untrustedFiles": "open",
    echo      "chat.disableAIFeatures": true,
    echo      "workbench.colorCustomizations": {
    echo        "activityBar.background": "#3f7467",
    echo        "activityBar.foreground": "#e1e8e6",
    echo        "activityBar.activeBackground": "#ffab0d", 
    echo        "activityBar.activeBorder": "#FFD700",
    echo        "activityBar.inactiveForeground": "#FFD700",
    echo        "activityBar.border": "#fff"
    echo      },
    echo      "sqldeveloper.datagrid.fontFamily": "Consolas, 'Courier New', monospace",
    echo      "sqldeveloper.format.general.keywordCase": "UPPER",
    echo      "sqldeveloper.format.general.identifierCase": "lower",
    echo      "sqldeveloper.logging.enable": false
    echo  }
) > "%WORKSPACE_DIR%\user-data\User\settings.json"


echo code --extensions-dir extensions --user-data-dir user-data "%WORKSPACE_NAME%.code-workspace" 
code --extensions-dir extensions --user-data-dir user-data "%WORKSPACE_NAME%.code-workspace" 
popd
