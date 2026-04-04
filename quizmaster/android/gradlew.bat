\
@echo off
setlocal
set SCRIPT_DIR=%~dp0
set PROPS_FILE=%SCRIPT_DIR%gradle\wrapper\gradle-wrapper.properties

for /f "tokens=1,* delims==" %%A in ('findstr /b "distributionUrl=" "%PROPS_FILE%"') do set DIST_URL=%%B

if not defined DIST_URL (
  echo distributionUrl not found in %PROPS_FILE%
  exit /b 1
)

echo This project is intended to be built in CI or with a local Gradle installation.
echo Use GitHub Actions for the APK build.
exit /b 1
