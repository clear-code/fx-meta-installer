rem Copyright (C) 2008-2012 ClearCode Inc.

@IF NOT EXIST config.bat GOTO ENDBATCH


@IF EXIST resources GOTO CONFIG
mkdir "resources"
xcopy _resources\*.sample resources\ /i /s


:CONFIG

call config.bat

del fainstall.exe
del fainstall.ini
del "%INSTALLER_NAME%.exe"

:NSIS

@IF NOT EXIST "%NSIS_PATH%" GOTO ENDBATCH

cd nsis

@IF NOT EXIST helper.exe (
  "%NSIS_PATH%\makensis.exe" helper.nsi
)
start /WAIT helper.exe

"%NSIS_PATH%\makensis.exe" fainstall.nsi
cd ..


:SIGN_TO_INSALLER

@IF NOT EXIST "%SIGN_PFX%" GOTO CREATE_PACKAGE_SOURCES
"%SIGNTOOL_PATH%\signtool.exe" sign /f "%SIGN_PFX%" /p "%SIGN_PASSWORD%" /t "%SIGN_TIMESTAMP%" /d "%SIGN_DESC%" /du "%SIGN_DESC_URL%" fainstall.exe


:CREATE_PACKAGE_SOURCES

rmdir "%INSTALLER_NAME%-source" /s /q
mkdir "%INSTALLER_NAME%-source"

move fainstall.exe "%INSTALLER_NAME%-source\"
move fainstall.ini "%INSTALLER_NAME%-source\"
xcopy resources "%INSTALLER_NAME%-source\resources" /i /s
copy 7z\pack.list "%INSTALLER_NAME%-source\"
copy /b 7z\7zS.sfx + 7z\FxAddonInstaller.tag "%INSTALLER_NAME%-source\fainstall.sfx"
copy 7z\7zr.exe "%INSTALLER_NAME%-source\"
copy 7z\pack.bat "%INSTALLER_NAME%-source\%INSTALLER_NAME%.bat"
copy 7z\pack.sh "%INSTALLER_NAME%-source\%INSTALLER_NAME%.sh"
cd "%INSTALLER_NAME%-source\"

call "%INSTALLER_NAME%.bat

cd ..

:ENDBATCH
