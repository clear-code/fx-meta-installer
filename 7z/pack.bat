rem Copyright (C) 2008-2014 ClearCode Inc.

rem ====================== CUSTOMIZABLE SECTION =======================

set SIGNTOOL_PATH=C:\Program Files\Microsoft Platform SDK\Bin
set SIGN_PFX=C:\Documents and Settings\All Users\Documents\ms_authenticode_cert.pfx
set SIGN_PASSWORD=password
set SIGN_TIMESTAMP=http://timestamp.globalsign.com/scripts/timestamp.dll
set SIGN_DESC=
set SIGN_DESC_URL=

rem ===================================================================

set INSTALLER_NAME=%~n0

:SEVENZIP

del "packed.7z"
del "%INSTALLER_NAME%.exe"
del "%INSTALLER_NAME%-*.exe"

7zr.exe a -t7z packed.7z @pack.list -mx=9 -xr!*.svn -xr!*.sample

set VERSION_LINE=""
for /f "tokens=*" %%i in ('findstr DisplayVersion fainstall.ini') do set VERSION_LINE=%%i
set VERSION=%VERSION_LINE:~15%
if not "%VERSION%" == "" set INSTALLER_NAME=%INSTALLER_NAME%-%VERSION%

copy /b fainstall.sfx + packed.7z "%INSTALLER_NAME%.exe"

del "packed.7z"


:SIGN_TO_PACKAGE

@IF NOT EXIST "%SIGN_PFX%" GOTO ENDBATCH
"%SIGNTOOL_PATH%\signtool.exe" sign /f "%SIGN_PFX%" /p "%SIGN_PASSWORD%" /t "%SIGN_TIMESTAMP%" /d "%SIGN_DESC%" /du "%SIGN_DESC_URL%" "%INSTALLER_NAME%.exe"


:ENDBATCH
