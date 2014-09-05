@echo off
rem ==================================================================
rem This Source Code Form is subject to the terms of the Mozilla Public
rem License, v. 2.0. If a copy of the MPL was not distributed with this
rem file, You can obtain one at http://mozilla.org/MPL/2.0/.
rem ==================================================================
rem This is a limited version of Fx Meta Installer.
rem Supports only following features:
rem 
rem  * Install Firefox or Thunderbird silently.
rem  * Install configuration file for MCD (AutoConfig) automatically.
rem 
rem Copyright (C) 2013-2014 ClearCode Inc.
rem ==================================================================

rem =========== CONFIGURATIONS ===========

rem Path to the installer of Firefox itself
set   INSTALLER_PATH="C:\Users\Public\Firefox Setup 31.1.0esr.exe"

rem Path to the configuration file
set   AUTOCONFIG_PATH="C:\Users\Public\autoconfig.cfg"

rem Configurations for the installer
set   InstallDirectoryName=
set   InstallDirectoryPath=C:\Mozilla Firefox
set   QuickLaunchShortcut=
set   DesktopShortcut=
set   StartMenuShortcuts=
set   StartMenuDirectoryName=
set   MaintenanceService=true

rem =========== /CONFIGURATIONS ==========


:CHECK_FILES_EXISTENCE
if exist %INSTALLER_PATH% goto END_CHECK_FILES_EXISTENCE

echo ERROR: File not found: %INSTALLER_PATH%
exit 1

:END_CHECK_FILES_EXISTENCE


rem =========== INITIALIZATION ==========

:DETECT_BASE_DIR

set DEFAULT_INSTALL_DIRECOTRY_NAME=Mozilla Firefox
set BASE_DIR=%ProgramFiles(x86)%
if "%BASE_DIR%"=="" set BASE_DIR=%ProgramFiles%

if not "%InstallDirectoryName%"=="" goto SET_BASE_DIR_FROM_InstallDirectoryName
if not "%InstallDirectoryPath%"=="" goto SET_BASE_DIR_FROM_InstallDirectoryPath
goto SET_BASE_DIR_DEFAULT

:SET_BASE_DIR_FROM_InstallDirectoryName
  set BASE_DIR=%BASE_DIR%\%InstallDirectoryPath%
  goto END_DETECT_BASE_DIR

:SET_BASE_DIR_FROM_InstallDirectoryPath
  set BASE_DIR=%InstallDirectoryPath%
  goto END_DETECT_BASE_DIR

:SET_BASE_DIR_DEFAULT
  set BASE_DIR=%BASE_DIR%\%DEFAULT_INSTALL_DIRECOTRY_NAME%

:END_DETECT_BASE_DIR
echo Base directory is %BASE_DIR%


set AUTOCONFIG_BASE_NAME=autoconfig
set AUTOCONFIG_LOADER_DIST_PATH=%BASE_DIR%\defaults\pref\%AUTOCONFIG_BASE_NAME%.js
set AUTOCONFIG_DIST_PATH=%BASE_DIR%\%AUTOCONFIG_BASE_NAME%.cfg



rem =========== INSTALLATION ==========

:INSTALL_APPLICATION

set INIFILE=%TEMP%\Firefox-setup.ini
>  "%INIFILE%" echo [Install]
>> "%INIFILE%" echo InstallDirectoryName=%InstallDirectoryName%
>> "%INIFILE%" echo InstallDirectoryPath=%InstallDirectoryPath%
>> "%INIFILE%" echo QuickLaunchShortcut=%QuickLaunchShortcut%
>> "%INIFILE%" echo DesktopShortcut=%DesktopShortcut%
>> "%INIFILE%" echo StartMenuShortcuts=%StartMenuShortcuts%
>> "%INIFILE%" echo StartMenuDirectoryName=%StartMenuDirectoryName%
>> "%INIFILE%" echo MaintenanceService=%MaintenanceService%

%INSTALLER_PATH% /INI=%INIFILE%


:INSTALL_AUTOCONFIG

if not exist "%AUTOCONFIG_PATH%" goto END_INSTALL_AUTOCONFIG

copy /Y "%AUTOCONFIG_PATH%" "%AUTOCONFIG_DIST_PATH%"

>  "%AUTOCONFIG_LOADER_DIST_PATH%" echo // load autoconfig file
>> "%AUTOCONFIG_LOADER_DIST_PATH%" echo pref("general.config.filename", "%AUTOCONFIG_BASE_NAME%.cfg");
>> "%AUTOCONFIG_LOADER_DIST_PATH%" echo pref("general.config.vendor", "%AUTOCONFIG_BASE_NAME%");
>> "%AUTOCONFIG_LOADER_DIST_PATH%" echo pref("general.config.obscure_value", 0);

:END_INSTALL_AUTOCONFIG