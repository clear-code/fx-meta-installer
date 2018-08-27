@echo off
rem Copyright (C) 2008-2012 ClearCode Inc.

:PREPARE_CONFIG_BAT
IF EXIST config.bat GOTO PREPARE_CONFIG_NSH
copy config.bat.sample config.bat

:PREPARE_CONFIG_NSH
IF EXIST config.nsh GOTO PREPARE_RESOURCES
copy config.nsh.sample config.nsh

:PREPARE_RESOURCES
IF EXIST resources GOTO CONFIG
mkdir "resources"
xcopy _resources\*.sample resources\ /i /s
ren resources\*.sample *.


:CONFIG

call config.bat

del fainstall.exe
del fainstall.ini

:NSIS

IF NOT EXIST "%NSIS_PATH%" GOTO ENDBATCH

cd nsis

IF NOT EXIST helper.exe (
  "%NSIS_PATH%\makensis.exe" helper.nsi
)
start /WAIT helper.exe

"%NSIS_PATH%\makensis.exe" fainstall.nsi
cd ..


:CHECK_RESULT
IF EXIST fainstall.exe GOTO SIGN_TO_INSALLER
echo "Failed to build fainstall.exe!"
exit /b 1


:SIGN_TO_INSALLER

IF NOT EXIST "%SIGN_PFX%" GOTO CREATE_PACKAGE_SOURCES
"%SIGNTOOL_PATH%\signtool.exe" sign /f "%SIGN_PFX%" /p "%SIGN_PASSWORD%" /t "%SIGN_TIMESTAMP%" /d "%SIGN_DESC%" /du "%SIGN_DESC_URL%" fainstall.exe


:CREATE_PACKAGE_SOURCES

for /f %%s in ('type product.txt') do set INSTALLER_NAME=%%s

del "%INSTALLER_NAME%.exe"
rmdir "%INSTALLER_NAME%-source" /s /q
mkdir "%INSTALLER_NAME%-source"

move fainstall.exe "%INSTALLER_NAME%-source\"
move fainstall.ini "%INSTALLER_NAME%-source\"
xcopy resources "%INSTALLER_NAME%-source\resources" /i /s
copy 7z\pack.list "%INSTALLER_NAME%-source\"
copy /b 7z\7zS.sfx.with-manifest + 7z\FxMetaInstaller.tag "%INSTALLER_NAME%-source\fainstall.sfx"
copy 7z\7zr.exe "%INSTALLER_NAME%-source\"
copy 7z\pack.bat "%INSTALLER_NAME%-source\%INSTALLER_NAME%.bat"
copy 7z\pack.sh "%INSTALLER_NAME%-source\%INSTALLER_NAME%.sh"
cd "%INSTALLER_NAME%-source\"

rem call "%INSTALLER_NAME%.bat

cd ..

:ENDBATCH
echo "Success"
exit /b 0

