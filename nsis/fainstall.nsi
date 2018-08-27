;Copyright (C) 2008-2012 ClearCode Inc.

;=== Libraries
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!insertmacro Locate
!insertmacro un.Locate
!insertmacro GetBaseName
!insertmacro GetParent
!insertmacro un.GetParameters
!insertmacro un.GetOptions
!include "WordFunc.nsh"
!insertmacro WordFind
!insertmacro WordReplace
!insertmacro VersionCompare
!insertmacro VersionConvert
!include "StrFunc.nsh"
${StrStr} ; activate macro for installation
${StrStrAdv} ; activate macro for installation
${UnStrStrAdv} ; activate macro for uninstallation
!include "native_message_box.nsh"
!include "logiclib_dir_exists.nsh"
!include "ExecWaitJob.nsh"

;== Definition of utilities
!define DefineDefaultValue "!insertmacro DefineDefaultValue"
!macro DefineDefaultValue Name Value
  !ifndef ${Name}
    !define ${Name} "${Value}"
  !endif
!macroend

Function IsTrue
  Pop $1
  ${StrStr} $0 "1,yes,true" "$1"
  ${If} "$0" != ""
    Push "1"
  ${Else}
    Push "0"
  ${EndIf}
FunctionEnd

!define IsTrue "!insertmacro IsTrue"

!macro IsTrue ResultVar SubString
  Push `${SubString}`
  Call IsTrue
  Pop `${ResultVar}`
!macroend

Function IsFalse
  Pop $1
  ${StrStr} $0 "0,no,false" "$1"
  ${If} "$0" != ""
    Push "1"
  ${Else}
    Push "0"
  ${EndIf}
FunctionEnd

!define IsFalse "!insertmacro IsFalse"

!macro IsFalse ResultVar SubString
  Push `${SubString}`
  Call IsFalse
  Pop `${ResultVar}`
!macroend

;== Basic Information
!include "..\config.nsh"

${DefineDefaultValue} PRODUCT_FULL_NAME    "Fx Meta Installer"
${DefineDefaultValue} PRODUCT_NAME         "FxMetaInstaller"
${DefineDefaultValue} PRODUCT_VERSION      "0.0.0.0"
${DefineDefaultValue} PRODUCT_YEAR         "2012"
${DefineDefaultValue} PRODUCT_PUBLISHER    "ClearCode Inc."
${DefineDefaultValue} PRODUCT_DOMAIN       "clear-code.com"
${DefineDefaultValue} PRODUCT_WEB_SITE     "http://www.clear-code.com/"
${DefineDefaultValue} PRODUCT_WEB_LABEL    "Go to Clear Code Inc."
${DefineDefaultValue} PRODUCT_LANGUAGE     "English"
${DefineDefaultValue} ADMIN_CHECK_DIR      ""
${DefineDefaultValue} PRODUCT_INSTALL_MODE "NORMAL"

${DefineDefaultValue} APP_NAME          "Firefox"
${DefineDefaultValue} APP_MIN_VERSION   "10.0"
${DefineDefaultValue} APP_MAX_VERSION   "99.99"
${DefineDefaultValue} APP_DOWNLOAD_PATH ""
${DefineDefaultValue} APP_EULA_PATH     ""
${DefineDefaultValue} APP_DOWNLOAD_URL  ""
${DefineDefaultValue} APP_EULA_URL      ""
${DefineDefaultValue} APP_APP_HASH      ""
${DefineDefaultValue} APP_INSTALL_MODE  "QUIET"
${DefineDefaultValue} APP_IS_64BIT      "false"
${DefineDefaultValue} APP_CLEANUP_DIRS ""

${DefineDefaultValue} FX_ENABLED_SEARCH_PLUGINS  "*"
${DefineDefaultValue} FX_DISABLED_SEARCH_PLUGINS ""

${DefineDefaultValue} DEFAULT_CLIENT   ""
${DefineDefaultValue} DISABLED_CLIENTS ""
${DefineDefaultValue} INSTALL_ADDONS   ""
${DefineDefaultValue} EXTRA_INSTALLERS ""
${DefineDefaultValue} EXTRA_SHORTCUTS  ""
${DefineDefaultValue} EXTRA_FILES      ""
${DefineDefaultValue} UPDATE_PINNED_SHORTCUTS "false"

${DefineDefaultValue} CLEAN_INSTALL           ""
${DefineDefaultValue} CLEAN_REQUIRED_MESSAGE  ""
${DefineDefaultValue} CLEAN_REQUIRED_TITLE    ""
${DefineDefaultValue} CLEAN_PREFERRED_MESSAGE ""
${DefineDefaultValue} CLEAN_PREFERRED_TITLE   ""

${DefineDefaultValue} FINISH_MESSAGE          ""
${DefineDefaultValue} FINISH_TITLE            ""

${DefineDefaultValue} CONFIRM_RESTART_MESSAGE ""
${DefineDefaultValue} CONFIRM_RESTART_TITLE   ""


!ifndef APP_EXE
!if ${APP_NAME} == "Firefox"
  !define APP_EXE "firefox.exe"
  !define APP_FULL_NAME "Mozilla Firefox"
  !define APP_KEY "Mozilla\${APP_FULL_NAME}"
  !define APP_KEY_ESR "Mozilla\${APP_FULL_NAME} ESR"
  !define APP_KEY_DEV "Mozilla\${APP_NAME} Developer Edition"
  !define APP_DIRECTORY_NAME "${APP_FULL_NAME}"
  !define APP_PROFILE_PATH "$APPDATA\Mozilla\Firefox"
!else if ${APP_NAME} == "Thunderbird"
  !define APP_EXE "thunderbird.exe"
  !define APP_FULL_NAME "Mozilla Thunderbird"
  !define APP_KEY "Mozilla\${APP_FULL_NAME}"
  !define APP_KEY_ESR "Mozilla\${APP_FULL_NAME}"
  !define APP_KEY_DEV "Mozilla\${APP_FULL_NAME}"
  !define APP_DIRECTORY_NAME "${APP_FULL_NAME}"
  !define APP_PROFILE_PATH "$APPDATA\Thunderbird"
!endif
!endif

${DefineDefaultValue} APP_EXE            "${APP_NAME}.exe"
${DefineDefaultValue} APP_FULL_NAME      "${APP_NAME}"
${DefineDefaultValue} APP_KEY            "${APP_NAME}"
${DefineDefaultValue} APP_KEY_ESR        "${APP_NAME}"
${DefineDefaultValue} APP_KEY_DEV        "${APP_NAME}"
${DefineDefaultValue} APP_DIRECTORY_NAME "${APP_NAME}"

!define INSTALLER_NAME      "fainstall"
!define PRODUCT_UNINST_KEY  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_DIR_REGKEY  "${PRODUCT_UNINST_KEY}\InstalledPath"
!define PRODUCT_UNINST_PATH "$INSTDIR\uninst.exe"

!define CLIENTS_KEY  "Software\Clients"

!define LANG_ENGLISH        "1033"
!define LANG_JAPANESE       "1041"

!define APP_EXTENSIONS_DIR  "$APP_DIR\extensions"
!define APP_DISTRIBUTION_DIR "$APP_DIR\distribution"
!define APP_BUNDLES_DIR      "${APP_DISTRIBUTION_DIR}\bundles"
!define APP_CONFIG_DIR      "$APP_DIR\defaults\pref"

; for backward compatibility
!ifdef PRODUCT_SILENT_INSTALL
  ${DefineDefaultValue} PRODUCT_INSTALL_MODE "QUIET"
!endif
!ifdef APP_SILENT_INSTALL
  ${DefineDefaultValue} APP_INSTALL_MODE "QUIET"
!endif

; fallback to default value
!ifdef PRODUCT_INSTALL_MODE
  !if ${PRODUCT_INSTALL_MODE} == "SILENT"
    !undef PRODUCT_INSTALL_MODE
    !define PRODUCT_INSTALL_MODE "QUIET"
  !else if ${PRODUCT_INSTALL_MODE} != "QUIET"
    !if ${PRODUCT_INSTALL_MODE} != "PASSIVE"
      !if ${PRODUCT_INSTALL_MODE} != "NORMAL"
        !undef PRODUCT_INSTALL_MODE
        !define PRODUCT_INSTALL_MODE "NORMAL"
      !endif
    !endif
  !endif
!else
  !define PRODUCT_INSTALL_MODE "NORMAL"
!endif

!ifdef APP_INSTALL_MODE
  !if ${APP_INSTALL_MODE} == "SILENT"
    !undef APP_INSTALL_MODE
    !define APP_INSTALL_MODE "QUIET"
  !else if ${APP_INSTALL_MODE} != "SKIP"
    !if ${APP_INSTALL_MODE} != "QUIET"
      !if ${APP_INSTALL_MODE} != "NORMAL"
        !undef APP_INSTALL_MODE
        !define APP_INSTALL_MODE "QUIET"
      !endif
    !endif
  !endif
!else
  !define APP_INSTALL_MODE "QUIET"
!endif

!ifdef PRODUCT_LANGUAGE
  !if ${PRODUCT_LANGUAGE} != "English"
    !if ${PRODUCT_LANGUAGE} != "Japanese"
      !undef PRODUCT_LANGUAGE
      !define PRODUCT_LANGUAGE "English"
    !endif
  !endif
!else
  !define PRODUCT_LANGUAGE "English"
!endif


!define INIPATH             "$EXEDIR\${INSTALLER_NAME}.ini"

!define SILENT_INSTALL_OPTIONS "-ms -ira -ispf"
; -ms   : silent install (ignore INI files)

!define SEPARATOR "|"

;=== Program Details
Name    "${PRODUCT_FULL_NAME}"
OutFile "..\${INSTALLER_NAME}.exe"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""

VIProductVersion                 "${PRODUCT_VERSION}"
VIAddVersionKey FileDescription  "${PRODUCT_FULL_NAME}"
VIAddVersionKey LegalCopyright   "${PRODUCT_YEAR} ${PRODUCT_PUBLISHER}"
VIAddVersionKey Comments         ""
VIAddVersionKey CompanyName      "${PRODUCT_PUBLISHER}"
VIAddVersionKey OriginalFilename "${INSTALLER_NAME}.exe"
VIAddVersionKey FileVersion      "${PRODUCT_VERSION}"

;=== Runtime Switches
XPStyle on
CRCCheck on
ShowInstDetails nevershow
ShowUnInstDetails nevershow

;=== Program Icon
Icon "${INSTALLER_NAME}.ico"

;=== Variables
Var DISPLAY_VERSION
Var APP_VERSION
Var APP_REG_KEY
Var APP_VERSIONS_ROOT_REG_KEY
Var NORMALIZED_APP_VERSION
Var APP_VERSION_NUM
Var APP_EXE_PATH
Var APP_EULA_FINAL_PATH
Var APP_INSTALLER_FINAL_PATH
Var APP_DIR
Var APP_INI
Var SHORTCUT_DEFAULT_NAME
Var PROGRAM_FOLDER_DEFAULT_NAME
Var PROGRAM_FOLDER_NAME
Var EXISTS_SHORTCUT_DESKTOP
Var EXISTS_SHORTCUT_STARTMENU
Var EXISTS_SHORTCUT_STARTMENU_PROGRAM
Var EXISTS_SHORTCUT_QUICKLAUNCH
Var SHORTCUT_PATH_DESKTOP
Var SHORTCUT_PATH_STARTMENU
Var SHORTCUT_PATH_STARTMENU_PROGRAM
Var SHORTCUT_PATH_QUICKLAUNCH
Var APP_INSTALLER_PATH
Var APP_INSTALLER_INI
Var APP_EXISTS
Var APP_INSTALLED
Var NORMALIZED_VERSION
Var APP_MAX_VERSION
Var APP_MIN_VERSION
Var APP_ALLOW_DOWNGRADE
Var APP_EULA_DL_FAILED
Var APP_WRONG_VERSION
Var APP_IS_64BIT
Var APP_PROGRAMFILES

Var PROCESSING_FILE
Var RES_DIR
Var DIST_DIR
Var DIST_PATH
Var DIST_FILE
Var BACKUP_PATH
Var BACKUP_COUNT
Var INSTALLED_FILE

Var ITEMS_LIST
Var ITEMS_LIST_INDEX
Var ITEM_NAME
Var ITEM_INDEX
Var ITEM_LOCATION
Var ITEM_LOCATION_BASE

Var MANIFEST_PATH
Var MANIFEST_DIR

Var REQUIRED_DIRECTORY
Var CREATED_TOP_REQUIRED_DIRECTORY
Var REQUIRED_DIRECTORIES
Var REQUIRED_DIRECTORY_INDEX

Var COMMAND_STRING

Var SHORTCUT_NAME
Var SHORTCUT_PATH

Var INI_TEMP
Var INI_TEMP2

!define ReadINIStrWithDefault "!insertmacro ReadINIStrWithDefault"
!macro ReadINIStrWithDefault OutVariable File Section Name Default
  StrCpy ${OutVariable} "${Default}"
  ${If} ${FileExists} ${File}
    ReadINIStr ${OutVariable} ${File} ${Section} ${Name}
    LogEx::Write "LoadINI: ${Name} = ${OutVariable}"
    ${IfThen} "${OutVariable}" == "" ${|} StrCpy ${OutVariable} "${Default}" ${|}
  ${EndIf}
!macroend

Var APP_DOWNLOAD_PATH
Var APP_DOWNLOAD_URL
Var APP_EULA_PATH
Var APP_EULA_URL
Var APP_HASH
Var APP_ENABLE_CRASH_REPORT

Var FX_ENABLED_SEARCH_PLUGINS
Var FX_DISABLED_SEARCH_PLUGINS
Var SEARCH_PLUGINS_PATH
Var CLEAN_INSTALL

!include "${PRODUCT_LANGUAGE}.nsh"
!if ${PRODUCT_INSTALL_MODE} != "QUIET"
  ;=== MUI: Modern UI
  !include "MUI2.nsh"
  !include "Sections.nsh"

  ; hide the footer "Nullsoft Install System v*.*"
  BrandingText " "

  ; MUI Settings
  !define MUI_ABORTWARNING
  !define MUI_ICON                     "${INSTALLER_NAME}.ico"
  !define MUI_UNICON                   "${INSTALLER_NAME}.ico"
  !define MUI_WELCOMEFINISHPAGE_BITMAP "..\icon\welcome.bmp"
  !define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
  !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
    !define MUI_FINISHPAGE_RUN           "$APP_EXE_PATH"
    !define MUI_FINISHPAGE_RUN_TEXT      $(MSG_APP_RUN_TEXT)
    !define MUI_FINISHPAGE_LINK          "${PRODUCT_WEB_LABEL}"
    !define MUI_FINISHPAGE_LINK_LOCATION "${PRODUCT_WEB_SITE}"
  !endif

  ; MUI Pages

  !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
    !insertmacro MUI_PAGE_WELCOME
    ;!define MUI_LICENSEPAGE_RADIOBUTTONS
    !insertmacro MUI_PAGE_LICENSE "..\resources\COPYING.txt"

    !if ${APP_INSTALL_MODE} != "NORMAL"
      !define MUI_LICENSEPAGE_RADIOBUTTONS
      !if ${APP_INSTALL_MODE} == "QUIET"
        !define MUI_PAGE_CUSTOMFUNCTION_PRE "AppEULAPageCheck"
        !define MUI_PAGE_CUSTOMFUNCTION_SHOW "AppEULAPageSetup"
        !insertmacro MUI_PAGE_LICENSE "dummy.txt"
      !endif
    !endif
  !endif

  !insertmacro MUI_PAGE_INSTFILES

  !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
    !insertmacro MUI_PAGE_FINISH

    ; Uninstaller pages
    !insertmacro MUI_UNPAGE_INSTFILES
  !endif

  !if ${PRODUCT_INSTALL_MODE} == "PASSIVE"
    AutoCloseWindow true
  !endif

  !insertmacro MUI_LANGUAGE "${PRODUCT_LANGUAGE}" #  ${LANG_JAPANESE}

  ;=== MUI end
!endif

;=== MUI sections
!if ${PRODUCT_INSTALL_MODE} == "NORMAL"
  !if ${APP_INSTALL_MODE} == "QUIET"
    Function AppEULAPageCheck
        LogEx::Write "AppEULAPageCheck"
        StrCpy $APP_EULA_DL_FAILED "0"

        Call GetAppPath
        Call CheckAppVersionWithMessage

        ${If} "$APP_EXISTS" == "1"
          LogEx::Write "  EULA does not exist"
          Abort
        ${Else}
          LogEx::Write "  Application does not exist so show EULA"
          StrCpy $APP_EULA_FINAL_PATH "$EXEDIR\EULA"
          ${Unless} ${FileExists} "$APP_EULA_PATH"
            StrCpy $APP_EULA_FINAL_PATH "$RES_DIR\${APP_NAME}-EULA.txt"
          ${EndIf}
          ${Unless} ${FileExists} "$APP_EULA_FINAL_PATH"
            StrCpy $APP_EULA_FINAL_PATH "$APP_EULA_PATH"
          ${EndIf}
          ${If} ${FileExists} "$APP_EULA_FINAL_PATH"
            GoTo EULADownloadDone
          ${Else}
            FindWindow $0 "#32770" "" $HWNDPARENT
            EnableWindow $HWNDPARENT 0
            inetc::get /SILENT /NOCANCEL \
              "$APP_EULA_URL" "$APP_EULA_FINAL_PATH"
            Pop $R0
            EnableWindow $HWNDPARENT 1
            ${Unless} "$R0" == "OK"
              StrCpy $APP_EULA_DL_FAILED "1"
              Abort
            ${EndUnless}
          ${EndIf}
          EULADownloadDone:
          LogEx::Write "  EULA = $APP_EULA_FINAL_PATH"
        ${EndIf}
    FunctionEnd

    Function AppEULAPageSetup
        !insertmacro MUI_HEADER_TEXT $(MSG_APP_EULA_TITLE) $(MSG_APP_EULA_SUBTITLE)
        FindWindow $0 "#32770" "" $HWNDPARENT
        GetDlgItem $0 $0 1000
        CustomLicense::LoadFile "$APP_EULA_FINAL_PATH" $0
    FunctionEnd
  !endif
!endif

Section "Initialize Variables" InitializeVariables
    LogEx::Write "InitializeVariables"

    ${ReadINIStrWithDefault} $APP_IS_64BIT "${INIPATH}" "${INSTALLER_NAME}" "AppIs64bit" "${APP_IS_64BIT}"
    ${If} "$APP_IS_64BIT" == "true"
      StrCpy $APP_PROGRAMFILES "$PROGRAMFILES64"
    ${Else}
      StrCpy $APP_PROGRAMFILES "$PROGRAMFILES32"
    ${EndIf}
    LogEx::Write "  APP_PROGRAMFILES = $APP_PROGRAMFILES"

    !if ${APP_INSTALL_MODE} == "SKIP"
      Call GetAppPath
      Call CheckAppVersion
      ${Unless} "$APP_EXISTS" == "1"
        MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_NOT_INSTALLED_ERROR)" /SD IDOK
        Abort
      ${EndUnless}
    !endif

    SetOutPath $INSTDIR

    ${ReadINIStrWithDefault} $RES_DIR "${INIPATH}" "${INSTALLER_NAME}" "Resources" "resources"
    ${If} "$RES_DIR" == ""
      StrCpy $RES_DIR "$EXEDIR"
    ${Else}
      StrCpy $RES_DIR "$EXEDIR\$RES_DIR"
    ${EndIf}
    LogEx::Write "  resources is $RES_DIR"

    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*${APP_NAME}*setup*.exe" "DetectAppInstallerPath"
    ${If} "$APP_INSTALLER_PATH" == ""
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=*setup*${APP_NAME}*.exe" "DetectAppInstallerPath"
    ${EndIf}
    ${If} "$APP_INSTALLER_PATH" == ""
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=*${APP_NAME}*installer*.exe" "DetectAppInstallerPath"
    ${EndIf}
    ${If} "$APP_INSTALLER_PATH" == ""
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=*installer*${APP_NAME}*.exe" "DetectAppInstallerPath"
    ${EndIf}
    ${If} "$APP_INSTALLER_PATH" == ""
      StrCpy $APP_INSTALLER_PATH "$RES_DIR\${APP_NAME}-setup.exe"
    ${EndIf}

    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*${APP_NAME}*setup*.ini" "DetectAppInstallerIni"
    ${If} "$APP_INSTALLER_INI" == ""
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=*setup*${APP_NAME}*.ini" "DetectAppInstallerIni"
    ${EndIf}
    ${If} "$APP_INSTALLER_INI" == ""
      StrCpy $APP_INSTALLER_INI "$RES_DIR\${APP_NAME}-setup.ini"
    ${EndIf}

    ${ReadINIStrWithDefault} $DISPLAY_VERSION "${INIPATH}" "${INSTALLER_NAME}" "DisplayVersion" "${PRODUCT_VERSION}"
SectionEnd

Function "DetectAppInstallerPath"
    StrCpy $PROCESSING_FILE "$R7"
    StrCpy $APP_INSTALLER_PATH "$RES_DIR\$PROCESSING_FILE"
    StrCpy $0 StopLocate
	Push $0
FunctionEnd

Function "DetectAppInstallerIni"
    StrCpy $PROCESSING_FILE "$R7"
    StrCpy $APP_INSTALLER_INI "$RES_DIR\$PROCESSING_FILE"
    StrCpy $0 StopLocate
	Push $0
FunctionEnd

Section "Cleanup Before Installation" CleanupBeforeInstall
      LogEx::Write "CleanupBeforeInstall"
      ${ReadINIStrWithDefault} $ITEMS_LIST "${INIPATH}" "${INSTALLER_NAME}" "AppCleanupDirs" "${APP_CLEANUP_DIRS}"
      ${Unless} "$ITEMS_LIST" == ""
      StrCpy $ITEMS_LIST_INDEX 0
      ${While} 1 == 1
        IntOp $ITEMS_LIST_INDEX $ITEMS_LIST_INDEX + 1
        ${WordFind} $ITEMS_LIST "${SEPARATOR}" "+$ITEMS_LIST_INDEX" $ITEM_NAME
        ${If} $ITEMS_LIST_INDEX > 1
          ${IfThen} "$ITEM_NAME" == "$ITEMS_LIST" ${|} ${Break} ${|}
        ${EndIf}
        StrCpy $ITEM_LOCATION "$ITEM_NAME"
        Call ResolveItemLocation
        ${If} ${FileExists} "$ITEM_LOCATION\uninstall\helper.exe"
          LogEx::Write "  Running $ITEM_LOCATION\uninstall\helper.exe"
          !insertmacro ExecWaitJob `"$ITEM_LOCATION\uninstall\helper.exe" /S`
        ${EndIf}
        ${EndWhile}
      ${EndUnless}
  SectionEnd

!if ${APP_INSTALL_MODE} != "SKIP"
  Section "Download Application" DownloadApp
      LogEx::Write "DownloadApp"
      Call GetAppPath
      !if ${APP_INSTALL_MODE} == "QUIET"
        Call CheckAppVersion
      !else
        Call CheckAppVersionWithMessage
      !endif

      ${Unless} "$APP_EXISTS" == "1"
        LogEx::Write "  Application not exist so do installation"
        StrCpy $APP_INSTALLER_FINAL_PATH "$APP_INSTALLER_PATH"

        ${IfThen} ${FileExists} "$APP_INSTALLER_FINAL_PATH" ${|} GoTo AppDownloadDone ${|}

        !if ${APP_INSTALL_MODE} == "QUIET"
          !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
            ${If} "$APP_EULA_DL_FAILED" == "1"
              MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_DOWNLOAD_ERROR)" /SD IDOK
              LogEx::Write "  Application's EULA does not exist"
              Abort
            ${EndIf}
          !endif
        !endif

        ${If} "$APP_DOWNLOAD_PATH" != ""
        ${AndIf} ${FileExists} "$APP_DOWNLOAD_PATH"
          StrCpy $APP_INSTALLER_FINAL_PATH "$APP_DOWNLOAD_PATH"
          GoTo AppDownloadDone
        ${EndIf}

        LogEx::Write "  Let's download from the Internet"

        ; overwrite subtitle
        SendMessage $mui.Header.SubText ${WM_SETTEXT} 0 "STR:$(MSG_APP_DOWNLOAD_START)"
        inetc::get \
            /TRANSLATE $(MSG_DL_DOWNLOADING)    \
                       $(MSG_DL_CONNECTIING)    \
                       $(MSG_DL_SECOND)         \
                       $(MSG_DL_MINUTE)         \
                       $(MSG_DL_HOUR)           \
                       $(MSG_DL_PLURAL)         \
                       $(MSG_DL_PROGRESS)       \
                       $(MSG_DL_REMAINING)      \
            "$APP_DOWNLOAD_URL" "$APP_INSTALLER_FINAL_PATH"
        Pop $R0

        ${If} "$R0" != "OK"
          MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_DOWNLOAD_ERROR)" /SD IDOK
          LogEx::Write "  Download failed"
          Abort
        ${EndIf}

        ;; Crypto plug-in 1.1 doesn't work on Windows XP...
        ; Crypto::HashFile "SHA1" "$APP_INSTALLER_FINAL_PATH"
        md5dll::GetMD5File "$APP_INSTALLER_FINAL_PATH"
        Pop $0

        ${If} "$APP_HASH" != ""
        ${AndIf} "$0" != "$APP_HASH"
          MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_HASH_ERROR)" /SD IDOK
          LogEx::Write "  Downloaded file is broken"
          Abort
        ${EndIf}

        AppDownloadDone:
        LogEx::Write "  installer is $APP_INSTALLER_FINAL_PATH"
      ${EndUnless}
  SectionEnd

  Section "Install Application" InstallApp
      Call GetAppPath
      Call CheckAppVersion

      Call CheckShortcutsExistence

      ${Unless} "$APP_EXISTS" == "1"
        LogEx::Write "  Let's run installer"
        ${If} ${FileExists} "$APP_INSTALLER_INI"
          ExecWait '"$APP_INSTALLER_FINAL_PATH" /INI="$APP_INSTALLER_INI"'
        ${Else}
          !if ${APP_INSTALL_MODE} == "QUIET"
            ExecWait '"$APP_INSTALLER_FINAL_PATH" ${SILENT_INSTALL_OPTIONS}'
          !else
            ExecWait '$APP_INSTALLER_FINAL_PATH'
          !endif
        ${EndIf}

        Call GetAppPath
        Call CheckAppVersion

        ${Unless} "$APP_EXISTS" == "1"
          ${If} "$APP_WRONG_VERSION" == "1"
            MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_VERSION_TOO_LOW_ERROR)" /SD IDOK
          ${ElseIf} "$APP_WRONG_VERSION" == "2"
            MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_VERSION_TOO_HIGH_ERROR)" /SD IDOK
          ${Else}
            MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_INSTALL_ERROR)" /SD IDOK
          ${EndIf}
          LogEx::Write "  Version check failed"
          Abort
        ${EndUnless}

        Call UpdateShortcutsExistence

        StrCpy $APP_INSTALLED "1"

        ${If} "$APP_ENABLE_CRASH_REPORT" == "false"
          RMDir /r "${APP_EXTENSIONS_DIR}\talkback@mozilla.org"
        ${EndIf}

        ; overwrite subtitle
        SendMessage $mui.Header.SubText ${WM_SETTEXT} 0 "STR:$(MSG_PRODUCT_INSTALLING)"
      ${EndUnless}

      ${If} "$APP_ENABLE_CRASH_REPORT" == "false"
        ; disable crash reporter for the current user
        WriteRegDWORD HKCU "Software\Mozilla\${APP_NAME}\Crash Reporter" "SubmitCrashReport" 0
        WriteRegDWORD HKCU "Software\Mozilla\${APP_NAME}\Crash Reporter" "Enabled" 0
        ; on Windows 7, vendor part is missing.
        WriteRegDWORD HKCU "Software\${APP_NAME}\Crash Reporter" "SubmitCrashReport" 0
        WriteRegDWORD HKCU "Software\${APP_NAME}\Crash Reporter" "Enabled" 0

        ; disable crash reporter for all users
        WriteRegDWORD HKLM "Software\Mozilla\${APP_NAME}\Crash Reporter" "SubmitCrashReport" 0
        WriteRegDWORD HKLM "Software\Mozilla\${APP_NAME}\Crash Reporter" "Enabled" 0
        ; on Windows 7, vendor part is missing.
        WriteRegDWORD HKLM "Software\${APP_NAME}\Crash Reporter" "SubmitCrashReport" 0
        WriteRegDWORD HKLM "Software\${APP_NAME}\Crash Reporter" "Enabled" 0

        ; this change blocks auto-update of the application itself unexpectedly...
        ; WriteIniStr "$APP_DIR\application.ini" "Crash Reporter" "Enabled" "0"
      ${EndIf}
  SectionEnd
!endif

Function "CheckShortcutsExistence"
    LogEx::Write "CheckShortcutsExistence"

    StrCpy $SHORTCUT_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"
    StrCpy $PROGRAM_FOLDER_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"
    ${If} ${FileExists} "$APP_INSTALLER_INI"
      ReadINIStr $SHORTCUT_NAME "$APP_INSTALLER_INI" "Install" "ShortcutName"
      ReadINIStr $PROGRAM_FOLDER_NAME "$APP_INSTALLER_INI" "Install" "StartMenuDirectoryName"
    ${EndIf}
    ${IfThen} "$SHORTCUT_NAME" == "" ${|} StrCpy $SHORTCUT_NAME "${APP_FULL_NAME}" ${|}
    ${IfThen} "$PROGRAM_FOLDER_NAME" == "" ${|} StrCpy $PROGRAM_FOLDER_NAME "${APP_FULL_NAME}" ${|}

    LogEx::Write "  SHORTCUT_NAME : $SHORTCUT_NAME"
    LogEx::Write "  PROGRAM_FOLDER_NAME : $PROGRAM_FOLDER_NAME"

    SetShellVarContext all
    StrCpy $SHORTCUT_PATH_DESKTOP "$DESKTOP\$SHORTCUT_NAME.lnk"
    ${IfThen} ${FileExists} "$SHORTCUT_PATH_DESKTOP" ${|} StrCpy $EXISTS_SHORTCUT_DESKTOP "1" ${|}

    SetShellVarContext current
    StrCpy $SHORTCUT_PATH_QUICKLAUNCH "$QUICKLAUNCH\$SHORTCUT_NAME.lnk"
    ${IfThen} ${FileExists} "$SHORTCUT_PATH_QUICKLAUNCH" ${|} StrCpy $EXISTS_SHORTCUT_QUICKLAUNCH "1" ${|}

    StrCpy $SHORTCUT_PATH_STARTMENU "$STARTMENU\$SHORTCUT_NAME.lnk"
    ${IfThen} ${FileExists} "$SHORTCUT_PATH_STARTMENU" ${|} StrCpy $EXISTS_SHORTCUT_STARTMENU "1" ${|}

    StrCpy $SHORTCUT_PATH_STARTMENU_PROGRAM "$SMPROGRAMS\$PROGRAM_FOLDER_NAME"
    ${If} ${FileExists} "$SHORTCUT_PATH_STARTMENU_PROGRAM"
    ${OrIf} ${FileExists} "$SHORTCUT_PATH_STARTMENU_PROGRAM\*.*"
      StrCpy $EXISTS_SHORTCUT_STARTMENU_PROGRAM "1"
    ${EndIf}

    LogEx::Write "  EXISTS_SHORTCUT_DESKTOP           : $EXISTS_SHORTCUT_DESKTOP"
    LogEx::Write "  EXISTS_SHORTCUT_STARTMENU         : $EXISTS_SHORTCUT_STARTMENU"
    LogEx::Write "  EXISTS_SHORTCUT_STARTMENU_PROGRAM : $EXISTS_SHORTCUT_STARTMENU_PROGRAM"
    LogEx::Write "  EXISTS_SHORTCUT_QUICKLAUNCH       : $EXISTS_SHORTCUT_QUICKLAUNCH"
FunctionEnd

Function "UpdateShortcutsExistence"
    LogEx::Write "UpdateShortcutsExistence"

    StrCpy $SHORTCUT_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"
    StrCpy $PROGRAM_FOLDER_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"

    ${If} ${FileExists} "$APP_INSTALLER_INI"
      ReadINIStr $1 "$APP_INSTALLER_INI" "Install" "DesktopShortcut"
      LogEx::Write "  DesktopShortcut: $1"
      ${If} "$1" == "false"
        ${If} "$EXISTS_SHORTCUT_DESKTOP" == ""
        ${AndIf} ${FileExists} "$SHORTCUT_PATH_DESKTOP"
          Delete "$SHORTCUT_PATH_DESKTOP"
        ${EndIf}
      ${EndIf}

      ReadINIStr $1 "$APP_INSTALLER_INI" "Install" "StartMenuShortcuts"
      LogEx::Write "  StartMenuShortcuts: $1"
      ${If} "$1" == "false"
        ${If} "$EXISTS_SHORTCUT_STARTMENU" == ""
        ${AndIf} ${FileExists} "$SHORTCUT_PATH_STARTMENU"
          Delete "$SHORTCUT_PATH_STARTMENU"
        ${EndIf}
        ${If} ${FileExists} "$SHORTCUT_PATH_STARTMENU_PROGRAM"
        ${OrIf} ${FileExists} "$SHORTCUT_PATH_STARTMENU_PROGRAM\*.*"
          ${IfThen} "$EXISTS_SHORTCUT_STARTMENU_PROGRAM" == "" ${|} RMDir /r "$SHORTCUT_PATH_STARTMENU_PROGRAM" ${|}
        ${EndIf}
      ${EndIf}

      ReadINIStr $1 "$APP_INSTALLER_INI" "Install" "QuickLaunchShortcutAllUsers"
      ReadINIStr $2 "$APP_INSTALLER_INI" "Install" "QuickLaunchShortcut"
      LogEx::Write "  QuickLaunchShortcutAllUsers: $1"
      ${If} "$1" == "true"
        SetShellVarContext current
        StrCpy $ITEM_LOCATION_BASE "$APPDATA\Microsoft\Internet Explorer\Quick Launch"
        ${WordReplace} "$ITEM_LOCATION_BASE" "$PROFILE" "" "+*" $ITEM_LOCATION_BASE
        ${GetParent} "$PROFILE" $1 ; $1 is parent of "HOME"
        StrCpy $ITEM_LOCATION_BASE "$1\%USERNAME%$ITEM_LOCATION_BASE"
        LogEx::Write "  parent of HOME: $1"
        LogEx::Write "  ITEM_LOCATION_BASE: $ITEM_LOCATION_BASE"
        StrCpy $ITEM_INDEX 0
        ReadINIStr $INI_TEMP "$APP_INSTALLER_INI" "Install" "QuickLaunchShortcut"
        ${Locate} "$1" "/L=D /G=0 /M=*" "UpdateQuickLaunchShortcutForOneUser"
        SetShellVarContext current
      ${ElseIf} "$2" == "false"
        ${If} "$EXISTS_SHORTCUT_QUICKLAUNCH" == ""
        ${AndIf} ${FileExists} "$SHORTCUT_PATH_QUICKLAUNCH"
          Delete "$SHORTCUT_PATH_QUICKLAUNCH"
        ${EndIf}
      ${EndIf}
    ${EndIf}
FunctionEnd

Var USER_NAME
Function "UpdateQuickLaunchShortcutForOneUser"
    LogEx::Write "UpdateQuickLaunchShortcutForOneUser"

    StrCpy $USER_NAME "$R7"
    LogEx::Write "  USER_NAME: $USER_NAME"
    ${WordReplace} "$ITEM_LOCATION_BASE" "%USERNAME%" "$USER_NAME" "+*" $ITEM_LOCATION
    LogEx::Write "  ITEM_LOCATION: $ITEM_LOCATION"

    ${If} "$INI_TEMP" == "false"
      LogEx::Write "  Delete $ITEM_LOCATION\$SHORTCUT_NAME.lnk"
      Delete "$ITEM_LOCATION\$SHORTCUT_NAME.lnk"
    ${Else}
      ${Unless} ${FileExists} "$ITEM_LOCATION\$SHORTCUT_NAME.lnk"
        LogEx::Write "  Create $ITEM_LOCATION\$SHORTCUT_NAME.lnk"
        SetOutPath "$APP_DIR"
        CreateShortCut "$ITEM_LOCATION\$SHORTCUT_NAME.lnk" "$APP_EXE_PATH" "" "$APP_EXE_PATH" 0
      ${EndUnless}
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledQuickLaunchShortcut$ITEM_INDEX" "$ITEM_LOCATION\$SHORTCUT_NAME.lnk"
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndIf}

    Push $USER_NAME ; for ${Locate}
FunctionEnd

Section "Set Default Client" SetDefaultClient
    LogEx::Write "SetDefaultClient"
    ${ReadINIStrWithDefault} $ITEM_NAME "${INIPATH}" "${INSTALLER_NAME}" "DefaultClient" "${DEFAULT_CLIENT}"
    ${Unless} "$ITEM_NAME" == ""
      LogEx::Write "  ITEM_NAME: $ITEM_NAME"

      ReadRegDWORD $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "IconsVisible"
      ${If} $COMMAND_STRING < 1
        LogEx::Write "  Hidden => Visible: $ITEM_NAME"
        ReadRegStr $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "ShowIconsCommand"
        LogEx::Write "  Command: $COMMAND_STRING"
        ${Unless} "$COMMAND_STRING" == ""
          StrCpy $ITEM_LOCATION "$COMMAND_STRING"
          Call ResolveItemLocation
          StrCpy $COMMAND_STRING "$ITEM_LOCATION"
          LogEx::Write "  Running: $COMMAND_STRING"
          ExecWait "$COMMAND_STRING"
          WriteRegDWORD HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "IconsVisible" 1
          WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DefaultClient" "$ITEM_NAME"
          WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DefaultClientShown" "true"
        ${EndUnless}
      ${EndIf}

      ReadRegStr $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "ReinstallCommand"
      ${Unless} "$COMMAND_STRING" == ""
        StrCpy $ITEM_LOCATION "$COMMAND_STRING"
        Call ResolveItemLocation
        StrCpy $COMMAND_STRING "$ITEM_LOCATION"
        LogEx::Write "  Running: $COMMAND_STRING"
        ExecWait "$COMMAND_STRING"

        ; re-installation can re-create shortcuts, so we have to remove them manually
        Call UpdateShortcutsExistence
      ${EndUnless}

      LogEx::Write "  Complete: $ITEM_NAME"
    ${EndUnless}
SectionEnd

Section "Disable Clients" DisableClients
    LogEx::Write "DisableClients"
    StrCpy $ITEM_INDEX 0
    ${ReadINIStrWithDefault} $ITEMS_LIST "${INIPATH}" "${INSTALLER_NAME}" "DisabledClients" "${DISABLED_CLIENTS}"
    ${Unless} "$ITEMS_LIST" == ""
      StrCpy $ITEMS_LIST_INDEX 0
      ${While} 1 == 1
        IntOp $ITEMS_LIST_INDEX $ITEMS_LIST_INDEX + 1
        ${WordFind} $ITEMS_LIST "${SEPARATOR}" "+$ITEMS_LIST_INDEX" $ITEM_NAME
        ${If} $ITEMS_LIST_INDEX > 1
          ${IfThen} "$ITEM_NAME" == "$ITEMS_LIST" ${|} ${Break} ${|}
        ${EndIf}
        Call DisableClient
      ${EndWhile}
    ${EndUnless}
SectionEnd

Function "DisableClient"
    LogEx::Write "DisableClient $ITEM_NAME"

    ReadRegDWORD $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "IconsVisible"
    ${If} $COMMAND_STRING > 0
      LogEx::Write "  Visible => Hidden: $ITEM_NAME"
      ReadRegStr $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "HideIconsCommand"
      LogEx::Write "  Command: $COMMAND_STRING"
      ${Unless} "$COMMAND_STRING" == ""
        StrCpy $ITEM_LOCATION "$COMMAND_STRING"
        Call ResolveItemLocation
        StrCpy $COMMAND_STRING "$ITEM_LOCATION"
        LogEx::Write "  Running: $COMMAND_STRING"
        ExecWait "$COMMAND_STRING"
        WriteRegDWORD HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "IconsVisible" 0
        WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "HiddenClient$ITEM_INDEX" "$ITEM_NAME"
      ${EndUnless}
    ${EndIf}

    ;Push $R0
FunctionEnd

Section "Install Profiles" InstallProfiles
    LogEx::Write "InstallProfiles"

    StrCpy $ITEM_INDEX 0

    ReadINIStr $ITEMS_LIST "${INIPATH}" "profile" "RootPathes"
    ${If} "$ITEMS_LIST" == ""
      ReadINIStr $ITEMS_LIST "${INIPATH}" "profile" "RootPath"
    ${EndIf}
    ${Unless} "$ITEMS_LIST" == ""
      StrCpy $ITEMS_LIST_INDEX 0
      ${While} 1 == 1
        IntOp $ITEMS_LIST_INDEX $ITEMS_LIST_INDEX + 1
        ${WordFind} $ITEMS_LIST "${SEPARATOR}" "+$ITEMS_LIST_INDEX" $ITEM_LOCATION
        ${If} $ITEMS_LIST_INDEX > 1
          ${IfThen} "$ITEM_LOCATION" == "$ITEMS_LIST" ${|} ${Break} ${|}
        ${EndIf}
        Call ResolveItemLocation
        Call InstallProfile
      ${EndWhile}
    ${EndUnless}

    ReadINIStr $ITEMS_LIST "${INIPATH}" "profile" "DefaultRootPathes"
    ${If} "$ITEMS_LIST" == ""
      ReadINIStr $ITEMS_LIST "${INIPATH}" "profile" "DefaultRootPath"
    ${EndIf}
    ${Unless} "$ITEMS_LIST" == ""
      StrCpy $ITEMS_LIST_INDEX 0
      ${While} 1 == 1
        IntOp $ITEMS_LIST_INDEX $ITEMS_LIST_INDEX + 1
        ${WordFind} $ITEMS_LIST "${SEPARATOR}" "+$ITEMS_LIST_INDEX" $ITEM_LOCATION
        ${If} $ITEMS_LIST_INDEX > 1
          ${IfThen} "$ITEM_LOCATION" == "$ITEMS_LIST" ${|} ${Break} ${|}
        ${EndIf}
        Call ResolveItemLocation
        Call InstallProfile
        ${Unless} "$CREATED_TOP_REQUIRED_DIRECTORY" == ""
          WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledDefaultProfiles$ITEM_INDEX" "$CREATED_TOP_REQUIRED_DIRECTORY"
          IntOp $ITEM_INDEX $ITEM_INDEX + 1
        ${EndUnless}
      ${EndWhile}
    ${EndUnless}

    ${If} ${FileExists} "$RES_DIR\profile.zip"
      LogEx::Write "  Install Default Profile"
      StrCpy $DIST_PATH "$APP_DIR\defaults\profile"
      StrCpy $BACKUP_PATH "$DIST_PATH.bakup.0"
      StrCpy $BACKUP_COUNT 0
      ${While} ${FileExists} "$DIST_PATH.bakup.$BACKUP_COUNT"
        IntOp $BACKUP_COUNT $BACKUP_COUNT + 1
        StrCpy $BACKUP_PATH "$DIST_PATH.bakup.$BACKUP_COUNT"
      ${EndWhile}
      Rename "$DIST_PATH" "$BACKUP_PATH"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DefaultProfileBackups$ITEM_INDEX" "$BACKUP_PATH"

      ZipDLL::extractall "$RES_DIR\profile.zip" "$DIST_PATH"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledDefaultProfiles$ITEM_INDEX" "$DIST_PATH"
    ${EndIf}

SectionEnd

Var PROFILE_INDEX
Function "InstallProfile"
    LogEx::Write "InstallProfile: start for $ITEM_LOCATION"

    StrCpy $1 "$ITEM_LOCATION"
    ReadINIStr $INI_TEMP "${INIPATH}" "profile" "Name"
    StrCpy $REQUIRED_DIRECTORY "$ITEM_LOCATION\Profiles\$INI_TEMP"
    Call SetUpRequiredDirectories
    StrCpy $ITEM_LOCATION "$1"

    ReadINIStr $INI_TEMP "$ITEM_LOCATION\profiles.ini" "General" "StartWithLastProfile"
    ${If} "$INI_TEMP" == ""
      LogEx::Write "  CreateProfile: there is no profile"
      ReadINIStr $INI_TEMP "${INIPATH}" "profile" "Name"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "General" "StartWithLastProfile" "1"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile0" "Name" "$INI_TEMP"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile0" "IsRelative" "1"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile0" "Path" "Profiles/$INI_TEMP"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile0" "Default" "1"
    ${Else}
      LogEx::Write "  CreateProfile: profile exists"
      ReadINIStr $INI_TEMP "${INIPATH}" "profile" "Name"

      StrCpy $PROFILE_INDEX 0
      ${While} 1 == 1
        ReadINIStr $INI_TEMP2 "$ITEM_LOCATION\profiles.ini" "Profile$PROFILE_INDEX" "Name"
        ${If} "$INI_TEMP2" == ""
        ${OrIf} "$INI_TEMP2" == "$INI_TEMP"
          ${Break}
        ${EndIf}
        IntOp $PROFILE_INDEX $PROFILE_INDEX + 1
      ${EndWhile}

      ${If} "$INI_TEMP2" == ""
        ; If we create a new profile, we should show the profile manager at the next startup.
        WriteINIStr "$ITEM_LOCATION\profiles.ini" "General" "StartWithLastProfile" "0"
      ${EndIf}

      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile$PROFILE_INDEX" "Name" "$INI_TEMP"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile$PROFILE_INDEX" "IsRelative" "1"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile$PROFILE_INDEX" "Path" "Profiles/$INI_TEMP"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile$PROFILE_INDEX" "Default" "1"
    ${EndIf}

    ${If} ${FileExists} "$RES_DIR\profile.zip"
      ${Unless} ${FileExists} "$ITEM_LOCATION\Profiles\$INI_TEMP"
        ZipDLL::extractall "$RES_DIR\profile.zip" "$ITEM_LOCATION\Profiles\$INI_TEMP"
      ${EndUnless}
    ${EndIf}
FunctionEnd

Section "Install Additional Files" DoInstallAdditionalFiles
  Call InstallAdditionalFiles
SectionEnd

Section "Old Distribution Directory Existence Check" OldDistDirExistenceCheck
    LogEx::Write "OldDistDirExistenceCheck"
    StrCpy $DIST_PATH   "${APP_DISTRIBUTION_DIR}"
    StrCpy $BACKUP_PATH "$DIST_PATH.bakup.0"
    StrCpy $BACKUP_COUNT 0
    LogEx::Write "  install to $DIST_PATH"
    ${While} ${FileExists} "$DIST_PATH.bakup.$BACKUP_COUNT"
      IntOp $BACKUP_COUNT $BACKUP_COUNT + 1
      StrCpy $BACKUP_PATH "$DIST_PATH.bakup.$BACKUP_COUNT"
    ${EndWhile}
    ${If} ${FileExists} "$DIST_PATH"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DistributonCustomizerBackup" "$BACKUP_PATH"
      Rename "$DIST_PATH" "$BACKUP_PATH"
      LogEx::Write "  BACKUP_PATH: $BACKUP_PATH"
    ${EndIf}
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledDistributonCustomizer" "$DIST_PATH"
SectionEnd

Section "Install Add-ons" InstallAddons
    LogEx::Write "InstallAddons"
    StrCpy $ITEM_INDEX 0
    ${ReadINIStrWithDefault} $ITEMS_LIST "${INIPATH}" "${INSTALLER_NAME}" "Addons" "${INSTALL_ADDONS}"
    ${If} "$ITEMS_LIST" == ""
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.xpi" "CollectAddonFiles"
    ${EndIf}
    LogEx::Write "  ADDONS: $ITEMS_LIST"
    ${Unless} "$ITEMS_LIST" == ""
      StrCpy $ITEMS_LIST_INDEX 0
      ${While} 1 == 1
        IntOp $ITEMS_LIST_INDEX $ITEMS_LIST_INDEX + 1
        ${WordFind} $ITEMS_LIST "${SEPARATOR}" "+$ITEMS_LIST_INDEX" $ITEM_NAME
        ${If} $ITEMS_LIST_INDEX > 1
          ${IfThen} "$ITEM_NAME" == "$ITEMS_LIST" ${|} ${Break} ${|}
        ${EndIf}
        Call InstallAddon
      ${EndWhile}
    ${EndUnless}
SectionEnd

Function "CollectAddonFiles"
    LogEx::Write "CollectAddonFiles: $R7"
    ${If} "$ITEMS_LIST" == ""
      StrCpy $ITEMS_LIST "$R7"
    ${Else}
      StrCpy $ITEMS_LIST "$ITEMS_LIST${SEPARATOR}$R7"
    ${EndIf}

    Push $ITEMS_LIST ; for ${Locate}
FunctionEnd

Var ADDON_NAME
Var UNPACK
Var UNINSTALL
Function "InstallAddon"
    LogEx::Write "InstallAddon: install $ITEM_NAME"

    ReadINIStr $ADDON_NAME "${INIPATH}" "$ITEM_NAME" "AddonId"
    ${If} "$ADDON_NAME" == ""
      ${GetBaseName} $ITEM_NAME $ADDON_NAME
      StrCpy $ADDON_NAME "$ADDON_NAME@${PRODUCT_DOMAIN}"
    ${EndIf}

    LogEx::Write "  ADDON_NAME: $ADDON_NAME"

    ReadINIStr $ITEM_LOCATION "${INIPATH}" "$ITEM_NAME" "TargetLocation"
    ${Unless} "$ITEM_LOCATION" == ""
      Call ResolveItemLocation
      StrCpy $ITEM_LOCATION "$ITEM_LOCATION"
    ${Else}
      ; use distribution directory for Firefox/Thunderbird 10 or later.
      ${VersionCompare} "$APP_VERSION_NUM" "10" $0
      ${If} "$0" == "1"
        StrCpy $ITEM_LOCATION "${APP_BUNDLES_DIR}"
      ${Else}
        StrCpy $ITEM_LOCATION "${APP_EXTENSIONS_DIR}"
      ${EndIf}
    ${EndUnless}

    ReadINIStr $UNPACK "${INIPATH}" "$ITEM_NAME" "Unpack"
    ReadINIStr $UNINSTALL "${INIPATH}" "$ITEM_NAME" "Uninstall"

    ${IsFalse} $R0 "$UNPACK"
    ${Unless} "$R0" == "1"
      StrCpy $ITEM_LOCATION "$ITEM_LOCATION\$ADDON_NAME"
      ReadINIStr $INI_TEMP "${INIPATH}" "$ITEM_NAME" "Overwrite"
      ${If} "$INI_TEMP" == "false"
      ${AndIf} ${FileExists} "$ITEM_LOCATION"
      ${AndIf} ${FileExists} "$ITEM_LOCATION\*.*"
        LogEx::Write "  $ADDON_NAME installation is canceled (already installed)"
        GoTo CANCELED
      ${EndIf}
    ${EndUnless}

    SetOutPath $ITEM_LOCATION
    LogEx::Write "  Install to $ITEM_LOCATION"

    ${IsFalse} $R0 "$UNPACK"
    ${If} "$R0" == "1"
      Rename "$RES_DIR\$ITEM_NAME" "$RES_DIR\$ADDON_NAME.xpi"
      CopyFiles /SILENT "$RES_DIR\$ADDON_NAME.xpi" "$ITEM_LOCATION"
      StrCpy $ITEM_LOCATION "$ITEM_LOCATION\$ADDON_NAME.xpi"
    ${Else}
      ZipDLL::extractall "$RES_DIR\$ITEM_NAME" "$ITEM_LOCATION"
      ; AccessControl::GrantOnFile "$ITEM_LOCATION" "(BU)" "GenericRead"
    ${EndIf}

    ; Install the "Managed Storage" manifest for the addon (if one exists)
    ${if} ${FileExists} "$RES_DIR\$ITEM_NAME.ManagedStorage"
      LogEx::Write "  $ADDON_NAME native manifest found (ManagedStorage)"

      StrCpy $MANIFEST_DIR "${APP_DISTRIBUTION_DIR}\ManagedStorage"
      SetOutPath $MANIFEST_DIR

      ; Distribute 'addon.xpi.ManagedStorage' as 'myaddon@clearcode.com.json'
      CopyFiles /SILENT "$RES_DIR\$ITEM_NAME.ManagedStorage" $MANIFEST_DIR
      Rename "$MANIFEST_DIR\$ITEM_NAME.ManagedStorage" "$MANIFEST_DIR\$ADDON_NAME.json"

      ${If} "$UNINSTALL" != "false"
        WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledManagedStorage$ITEM_INDEX" "$MANIFEST_DIR\$ADDON_NAME.json"
      ${EndIf}

      ; For native messaging manifests, the registry key should not be created under
      ; Wow6432Node, even if the app is 32-bit.
      SetRegView 64
      WriteRegStr HKLM "Software\Mozilla\ManagedStorage\$ADDON_NAME" "" "$MANIFEST_DIR\$ADDON_NAME.json"
      SetRegView 32
    ${EndIf}

    ${If} "$UNINSTALL" != "false"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledAddon$ITEM_INDEX" "$ITEM_LOCATION"
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndIf}

    LogEx::Write "  $ADDON_NAME successfully installed"
  CANCELED:
FunctionEnd

Section "Install Shortcuts" InstallShortcuts
    LogEx::Write "InstallShortcuts"
    ${ReadINIStrWithDefault} $ITEMS_LIST "${INIPATH}" "${INSTALLER_NAME}" "Shortcuts" "${EXTRA_SHORTCUTS}"
    StrCpy $ITEM_INDEX 0
    ${Unless} "$ITEMS_LIST" == ""
      StrCpy $ITEMS_LIST_INDEX 0
      ${While} 1 == 1
        IntOp $ITEMS_LIST_INDEX $ITEMS_LIST_INDEX + 1
        ${WordFind} $ITEMS_LIST "${SEPARATOR}" "+$ITEMS_LIST_INDEX" $ITEM_NAME
        ${If} $ITEMS_LIST_INDEX > 1
          ${IfThen} "$ITEM_NAME" == "$ITEMS_LIST" ${|} ${Break} ${|}
        ${EndIf}
        Call InstallShortcut
      ${EndWhile}
    ${EndUnless}
SectionEnd

Var SHORTCUT_OPTIONS
Var UPDATED_SHORTCUT_OPTIONS
Var SHORTCUT_OPTIONS_INDEX
Var SHORTCUT_WORK_PATH
Var SHORTCUT_FINAL_PATH
Var SHORTCUT_ICON_PATH
Var SHORTCUT_ICON_INDEX
Var UPDATE_PINNED_SHORTCUTS
Function "InstallShortcut"
    LogEx::Write "InstallShortcuts: install $ITEM_NAME"

    ReadINIStr $SHORTCUT_NAME "${INIPATH}" "$ITEM_NAME" "Name"

    ReadINIStr $INI_TEMP "${INIPATH}" "$ITEM_NAME" "TargetUser"
    ${If} "$INI_TEMP" == "all"
      SetShellVarContext all
    ${Else}
      SetShellVarContext current
    ${EndIf}

    ReadINIStr $REQUIRED_DIRECTORY "${INIPATH}" "$ITEM_NAME" "TargetLocation"
    Call SetUpRequiredDirectories
    ${Unless} "$CREATED_TOP_REQUIRED_DIRECTORY" == ""
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledShortcut$ITEM_INDEX" "$CREATED_TOP_REQUIRED_DIRECTORY"
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndUnless}

    ReadINIStr $SHORTCUT_OPTIONS "${INIPATH}" "$ITEM_NAME" "Options"
    ${Unless} "$SHORTCUT_OPTIONS" == ""
      StrCpy $UPDATED_SHORTCUT_OPTIONS ""
      StrCpy $SHORTCUT_OPTIONS_INDEX 0
      ${While} 1 == 1
        IntOp $SHORTCUT_OPTIONS_INDEX $SHORTCUT_OPTIONS_INDEX + 1
        ${WordFind} $SHORTCUT_OPTIONS " " "+$SHORTCUT_OPTIONS_INDEX" $ITEM_LOCATION
        ${If} $SHORTCUT_OPTIONS_INDEX > 1
          ${IfThen} "$ITEM_LOCATION" == "$SHORTCUT_OPTIONS" ${|} ${Break} ${|}
        ${EndIf}
        Call ResolveItemLocationBasic
        StrCpy $UPDATED_SHORTCUT_OPTIONS "$UPDATED_SHORTCUT_OPTIONS $ITEM_LOCATION"
      ${EndWhile}
      StrCpy $SHORTCUT_OPTIONS "$UPDATED_SHORTCUT_OPTIONS"
    ${EndUnless}

    ReadINIStr $SHORTCUT_ICON_INDEX "${INIPATH}" "$ITEM_NAME" "IconIndex"

;    ReadINIStr $SHORTCUT_DESCRIPTION "${INIPATH}" "$ITEM_NAME" "Description"

    ReadINIStr $ITEM_LOCATION "${INIPATH}" "$ITEM_NAME" "Path"
    Call ResolveItemLocation
    StrCpy $SHORTCUT_PATH "$ITEM_LOCATION"

    ReadINIStr $ITEM_LOCATION "${INIPATH}" "$ITEM_NAME" "IconPath"
    Call ResolveItemLocation
    StrCpy $SHORTCUT_ICON_PATH "$ITEM_LOCATION"
    ${If} "$SHORTCUT_ICON_PATH" == ""
      StrCpy $SHORTCUT_ICON_PATH "$SHORTCUT_PATH"
    ${EndIf}

    ReadINIStr $ITEM_LOCATION "${INIPATH}" "$ITEM_NAME" "TargetLocation"
    ${If} "$ITEM_LOCATION" == ""
      StrCpy $ITEM_LOCATION "%Desktop%"
    ${EndIf}
    Call ResolveItemLocation
;    SetOutPath $ITEM_LOCATION
    StrCpy $ITEM_LOCATION "$ITEM_LOCATION\$SHORTCUT_NAME.lnk"

    StrCpy $SHORTCUT_WORK_PATH "$SHORTCUT_PATH"
    ${StrStrAdv} $SHORTCUT_WORK_PATH "$SHORTCUT_PATH" "\" "<" "<" "0" "0" "0"
    SetOutPath $SHORTCUT_WORK_PATH
    LogEx::Write "  install to $SHORTCUT_WORK_PATH"

    ${If} "$SHORTCUT_ICON_INDEX" == ""
    ${OrIf} "$SHORTCUT_ICON_INDEX" == "0"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_ICON_PATH" 0
    ${ElseIf} "$SHORTCUT_ICON_INDEX" == "1"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_ICON_PATH" 1
    ${ElseIf} "$SHORTCUT_ICON_INDEX" == "2"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_ICON_PATH" 2
    ${ElseIf} "$SHORTCUT_ICON_INDEX" == "3"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_ICON_PATH" 3
    ${ElseIf} "$SHORTCUT_ICON_INDEX" == "4"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_ICON_PATH" 4
    ${ElseIf} "$SHORTCUT_ICON_INDEX" == "5"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_ICON_PATH" 5
    ${EndIf}

    ; AccessControl::GrantOnFile "$ITEM_LOCATION" "(BU)" "GenericRead"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledShortcut$ITEM_INDEX" "$ITEM_LOCATION"

    SetShellVarContext current

    ${ReadINIStrWithDefault} $UPDATE_PINNED_SHORTCUTS "${INIPATH}" "${INSTALLER_NAME}" "UpdatePinnedShortcuts" "${UPDATE_PINNED_SHORTCUTS}"
    ${Unless} "$UPDATE_PINNED_SHORTCUTS" == "false"
      ; Update shortcut in the start menu shortcut pinned by by the user
      StrCpy $SHORTCUT_FINAL_PATH "$ITEM_LOCATION"
      StrCpy $ITEM_LOCATION "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu\$SHORTCUT_NAME.lnk"
      Call ResolveItemLocation
      StrCpy $SHORTCUT_WORK_PATH "$ITEM_LOCATION"
      ${If} ${FileExists} "$SHORTCUT_WORK_PATH"
        Delete "$SHORTCUT_WORK_PATH"
        ${Unless} "$UPDATE_PINNED_SHORTCUTS" == "delete"
          LogEx::Write "  $SHORTCUT_WORK_PATH => $SHORTCUT_FINAL_PATH"
          CopyFiles /SILENT "$SHORTCUT_FINAL_PATH" "$SHORTCUT_WORK_PATH"
        ${EndUnless}
      ${EndIf}

      ; Update shortcut in the task bar shortcut pinned by by the user
      StrCpy $SHORTCUT_FINAL_PATH "$ITEM_LOCATION"
      StrCpy $ITEM_LOCATION "%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\$SHORTCUT_NAME.lnk"
      Call ResolveItemLocation
      StrCpy $SHORTCUT_WORK_PATH "$ITEM_LOCATION"
      ${If} ${FileExists} "$SHORTCUT_WORK_PATH"
        Delete "$SHORTCUT_WORK_PATH"
        ${Unless} "$UPDATE_PINNED_SHORTCUTS" == "delete"
          LogEx::Write "  $SHORTCUT_WORK_PATH => $SHORTCUT_FINAL_PATH"
          CopyFiles /SILENT "$SHORTCUT_FINAL_PATH" "$SHORTCUT_WORK_PATH"
        ${EndUnless}
      ${EndIf}
    ${EndUnless}

    IntOp $ITEM_INDEX $ITEM_INDEX + 1

    LogEx::Write "  $ITEM_NAME successfully installed"
FunctionEnd

Var INSTALLING_APPLICATION_SPECIFIC_FILES
Section "Install Extra Files" InstallExtraFiles
    LogEx::Write "InstallExtraFiles"
    ; Disable install guard for ExtraFiles=
    StrCpy $INSTALLING_APPLICATION_SPECIFIC_FILES 0
    ${ReadINIStrWithDefault} $ITEMS_LIST "${INIPATH}" "${INSTALLER_NAME}" "ExtraFiles" "${EXTRA_FILES}"
    ${Unless} "$ITEMS_LIST" == ""
      StrCpy $ITEMS_LIST_INDEX 0
      ${While} 1 == 1
        IntOp $ITEMS_LIST_INDEX $ITEMS_LIST_INDEX + 1
        ${WordFind} $ITEMS_LIST "${SEPARATOR}" "+$ITEMS_LIST_INDEX" $ITEM_NAME
        LogEx::Write "  WordFind ITEM_NAME ($ITEM_NAME) in ITEMS_LIST ($ITEMS_LIST)"
        ${If} $ITEMS_LIST_INDEX > 1
          ${IfThen} "$ITEM_NAME" == "$ITEMS_LIST" ${|} ${Break} ${|}
        ${EndIf}
        StrCpy $PROCESSING_FILE "$ITEM_NAME"
        LogEx::Write "  PROCESSING_FILE: $PROCESSING_FILE"
        Call InstallNormalFile
      ${EndWhile}
    ${EndUnless}
    StrCpy $INSTALLING_APPLICATION_SPECIFIC_FILES 1
SectionEnd

Section "Install Extra Installers" InstallExtraInstallers
    LogEx::Write "InstallExtraInstallers"
    ${ReadINIStrWithDefault} $ITEMS_LIST "${INIPATH}" "${INSTALLER_NAME}" "Installers" "${EXTRA_INSTALLERS}"
    ${Unless} "$ITEMS_LIST" == ""
      StrCpy $ITEMS_LIST_INDEX 0
      ${While} 1 == 1
        IntOp $ITEMS_LIST_INDEX $ITEMS_LIST_INDEX + 1
        ${WordFind} $ITEMS_LIST "${SEPARATOR}" "+$ITEMS_LIST_INDEX" $ITEM_NAME
        ${If} $ITEMS_LIST_INDEX > 1
          ${IfThen} "$ITEM_NAME" == "$ITEMS_LIST" ${|} ${Break} ${|}
        ${EndIf}
        Call InstallExtraInstaller
      ${EndWhile}
    ${EndUnless}
SectionEnd

Var EXTRA_INSTALLER_NAME
Var EXTRA_INSTALLER_OPTIONS
Function "InstallExtraInstaller"
    LogEx::Write "InstallExtraInstaller: install $ITEM_NAME"

    ReadINIStr $EXTRA_INSTALLER_NAME "${INIPATH}" "$ITEM_NAME" "Name"
    LogEx::Write "  EXTRA_INSTALLER_NAME from INI: $EXTRA_INSTALLER_NAME"
    ${If} "$EXTRA_INSTALLER_NAME" == ""
      StrCpy $EXTRA_INSTALLER_NAME "$ITEM_NAME"
    ${EndIf}

    ReadINIStr $EXTRA_INSTALLER_OPTIONS "${INIPATH}" "$ITEM_NAME" "Options"
    LogEx::Write "  EXTRA_INSTALLER_OPTIONS from INI: $EXTRA_INSTALLER_OPTIONS"

    ExecWait '"$RES_DIR\$EXTRA_INSTALLER_NAME" $EXTRA_INSTALLER_OPTIONS'

    LogEx::Write "  InstallExtraInstaller: $ITEM_NAME successfully installed"
FunctionEnd

Function InstallAdditionalFiles
    LogEx::Write "InstallAdditionalFiles"
    StrCpy $ITEM_INDEX 0
    StrCpy $INSTALLING_APPLICATION_SPECIFIC_FILES 0

    StrCpy $DIST_DIR "$APP_DIR"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.cfg" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.properties" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=override.ini" "InstallNormalFileForLocate"

    StrCpy $DIST_DIR "$APP_DIR\defaults"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.cer" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.crt" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.pem" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.der" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.cer.override" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.crt.override" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.pem.override" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.der.override" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.permissions" "InstallNormalFileForLocate"

    StrCpy $DIST_DIR "$APP_DIR\defaults\profile"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=bookmarks.html" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.rdf" "InstallNormalFileForLocate"

    StrCpy $DIST_DIR "$APP_DIR\isp"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.xml" "InstallNormalFileForLocate"

    StrCpy $DIST_DIR "${APP_CONFIG_DIR}"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.js" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.jsc" "InstallNormalFileForLocate"

    StrCpy $DIST_DIR "$APP_DIR\chrome"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.css" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.jar" "InstallNormalFileForLocate"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.manifest" "InstallNormalFileForLocate"

    StrCpy $DIST_DIR "$APP_DIR\chrome\icons\default"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.ico" "InstallNormalFileForLocate"

    StrCpy $DIST_DIR "$APP_DIR\components"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.xpt" "InstallNormalFileForLocate"

    StrCpy $DIST_DIR "$APP_DIR\plugins"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.dll" "InstallNormalFileForLocate"

    StrCpy $DIST_DIR "$DESKTOP"
    ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.lnk" "InstallNormalFileForLocate"
  ;  StrCpy $DIST_DIR "$QUICKLAUNCH"
  ;  ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.lnk" "InstallNormalFileForLocate"
  ;  StrCpy $DIST_DIR "$SMPROGRAMS"
  ;  ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.lnk" "InstallNormalFileForLocate"

    StrCpy $INSTALLING_APPLICATION_SPECIFIC_FILES 1

    !if ${APP_NAME} == "Firefox"
      ; Firefox 21 and later, these files must be placed into the "browser" directory. 
      StrCpy $DIST_DIR "$APP_DIR\browser"
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=override.ini" "InstallNormalFileForLocate"

      StrCpy $DIST_DIR "$APP_DIR\browser\defaults\profile"
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=bookmarks.html" "InstallNormalFileForLocate"
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.rdf" "InstallNormalFileForLocate"

      StrCpy $DIST_DIR "$APP_DIR\browser\chrome\icons\default"
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.ico" "InstallNormalFileForLocate"

      StrCpy $DIST_DIR "$APP_DIR\browser\plugins"
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.dll" "InstallNormalFileForLocate"
    !endif
FunctionEnd

Function "InstallNormalFileForLocate"
    StrCpy $PROCESSING_FILE "$R7"
    Call InstallNormalFile
FunctionEnd

Function "InstallNormalFile"
    ReadINIStr $ITEM_LOCATION "${INIPATH}" "$PROCESSING_FILE" "TargetLocation"
    ClearErrors
    ; NOTE: this "ClearErrors" is required to process multiple files by Locate correctly!!!
    ;       otherwise only the first found file will be installed and others are ignored.
    LogEx::Write "InstallNormalFile: installing $PROCESSING_FILE to $ITEM_LOCATION"
    ${Unless} "$ITEM_LOCATION" == ""
      ${If} $INSTALLING_APPLICATION_SPECIFIC_FILES == 1
        ; Don't install normal file twice to the location specified by "TargetLocation".
        LogEx::Write "  block to install $PROCESSING_FILE to $ITEM_LOCATION twice"
        GoTo RETURN
      ${EndIf}
      Call ResolveItemLocation
    ${EndUnless}
    ${If} "$ITEM_LOCATION" == ""
      StrCpy $ITEM_LOCATION "$DIST_DIR"
      LogEx::Write "  fallback to $ITEM_LOCATION"
    ${EndIf}
    StrCpy $DIST_PATH "$ITEM_LOCATION\$PROCESSING_FILE"

    LogEx::Write "  install $PROCESSING_FILE to $DIST_PATH"

    ${If} ${FileExists} "$DIST_PATH"
      StrCpy $BACKUP_PATH "$DIST_PATH.bakup.0"
      StrCpy $BACKUP_COUNT 0
      ${While} ${FileExists} "$DIST_PATH.bakup.$BACKUP_COUNT"
        IntOp $BACKUP_COUNT $BACKUP_COUNT + 1
        StrCpy $BACKUP_PATH "$DIST_PATH.bakup.$BACKUP_COUNT"
      ${EndWhile}
      LogEx::Write "  backup old file as $BACKUP_PATH"
      Rename "$DIST_PATH" "$BACKUP_PATH"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$ITEM_INDEXBackup" "$BACKUP_PATH"
    ${EndIf}

    SetOutPath $ITEM_LOCATION

    CopyFiles /SILENT "$RES_DIR\$PROCESSING_FILE" "$DIST_PATH"
    ; AccessControl::GrantOnFile "$DIST_PATH" "(BU)" "GenericRead"
    ${If} $ITEM_INDEX > -1
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$ITEM_INDEX" "$DIST_PATH"
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndIf}

    LogEx::Write "  $PROCESSING_FILE is successfully installed"

  RETURN:
    Push $PROCESSING_FILE ; for ${Locate}
FunctionEnd

Section "Initialize Search Plugins" InitSearchPlugins
    LogEx::Write "InitSearchPlugins"
    StrCpy $DIST_PATH "$APP_DIR\browser\searchplugins"
    ${Unless} ${FileExists} "$DIST_PATH"
      StrCpy $DIST_PATH "$APP_DIR\searchplugins"
    ${EndUnless}

    StrCpy $BACKUP_PATH "$DIST_PATH.bakup.0"
    StrCpy $BACKUP_COUNT 0
    LogEx::Write "  install to $DIST_PATH"
    ${While} ${FileExists} "$DIST_PATH.bakup.$BACKUP_COUNT"
      IntOp $BACKUP_COUNT $BACKUP_COUNT + 1
      StrCpy $BACKUP_PATH "$DIST_PATH.bakup.$BACKUP_COUNT"
    ${EndWhile}

    CreateDirectory "$BACKUP_PATH"
    LogEx::Write "  BACKUP_PATH = $BACKUP_PATH"

    ${If} "$FX_ENABLED_SEARCH_PLUGINS" != ""
    ${AndIf} "$FX_ENABLED_SEARCH_PLUGINS" != "*"
      ${Locate} "$DIST_PATH" "/L=F /G=0 /M=*.xml" "CheckDisableSearchPlugin"
    ${EndIf}
    ${If} "$FX_DISABLED_SEARCH_PLUGINS" == "*"
    ${OrIf} "$FX_DISABLED_SEARCH_PLUGINS" != ""
      ${Locate} "$DIST_PATH" "/L=F /G=0 /M=*.xml" "CheckDisableSearchPlugin"
    ${EndIf}

    ${If} ${FileExists} "$BACKUP_PATH\*.xml"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisabledSearchPlugins" "$BACKUP_PATH"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "EnabledSearchPlugins" "$DIST_PATH"
    ${Else}
      RMDir /r "$BACKUP_PATH"
    ${EndIf}

    ; install additional engines
    StrCpy $DIST_DIR "$APP_DIR\searchplugins"
    ${If} ${FileExists} "$RES_DIR\*.xml"
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=*.xml" "InstallNormalFileForLocate"
    ${EndIf}
SectionEnd

Function "CheckDisableSearchPlugin"
    LogEx::Write "CheckDisableSearchPlugin"
    StrCpy $PROCESSING_FILE "$R7"

    ${Unless} "$FX_ENABLED_SEARCH_PLUGINS" == "*"
      ${WordFind} "$FX_ENABLED_SEARCH_PLUGINS" "$PROCESSING_FILE" "E+1{" $R0
      IfErrors NOTFOUND_IN_ENABLED FOUND_IN_ENABLED
      FOUND_IN_ENABLED:
        GoTo RETURN
      NOTFOUND_IN_ENABLED:
        GoTo DISABLE_SEARCH_PLUGIN
    ${EndUnless}

    ${Switch} "$FX_DISABLED_SEARCH_PLUGINS"
      ${Case} "*"
        GoTo DISABLE_SEARCH_PLUGIN

      ${Case} ""
        GoTo RETURN

      ${Default}
        ${WordFind} "$FX_ENABLED_SEARCH_PLUGINS" "$PROCESSING_FILE" "E+1{" $R0
        IfErrors NOTFOUND_IN_DISABLED FOUND_IN_DISABLED
        FOUND_IN_DISABLED:
          GoTo DISABLE_SEARCH_PLUGIN
        NOTFOUND_IN_DISABLED:
          GoTo RETURN
    ${EndSwitch}

  DISABLE_SEARCH_PLUGIN:
    LogEx::Write "  $DIST_PATH\$PROCESSING_FILE to $BACKUP_PATH\$PROCESSING_FILE"
    Rename "$DIST_PATH\$PROCESSING_FILE" "$BACKUP_PATH\$PROCESSING_FILE"
  RETURN:

    Push $PROCESSING_FILE ; for ${Locate}
FunctionEnd

Section "Initialize Distribution Customizer" InitDistributonCustomizer
    LogEx::Write "InitDistributonCustomizer"
    StrCpy $DIST_PATH   "${APP_DISTRIBUTION_DIR}"
    StrCpy $DIST_DIR "$DIST_PATH"
    ${If} ${FileExists} "$RES_DIR\distribution.*"
    ${OrIf} ${FileExists} "$RES_DIR\policies.json"
      LogEx::Write "  Preparing $DIST_PATH"
      CreateDirectory "$DIST_PATH"
      ; AccessControl::GrantOnFile "$DIST_PATH" "(BU)" "GenericRead"

      ; Set ITEM_INDEX to negative to prevent registeration of the installed file
      ; with an uninstall target, because distribution.* files are automatically
      ; removed with the parent folder stored as "InstalledDistributonCustomizer".
      StrCpy $ITEM_INDEX -1
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=distribution.*" "InstallNormalFileForLocate"
      ${Locate} "$RES_DIR" "/L=F /G=0 /M=policies.json" "InstallNormalFileForLocate"
    ${EndIf}
SectionEnd

Section -Post
    LogEx::Write "Post process"
    WriteUninstaller "${PRODUCT_UNINST_PATH}"
    WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName"     "${PRODUCT_FULL_NAME}"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" "${PRODUCT_UNINST_PATH}"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon"     "${PRODUCT_UNINST_PATH}"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion"  "$DISPLAY_VERSION"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "URLInfoAbout"    "${PRODUCT_WEB_SITE}"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher"       "${PRODUCT_PUBLISHER}"
    ${If} "$APP_INSTALLED" == "1"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledAppRegKey"  "$APP_REG_KEY"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledAppVersionsRootRegKey"  "$APP_VERSIONS_ROOT_REG_KEY"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledAppVersion" "$APP_VERSION"
    ${EndIf}
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "AppIs64bit" "$APP_IS_64BIT"
SectionEnd

Section "Show Finish Message" ShowFinishMessage
    LogEx::Write "ShowFinishMessage"
    ${ReadINIStrWithDefault} $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "FinishMessage" "${FINISH_MESSAGE}"
    ${ReadINIStrWithDefault} $INI_TEMP2 "${INIPATH}" "${INSTALLER_NAME}" "FinishTitle" "${FINISH_TITLE}"
    ${Unless} "$INI_TEMP" == ""
      ${WordReplace} "$INI_TEMP" "\n" "$\n" "+*" $INI_TEMP
      ${If} "$INI_TEMP2" == ""
        MessageBox MB_OK|MB_ICONINFORMATION "$INI_TEMP" /SD IDOK
      ${Else}
        !insertmacro NativeMessageBox ${NATIVE_MB_OK}|${NATIVE_MB_ICONINFORMATION} "$INI_TEMP2" "$INI_TEMP" $0
      ${EndIf}
    ${EndUnless}
SectionEnd

Section "Confirm to Restart" ConfirmRestart
    LogEx::Write "ConfirmRestart"
    ${ReadINIStrWithDefault} $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "ConfirmRestartMessage" "${CONFIRM_RESTART_MESSAGE}"
    ${ReadINIStrWithDefault} $INI_TEMP2 "${INIPATH}" "${INSTALLER_NAME}" "ConfirmRestartTitle" "${CONFIRM_RESTART_TITLE}"
    ${Unless} "$INI_TEMP" == ""
      ${WordReplace} "$INI_TEMP" "\n" "$\n" "+*" $INI_TEMP
      ${If} "$INI_TEMP2" == ""
        MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON1 "$INI_TEMP" IDYES +2
        GoTo RETURN
      ${Else}
        !insertmacro NativeMessageBox ${NATIVE_MB_ICONQUESTION}|${NATIVE_MB_YESNO} "$INI_TEMP2" "$INI_TEMP" $0
        ${Unless} $0 == ${NATIVE_MB_BUTTON_YES}
          GoTo RETURN
        ${EndUnless}
      ${EndIf}
      Reboot
    ${EndUnless}
  RETURN:
SectionEnd

Function .onRebootFailed
    MessageBox MB_OK|MB_ICONSTOP "$(MSG_REQUIRE_RESTART_MANUALLY)" /SD IDOK
FunctionEnd

Var UNINSTALL_FAILED
Section Uninstall
    StrCpy $UNINSTALL_FAILED 0

    ReadRegStr $ITEM_NAME HKLM "${PRODUCT_UNINST_KEY}" "DefaultClientShown"
    ${If} "$ITEM_NAME" == "true"
      ReadRegStr $ITEM_NAME HKLM "${PRODUCT_UNINST_KEY}" "DefaultClient"
      ReadRegStr $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "HideIconsCommand"
      ${Unless} "$COMMAND_STRING" == ""
        StrCpy $ITEM_LOCATION "$COMMAND_STRING"
        Call un.ResolveItemLocation
        StrCpy $COMMAND_STRING "$ITEM_LOCATION"
        ExecWait "$COMMAND_STRING"
        WriteRegDWORD HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "IconsVisible" 0
      ${EndUnless}
    ${EndIf}

    StrCpy $ITEM_INDEX 0
    ${While} 1 == 1
      ReadRegStr $ITEM_NAME HKLM "${PRODUCT_UNINST_KEY}" "HiddenClient$ITEM_INDEX"
      ${IfThen} "$ITEM_NAME" == "" ${|} ${Break} ${|}
      ReadRegStr $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "ShowIconsCommand"
      ${Unless} "$COMMAND_STRING" == ""
        StrCpy $ITEM_LOCATION "$COMMAND_STRING"
        Call un.ResolveItemLocation
        StrCpy $COMMAND_STRING "$ITEM_LOCATION"
        ExecWait "$COMMAND_STRING"
        WriteRegDWORD HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "IconsVisible" 1
      ${EndUnless}
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndWhile}

    StrCpy $ITEM_INDEX 0
    ${While} 1 == 1
      ReadRegStr $INSTALLED_FILE HKLM "${PRODUCT_UNINST_KEY}" "InstalledDefaultProfiles$ITEM_INDEX"
      ${IfThen} "$INSTALLED_FILE" == "" ${|} ${Break} ${|}
      RMDir /r "$INSTALLED_FILE"
      ${If} ${Errors}
      ${AndIf} ${FileExists} "$INSTALLED_FILE"
        StrCpy $UNINSTALL_FAILED 1
      ${Else}
        ReadRegStr $BACKUP_PATH HKLM "${PRODUCT_UNINST_KEY}" "DefaultProfileBackups$ITEM_INDEX"
        ${If} "$BACKUP_PATH" != ""
        ${AndIf} ${FileExists} "$BACKUP_PATH"
          Rename "$BACKUP_PATH" "$INSTALLED_FILE"
        ${EndIf}
      ${EndIf}
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndWhile}

    StrCpy $ITEM_INDEX 0
    ${While} 1 == 1
      ReadRegStr $INSTALLED_FILE HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$ITEM_INDEX"
      ReadRegStr $BACKUP_PATH HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$ITEM_INDEXBackup"
      ${IfThen} "$INSTALLED_FILE" == "" ${|} ${Break} ${|}
      Delete "$INSTALLED_FILE"
      ${If} ${Errors}
      ${AndIf} ${FileExists} "$INSTALLED_FILE"
        StrCpy $UNINSTALL_FAILED 1
        ${Break}
      ${EndIf}
      ${If} "$BACKUP_PATH" != ""
      ${AndIf} ${FileExists} "$BACKUP_PATH"
        Rename "$BACKUP_PATH" "$INSTALLED_FILE"
      ${EndIf}
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndWhile}

    StrCpy $ITEM_INDEX 0
    ${While} 1 == 1
      ReadRegStr $INSTALLED_FILE HKLM "${PRODUCT_UNINST_KEY}" "InstalledShortcut$ITEM_INDEX"
      ${IfThen} "$INSTALLED_FILE" == "" ${|} ${Break} ${|}
      ${If} ${FileExists} "$INSTALLED_FILE"
        ${If} ${FileExists} "$INSTALLED_FILE\*.*"
          RMDir /r "$INSTALLED_FILE"
        ${Else}
          Delete "$INSTALLED_FILE"
        ${EndIf}
        ${If} ${Errors}
        ${AndIf} ${FileExists} "$INSTALLED_FILE"
          StrCpy $UNINSTALL_FAILED 1
          ${Break}
        ${EndIf}
      ${EndIf}
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndWhile}

    StrCpy $ITEM_INDEX 0
    ${While} 1 == 1
      ReadRegStr $INSTALLED_FILE HKLM "${PRODUCT_UNINST_KEY}" "InstalledQuickLaunchShortcut$ITEM_INDEX"
      ${IfThen} "$INSTALLED_FILE" == "" ${|} ${Break} ${|}
      Delete "$INSTALLED_FILE"
      ${If} ${Errors}
      ${AndIf} ${FileExists} "$INSTALLED_FILE"
        StrCpy $UNINSTALL_FAILED 1
        ${Break}
      ${EndIf}
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndWhile}

    StrCpy $ITEM_INDEX 0
    ${While} 1 == 1
      ReadRegStr $ITEM_LOCATION HKLM "${PRODUCT_UNINST_KEY}" "InstalledAddon$ITEM_INDEX"
      ${IfThen} "$ITEM_LOCATION" == "" ${|} ${Break} ${|}

      ${If} ${DirExists} "$ITEM_LOCATION"
        RMDir /r "$ITEM_LOCATION"
      ${ElseIf} ${FileExists} "$ITEM_LOCATION"
        Delete "$ITEM_LOCATION"
      ${EndIf}

      ; Remove the manifest files for the addon, too
      ReadRegStr $MANIFEST_PATH HKLM "${PRODUCT_UNINST_KEY}" "InstalledManagedStorage$ITEM_INDEX"
      ${If} "$MANIFEST_PATH" != ""
      ${AndIf} ${FileExists} "$MANIFEST_PATH"
        Delete "$MANIFEST_PATH"
      ${EndIf}

      ${If} ${Errors}
      ${AndIf} ${FileExists} "$PROCESSING_FILE"
        StrCpy $UNINSTALL_FAILED 1
        ${Break}
      ${EndIf}
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndWhile}

    ; search plugins
    ReadRegStr $BACKUP_PATH HKLM "${PRODUCT_UNINST_KEY}" "DisabledSearchPlugins"
    ReadRegStr $SEARCH_PLUGINS_PATH HKLM "${PRODUCT_UNINST_KEY}" "EnabledSearchPlugins"
    ${If} "$BACKUP_PATH" != ""
    ${AndIf} ${FileExists} "$BACKUP_PATH"
    ${AndIf} ${FileExists} "$BACKUP_PATH\*.xml"
      ${un.Locate} "$BACKUP_PATH" "/L=F /G=0 /M=*.xml" "un.EnableSearchPlugin"
      ${Unless} ${FileExists} "$BACKUP_PATH\*.xml"
        RMDir /r "$BACKUP_PATH"
      ${EndUnless}
    ${EndIf}

    ; distributon customizer
    ReadRegStr $BACKUP_PATH HKLM "${PRODUCT_UNINST_KEY}" "DistributonCustomizerBackup"
    ReadRegStr $INSTALLED_FILE HKLM "${PRODUCT_UNINST_KEY}" "InstalledDistributonCustomizer"
    ${If} "$INSTALLED_FILE" != ""
      RMDir /r "$INSTALLED_FILE"
    ${EndIf}
    ${If} "$BACKUP_PATH" != ""
    ${AndIf} ${FileExists} "$BACKUP_PATH"
    ${AndIf} ${FileExists} "$BACKUP_PATH\*.*"
      Rename "$BACKUP_PATH" "$INSTALLED_FILE"
    ${EndIf}

    RMDir /r "$INSTDIR"
    DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"

    ; remove publisher directory when $PRODUCT_PUBLISHER is empty
    RMDir "$PROGRAMFILES\${PRODUCT_PUBLISHER}"

    ${If} "$UNINSTALL_FAILED" == "1"
      MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_UNINST_ERROR)" /SD IDOK
    ${EndIf}

    SetAutoClose true
SectionEnd

Function "un.EnableSearchPlugin"
    StrCpy $PROCESSING_FILE "$R7"
    Rename "$BACKUP_PATH\$PROCESSING_FILE" "$SEARCH_PLUGINS_PATH\$PROCESSING_FILE"
    Push 0
FunctionEnd

;=== Callback functions
Function .onInit
    StrCpy $INSTDIR "$PROGRAMFILES\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}"
    SetOutPath $INSTDIR

    LogEx::Init "$INSTDIR\install.log"
    LogEx::Write "----------------------onInit------------------------"
    LogEx::Write "Install to $INSTDIR"

    Call CheckAppProc

    Call LoadINI
    Call CheckCleanInstall

    Call CheckAdminPrivilege

    Call CheckInstalled
    !if ${PRODUCT_INSTALL_MODE} == "QUIET"
      SetSilent silent
    !endif
FunctionEnd

Function un.onInit
    Call un.CheckAppProc
    !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
      MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(MSG_UNINST_CONFIRM)" IDYES +2
      Abort
    !else
      SetSilent silent
    !endif
    ReadRegStr $APP_VERSION HKLM "${PRODUCT_UNINST_KEY}" "InstalledAppVersion"

    ; This must be called here, because all registory keys are
    ; already cleared at "onUninstSuccess".
    ${If} "$APP_VERSION" != ""
      Call un.GetCurrentAppVersion
    ${EndIf}
FunctionEnd

Function un.onUninstSuccess
    HideWindow
    !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
      MessageBox MB_ICONINFORMATION|MB_OK "$(MSG_UNINST_SUCCESS)"
    !endif

    ${un.GetParameters} $0
    ${un.GetOptions} "$0" "/AddonOnly" $1
    ;MessageBox MB_ICONINFORMATION|MB_OK "un.onUninstSuccess, APP_VERSION = $APP_VERSION"
    ${If} ${Errors}
    ${AndIf} "$APP_VERSION" != ""
      ;MessageBox MB_ICONINFORMATION|MB_OK "Reading $APP_VERSIONS_ROOT_REG_KEY\$APP_VERSION\Main"
      ${If} "$APP_IS_64BIT" == "true"
        SetRegView 64
      ${EndIf}
      ReadRegStr $APP_DIR HKLM "$APP_VERSIONS_ROOT_REG_KEY\$APP_VERSION\Main" "Install Directory"
      ${If} "$APP_IS_64BIT" == "true"
        SetRegView 32
      ${EndIf}
      ;MessageBox MB_ICONINFORMATION|MB_OK "APP_DIR = $APP_DIR"
      ${IfThen} "$APP_DIR" != "" ${|} call un.UninstallApp ${|}
    ${EndIf}
FunctionEnd

Function un.UninstallApp
    ;MessageBox MB_ICONINFORMATION|MB_OK "Checking $APP_DIR\uninstall\uninstall.log"
    ${If} ${FileExists} "$APP_DIR\uninstall\uninstall.log"
      !if ${APP_INSTALL_MODE} != "SKIP"
        !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
          MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(MSG_UNINST_APP_CONFIRM)" IDYES +2
          GoTo SKIP_APP_UNINSTALLATION
        !endif
        !if ${APP_INSTALL_MODE} == "QUIET"
          ExecWait `"$APP_DIR\uninstall\helper.exe" /S`
        !else
          ExecWait "$APP_DIR\uninstall\helper.exe"
        !endif
      !endif
      SKIP_APP_UNINSTALLATION:
    ${EndIf}
FunctionEnd

;=== Utility functions
Function CheckCleanInstall
  LogEx::Write "CheckCleanInstall"
  ${If} ${FileExists} "${APP_PROFILE_PATH}"
    ${If} "$CLEAN_INSTALL" == "REQUIRED"
      ${ReadINIStrWithDefault} $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "CleanInstallRequiredMessage" "${CLEAN_REQUIRED_MESSAGE}"
      ${WordReplace} "$INI_TEMP" "\n" "$\n" "+*" $INI_TEMP
      ${ReadINIStrWithDefault} $INI_TEMP2 "${INIPATH}" "${INSTALLER_NAME}" "CleanInstallRequiredTitle" "${CLEAN_REQUIRED_TITLE}"
      ${IfThen} "$INI_TEMP" == "" ${|} StrCpy $INI_TEMP "$(MSG_CLEAN_INSTALL_REQUIRED)" ${|}
      ${If} "$INI_TEMP2" == ""
        MessageBox MB_OK|MB_ICONEXCLAMATION "$INI_TEMP" /SD IDOK
      ${Else}
        !insertmacro NativeMessageBox ${NATIVE_MB_OK}|${NATIVE_MB_ICONEXCLAMATION} "$INI_TEMP2" "$INI_TEMP" $0
      ${EndIf}
      Abort
    ${ElseIf} "$CLEAN_INSTALL" == "PREFERRED"
      ${ReadINIStrWithDefault} $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "CleanInstallPreferredMessage" "${CLEAN_PREFERRED_MESSAGE}"
      ${WordReplace} "$INI_TEMP" "\n" "$\n" "+*" $INI_TEMP
      ReadINIStr $INI_TEMP2 "${INIPATH}" "${INSTALLER_NAME}" ""
      ${ReadINIStrWithDefault} $INI_TEMP2 "${INIPATH}" "${INSTALLER_NAME}" "CleanInstallPreferredTitle" "${CLEAN_PREFERRED_TITLE}"
      ${IfThen} "$INI_TEMP" == "" ${|} StrCpy $INI_TEMP "$(MSG_CLEAN_INSTALL_PREFERRED)" ${|}
      ${If} "$INI_TEMP2" == ""
        MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$INI_TEMP" IDYES +2
        Abort
      ${Else}
        !insertmacro NativeMessageBox ${NATIVE_MB_ICONQUESTION}|${NATIVE_MB_YESNO}|${NATIVE_MB_DEFBUTTON2} "$INI_TEMP2" "$INI_TEMP" $0
        ${Unless} $0 == ${NATIVE_MB_BUTTON_YES}
          Abort
        ${EndUnless}
      ${EndIf}
    ${EndIf}
  ${EndIf}
FunctionEnd

Var REQUIRE_ADMIN
Function CheckAdminPrivilege
    LogEx::Write "CheckAdminPrivilege"
    ${ReadINIStrWithDefault} $REQUIRE_ADMIN "${INIPATH}" "${INSTALLER_NAME}" "RequireAdminPrivilege" "${REQUIRE_ADMIN}"
    ${If} "$REQUIRE_ADMIN" == "false"
      GoTo PRIVILEGE_TEST_DONE
    ${EndIf}

    LogEx::Write "  Checking access rights by sid"
    ; check by sid (administrator ends with -500)
    AccessControl::GetCurrentUserName
    Pop $0
    AccessControl::NameToSid $0
    Pop $0
    ${WordFind} $0 "-" "-1" $1
    ${If} $1 == "500"
      GoTo PRIVILEGE_TEST_DONE
    ${EndIf}

    LogEx::Write "  Checking access rights by local group"
    ; check by local group
    UserMgr::GetCurrentUserName
    Pop $0
    UserMgr::IsMemberOfGroup "$0" "Administrators"
    Pop $0
    ${If} "$0" == "TRUE"
      GoTo PRIVILEGE_TEST_DONE
    ${EndIf}

    ; check by file writing
    ${ReadINIStrWithDefault} $ITEM_LOCATION "${INIPATH}" "${INSTALLER_NAME}" "AdminPrivilegeCheckDirectory" "${ADMIN_CHECK_DIR}"
    Call ResolveItemLocation
    ${IfThen} "$ITEM_LOCATION" == "" ${|} StrCpy $ITEM_LOCATION "$APP_PROGRAMFILES" ${|}
    LogEx::Write "  Checking access rights by file access to $ITEM_LOCATION"
    ${Unless} "$ITEM_LOCATION" == ""
      StrCpy $ITEM_LOCATION "$ITEM_LOCATION\_${INSTALLER_NAME}.lock"
      ${If} ${FileExists} "$ITEM_LOCATION"
        Delete "$ITEM_LOCATION"
        ${Unless} ${FileExists} "$ITEM_LOCATION"
          GoTo PRIVILEGE_TEST_DONE
        ${EndUnless}
      ${Else}
        WriteINIStr "$ITEM_LOCATION" "${INSTALLER_NAME}" "test" "true"
        FlushINI "$ITEM_LOCATION"
        ${If} ${FileExists} "$ITEM_LOCATION"
          Delete "$ITEM_LOCATION"
          GoTo PRIVILEGE_TEST_DONE
        ${EndIf}
      ${EndIf}
    ${EndUnless}

    LogEx::Write "  No access rights."
    MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_NOT_ADMIN_ERROR_BEFORE)$ITEM_LOCATION$(MSG_APP_NOT_ADMIN_ERROR_AFTER)" /SD IDOK
    Abort

  PRIVILEGE_TEST_DONE:
FunctionEnd

Function CheckInstalled
    LogEx::Write "CheckInstalled"
    ReadRegStr $R0 HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
    ${Unless} "$R0" == ""
      !if ${APP_INSTALL_MODE} != "SKIP"
        !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
          MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION "$(MSG_ALREADY_INSTALLED)" IDOK UNINST
          Abort
        !endif

      UNINST:
        LogEx::Write "CheckInstalled: Application is installed by meta installer"
        ; If the Firefox/Thunderbird is installed by this meta installer,
        ; then we should keep the state.
        ReadRegStr $APP_VERSION HKLM "${PRODUCT_UNINST_KEY}" "InstalledAppVersion"
        ${IfThen} "$APP_VERSION" != "" ${|} StrCpy $APP_INSTALLED "1" ${|}
        ; Run the uninstaller directly. If we copy the exe file into the
        ; temporary directory, it doesn't work as we expect.
        ExecWait '$R0 /AddonOnly _?=$INSTDIR'
      !endif
    ${EndUnless}
FunctionEnd

Function LoadINI
    LogEx::Write "LoadINI"
    ${ReadINIStrWithDefault} $APP_DOWNLOAD_PATH "${INIPATH}" "${INSTALLER_NAME}" "AppDownloadPath" "${APP_DOWNLOAD_PATH}"
    ${ReadINIStrWithDefault} $APP_EULA_PATH     "${INIPATH}" "${INSTALLER_NAME}" "AppEulaPath"     "${APP_EULA_PATH}"
    ${ReadINIStrWithDefault} $APP_DOWNLOAD_URL  "${INIPATH}" "${INSTALLER_NAME}" "AppDownloadUrl"  "${APP_DOWNLOAD_URL}"
    ${ReadINIStrWithDefault} $APP_EULA_URL      "${INIPATH}" "${INSTALLER_NAME}" "AppEulaUrl"      "${APP_EULA_URL}"
    ${ReadINIStrWithDefault} $APP_HASH          "${INIPATH}" "${INSTALLER_NAME}" "AppHash"         "${APP_HASH}"

    ${ReadINIStrWithDefault} $APP_ENABLE_CRASH_REPORT "${INIPATH}" "${INSTALLER_NAME}" "AppInstallTalkback"   ""
    ${If} "$APP_ENABLE_CRASH_REPORT" == ""
      ${ReadINIStrWithDefault} $APP_ENABLE_CRASH_REPORT "${INIPATH}" "${INSTALLER_NAME}" "AppEnableCrashReport" "true"
    ${EndIf}

    ${ReadINIStrWithDefault} $FX_ENABLED_SEARCH_PLUGINS  "${INIPATH}" "${INSTALLER_NAME}" "FxEnabledSearchPlugins"  "${FX_ENABLED_SEARCH_PLUGINS}"
    ${ReadINIStrWithDefault} $FX_DISABLED_SEARCH_PLUGINS "${INIPATH}" "${INSTALLER_NAME}" "FxDisabledSearchPlugins" "${FX_DISABLED_SEARCH_PLUGINS}"

    !ifdef CLEAN_INSTALL
      StrCpy $CLEAN_INSTALL "${CLEAN_INSTALL}"
    !endif

    ${ReadINIStrWithDefault} $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "CleanInstallPreferredMessage" ""
    ${Unless} $INI_TEMP == ""
      StrCpy $CLEAN_INSTALL "PREFERRED"
    ${EndUnless}

    ${ReadINIStrWithDefault} $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "CleanInstallRequiredMessage" ""
    ${Unless} $INI_TEMP == ""
      StrCpy $CLEAN_INSTALL "REQUIRED"
    ${EndUnless}

FunctionEnd

!macro CheckAppProc un
  Function ${un}CheckAppProc
    FindProcDLL::FindProc "${APP_EXE}" $R0
    ${If} "$R0" == "1"
      MessageBox MB_OK|MB_ICONINFORMATION `$(MSG_APP_IS_RUNNING)`
      Abort
    ${EndIf}
  FunctionEnd
!macroend
!insertmacro CheckAppProc ""
!insertmacro CheckAppProc "un."

Function GetCurrentAppRegKey
  LogEx::Write "GetCurrentAppRegKey"
  ReadINIStr $INI_TEMP ${INIPATH} ${INSTALLER_NAME} "AppIsESR"
  ${If} "$INI_TEMP" == ""
    ReadINIStr $INI_TEMP ${INIPATH} ${INSTALLER_NAME} "AppIsEsr"
  ${EndIf}
  ${If} "$INI_TEMP" == ""
    !ifdef APP_IS_ESR
      StrCpy $INI_TEMP "yes"
    !else
      StrCpy $INI_TEMP "no"
    !endif
  ${EndIf}

  ${IsTrue} $R0 "$INI_TEMP"
  ${If} "$R0" == "1"
    StrCpy $APP_REG_KEY "Software\${APP_KEY_ESR}"
    StrCpy $APP_VERSIONS_ROOT_REG_KEY "Software\${APP_KEY}"
  ${Else}
    ReadINIStr $INI_TEMP ${INIPATH} ${INSTALLER_NAME} "AppIsDevEdition"
    ${If} "$INI_TEMP" == ""
      !ifdef APP_IS_DEV_EDITION
        StrCpy $INI_TEMP "yes"
      !else
        StrCpy $INI_TEMP "no"
      !endif
    ${EndIf}

    ${IsTrue} $R0 "$INI_TEMP"
    ${If} "$R0" == "1"
      StrCpy $APP_REG_KEY "Software\${APP_KEY_DEV}"
      StrCpy $APP_VERSIONS_ROOT_REG_KEY "Software\${APP_KEY_DEV}"
    ${Else}
      StrCpy $APP_REG_KEY "Software\${APP_KEY}"
      StrCpy $APP_VERSIONS_ROOT_REG_KEY "Software\${APP_KEY}"
    ${EndIf}
  ${EndIf}
  LogEx::Write "  APP_REG_KEY:               $APP_REG_KEY"
  LogEx::Write "  APP_VERSIONS_ROOT_REG_KEY: $APP_VERSIONS_ROOT_REG_KEY"
FunctionEnd

Function un.GetCurrentAppRegKey
  ReadRegStr $APP_IS_64BIT HKLM "${PRODUCT_UNINST_KEY}" "AppIs64bit"
  ReadRegStr $APP_REG_KEY HKLM "${PRODUCT_UNINST_KEY}" "InstalledAppRegKey"
  ReadRegStr $APP_VERSIONS_ROOT_REG_KEY HKLM "${PRODUCT_UNINST_KEY}" "InstalledAppVersionsRootRegKey"
FunctionEnd

!macro GetCurrentAppVersion un
  Function ${un}GetCurrentAppVersion
    Call ${un}GetCurrentAppRegKey
    ${If} "$APP_IS_64BIT" == "true"
      SetRegView 64
    ${EndIf}
    ReadRegStr $APP_VERSION HKLM "$APP_REG_KEY" "CurrentVersion"
    ;MessageBox MB_OK|MB_ICONEXCLAMATION "APP_IS_64BIT = $APP_IS_64BIT / APP_REG_KEY = $APP_REG_KEY / APP_VERSION = $APP_VERSION" /SD IDOK
    ${If} "$APP_IS_64BIT" == "true"
      SetRegView 32
    ${EndIf}
  FunctionEnd
!macroend
!insertmacro GetCurrentAppVersion ""
!insertmacro GetCurrentAppVersion "un."

Function GetAppPath
    LogEx::Write "GetAppPath"
    ${IfThen} "$APP_INSTALLED" != "1" ${|} StrCpy $APP_INSTALLED "0" ${|}

    LogEx::Write "  Application installed"

    Call GetCurrentAppVersion
    ${IfThen} "$APP_VERSION" == "" ${|} GoTo ERR ${|}
    StrCpy $0 "$APP_VERSIONS_ROOT_REG_KEY\$APP_VERSION\Main"

    ; EXE path
    ${If} "$APP_IS_64BIT" == "true"
      SetRegView 64
    ${EndIf}
    ReadRegStr $APP_EXE_PATH HKLM $0 "PathToExe"
    ${If} "$APP_IS_64BIT" == "true"
      SetRegView 32
    ${EndIf}
    ${IfThen} "$APP_EXE_PATH" == "" ${|} GoTo ERR ${|}

    LogEx::Write "  APP_EXE_PATH: $APP_EXE_PATH"

    ; Application directory
    ${If} "$APP_IS_64BIT" == "true"
      SetRegView 64
    ${EndIf}
    ReadRegStr $APP_DIR HKLM $0 "Install Directory"
    ${If} "$APP_IS_64BIT" == "true"
      SetRegView 32
    ${EndIf}
    ${IfThen} "$APP_DIR" == "" ${|} GoTo ERR ${|}

    LogEx::Write "  APP_DIR: $APP_DIR"

    ${If} ${FileExists} "$APP_INSTALLER_INI"
      ReadINIStr $INI_TEMP "$APP_INSTALLER_INI" "Install" "InstallDirectoryName"
      LogEx::Write "  InstallDirectoryName: $INI_TEMP"
      ReadINIStr $INI_TEMP2 "$APP_INSTALLER_INI" "Install" "InstallDirectoryPath"
      LogEx::Write "  InstallDirectoryPath: $INI_TEMP2"
      ${If} $INI_TEMP2 != ""
      ${AndIf} $INI_TEMP != ""
        LogEx::Write "  Both InstallDirectoryName and InstallDirectoryPath are specified!!"
        LogEx::Write "  Clearing InstallDirectoryPath to use only InstallDirectoryName."
        StrCpy $INI_TEMP2 ""
      ${EndIf}
      ${If} $INI_TEMP2 != ""
        ${If} "$APP_DIR" != "$INI_TEMP2"
          LogEx::Write "  APP_DIR must be $INI_TEMP2"
          StrCpy $APP_DIR "$INI_TEMP2"
          StrCpy $APP_EXE_PATH "$APP_DIR\${APP_EXE}"
        ${EndIf}
      ${ElseIf} $INI_TEMP != ""
        ${If} "$APP_DIR" != "$APP_PROGRAMFILES\$INI_TEMP"
          LogEx::Write "  APP_DIR must be $APP_PROGRAMFILES\$INI_TEMP"
          StrCpy $APP_DIR "$APP_PROGRAMFILES\$INI_TEMP"
          StrCpy $APP_EXE_PATH "$APP_DIR\${APP_EXE}"
        ${EndIf}
      ${EndIf}
    ${EndIf}

    ${If} ${FileExists} "$APP_EXE_PATH"
      ${If} ${FileExists} "$APP_DIR"
      ${OrIf} ${FileExists} "$APP_DIR\*.*"
        LogEx::Write "  Application exists"
        StrCpy $APP_EXISTS "1"
        ; get actual version number from application.ini because
        ; the version can be mismatched.
        ReadINIStr $APP_VERSION "$APP_DIR\application.ini" "App" "Version"
      ${EndIf}
    ${EndIf}

  ERR:
FunctionEnd

Function CheckAppVersion
    LogEx::Write "CheckAppVersion"
    ; try to remove " (ja)" part
    ${StrStrAdv} $NORMALIZED_APP_VERSION "$APP_VERSION" " " ">" "<" "0" "0" "0"
    ${If} "$NORMALIZED_APP_VERSION" == ""
      StrCpy $NORMALIZED_APP_VERSION "$APP_VERSION"
    ${EndIf}

    LogEx::Write "  APP_VERSION            = $APP_VERSION"
    LogEx::Write "  NORMALIZED_APP_VERSION = $NORMALIZED_APP_VERSION"
    LogEx::Write "  APP_MIN_VERSION        = $APP_MIN_VERSION"
    LogEx::Write "  APP_MAX_VERSION        = $APP_MAX_VERSION"
    LogEx::Write "  APP_ALLOW_DOWNGRADE    = $APP_ALLOW_DOWNGRADE"

    ${VersionConvert} "$NORMALIZED_APP_VERSION" "abcdefghijklmnopqrstuvwxyz" $APP_VERSION_NUM
    StrCpy $APP_WRONG_VERSION "0"

    ${ReadINIStrWithDefault} $APP_ALLOW_DOWNGRADE "${INIPATH}" "${INSTALLER_NAME}" "AppAllowDowngrade" "${APP_ALLOW_DOWNGRADE}"
    ${If} "$APP_ALLOW_DOWNGRADE" == "1"
    ${OrIf} "$APP_ALLOW_DOWNGRADE" == "yes"
      StrCpy $APP_ALLOW_DOWNGRADE "true"
    ${EndIf}

    ${IfThen} "$APP_EXISTS" != "1" ${|} GoTo RETURN ${|}

    LogEx::Write "  Application exists"

    ${ReadINIStrWithDefault} $0 "${INIPATH}" "${INSTALLER_NAME}" "AppMaxVersion" "${APP_MAX_VERSION}"
    ${VersionConvert} "$0" "abcdefghijklmnopqrstuvwxyz" $1
    ${VersionCompare} "$APP_VERSION_NUM" "$1" $0
    ${If} "$0" == "1"
      StrCpy $APP_WRONG_VERSION "2"
      StrCpy $APP_EXISTS "0"
      LogEx::Write "  Installed version is too new"
      GoTo RETURN
    ${EndIf}

    ${ReadINIStrWithDefault} $0 "${INIPATH}" "${INSTALLER_NAME}" "AppMinVersion" "${APP_MIN_VERSION}"
    ${VersionConvert} "$0" "abcdefghijklmnopqrstuvwxyz" $1
    ${VersionCompare} "$APP_VERSION_NUM" "$1" $0
    ${If} "$0" == "2"
      StrCpy $APP_WRONG_VERSION "1"
      StrCpy $APP_EXISTS "0"
      LogEx::Write "  Installed version is too old"
      GoTo RETURN
    ${EndIf}
  RETURN:
FunctionEnd

Function CheckAppVersionWithMessage
    LogEx::Write "CheckAppVersionWithMessage"
    ${IfThen} "$APP_EXISTS" != "1" ${|} GoTo RETURN ${|}

    Call CheckAppVersion

    LogEx::Write "  APP_WRONG_VERSION = $APP_WRONG_VERSION"
    ${Switch} $APP_WRONG_VERSION

      ${Case} 1
        !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
          MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION "$(MSG_APP_VERSION_TOO_LOW_CONFIRM)" IDOK RETURN
          MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_VERSION_TOO_LOW_ERROR)" /SD IDOK
        !else
          GoTo RETURN
        !endif
        Abort
        ${Break}

      ${Case} 2
        ${If} "$APP_ALLOW_DOWNGRADE" == "true"
          !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
            MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION "$(MSG_APP_VERSION_TOO_HIGH_CONFIRM)" IDOK RETURN
          !else
            GoTo RETURN
          !endif
        ${EndIf}
        !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
          MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_VERSION_TOO_HIGH_ERROR)" /SD IDOK
        !endif
        Abort
        ${Break}

    ${EndSwitch}

  RETURN:
FunctionEnd

Function "SetUpRequiredDirectories"
    LogEx::Write "SetUpRequiredDirectories: setup $REQUIRED_DIRECTORY"

    StrCpy $CREATED_TOP_REQUIRED_DIRECTORY ""
    StrCpy $REQUIRED_DIRECTORIES "$REQUIRED_DIRECTORY"

    StrCpy $R0 "$REQUIRED_DIRECTORIES"
    ${While} 1 == 1
      ${GetParent} "$R0" $R1
      ${IfThen} "$R1" == "" ${|} ${Break} ${|}
      StrCpy $REQUIRED_DIRECTORIES "$R1${SEPARATOR}$REQUIRED_DIRECTORIES"
      StrCpy $R0 "$R1"
    ${EndWhile}

    LogEx::Write "  folders = $REQUIRED_DIRECTORIES"

    StrCpy $REQUIRED_DIRECTORY_INDEX 0
    ${While} 1 == 1
      IntOp $REQUIRED_DIRECTORY_INDEX $REQUIRED_DIRECTORY_INDEX + 1
      ${WordFind} $REQUIRED_DIRECTORIES "${SEPARATOR}" "+$REQUIRED_DIRECTORY_INDEX" $REQUIRED_DIRECTORY
      ${If} $REQUIRED_DIRECTORY_INDEX > 1
        ${IfThen} "$REQUIRED_DIRECTORY" == "$REQUIRED_DIRECTORIES" ${|} ${Break} ${|}
      ${EndIf}
      StrCpy $ITEM_LOCATION "$REQUIRED_DIRECTORY"
      Call ResolveItemLocation
      ${If} ${FileExists} "$ITEM_LOCATION"
      ${AndIf} ${FileExists} "$ITEM_LOCATION\*.*"
        ${Continue}
      ${EndIf}
      LogEx::Write "  create $ITEM_LOCATION"
      CreateDirectory "$ITEM_LOCATION"
      ${If} "$CREATED_TOP_REQUIRED_DIRECTORY" == ""
        StrCpy $CREATED_TOP_REQUIRED_DIRECTORY "$ITEM_LOCATION"
        LogEx::Write "  top level = $ITEM_LOCATION"
      ${EndIf}
    ${EndWhile}
FunctionEnd

Function "NormalizePathDelimiter"
  ${StrStrAdv} $0 "$ITEM_LOCATION" "://" ">" "<" "1" "0" "0"
  ; Don't normalize as a local file path, if it is an URI.
  ${If} "$0" == ""
  ${OrIf} "$0" == "://"
    ${WordReplace} "$ITEM_LOCATION" "/" "\" "+*" $ITEM_LOCATION
  ${EndIf}
FunctionEnd

Function "un.NormalizePathDelimiter"
  ${UnStrStrAdv} $0 "$ITEM_LOCATION" "://" ">" "<" "1" "0" "0"
  ; Don't normalize as a local file path, if it is an URI.
  ${If} "$0" == ""
  ${OrIf} "$0" == "://"
    ${un.WordReplace} "$ITEM_LOCATION" "/" "\" "+*" $ITEM_LOCATION
  ${EndIf}
FunctionEnd

!define FillPlaceHolder "!insertmacro FillPlaceHolder"
!macro FillPlaceHolder Name Value
  ${WordReplace} "$ITEM_LOCATION" "%${Name}%" "${Value}" "+*" $ITEM_LOCATION
!macroend

!define un.FillPlaceHolder "!insertmacro un.FillPlaceHolder"
!macro un.FillPlaceHolder Name Value
  ${un.WordReplace} "$ITEM_LOCATION" "%${Name}%" "${Value}" "+*" $ITEM_LOCATION
!macroend

!define FillPlaceHolderWithATerm "!insertmacro FillPlaceHolderWithATerm"
!macro FillPlaceHolderWithATerm Name1 Name2 Name3 Value
    ${FillPlaceHolder} ${Name1} "${Value}"
    ${FillPlaceHolder} ${Name2} "${Value}"
    ${FillPlaceHolder} ${Name3} "${Value}"
!macroend

!define un.FillPlaceHolderWithATerm "!insertmacro un.FillPlaceHolderWithATerm"
!macro un.FillPlaceHolderWithATerm Name1 Name2 Name3 Value
    ${un.FillPlaceHolder} ${Name1} "${Value}"
    ${un.FillPlaceHolder} ${Name2} "${Value}"
    ${un.FillPlaceHolder} ${Name3} "${Value}"
!macroend

!define FillPlaceHolderWithTerms "!insertmacro FillPlaceHolderWithTerms"
!macro FillPlaceHolderWithTerms Name1 Name2 Name3 Name4 Value
    ${FillPlaceHolder} ${Name1} "${Value}"
    ${FillPlaceHolder} ${Name2} "${Value}"
    ${FillPlaceHolder} ${Name3} "${Value}"
    ${FillPlaceHolder} ${Name4} "${Value}"
!macroend

!define un.FillPlaceHolderWithTerms "!insertmacro un.FillPlaceHolderWithTerms"
!macro un.FillPlaceHolderWithTerms Name1 Name2 Name3 Name4 Value
    ${un.FillPlaceHolder} ${Name1} "${Value}"
    ${un.FillPlaceHolder} ${Name2} "${Value}"
    ${un.FillPlaceHolder} ${Name3} "${Value}"
    ${un.FillPlaceHolder} ${Name4} "${Value}"
!macroend

Function "ResolveItemLocation"
    LogEx::Write "ResolveItemLocation for $ITEM_LOCATION"
    Call ResolveItemLocationBasic

    ; Windows Environment Variables
    ${FillPlaceHolderWithTerms} AppData Appdata appdata APPDATA         "$APPDATA"
    ${FillPlaceHolderWithTerms} HomePath Homepath homepath HOMEPATH     "$PROFILE"
    ${FillPlaceHolderWithTerms} HomeDrive Homedrive homedrive HOMEDRIVE "$%homedrive%"
    ${FillPlaceHolderWithTerms} UserName Username username USERNAME     "$%username%"

    Call NormalizePathDelimiter
    LogEx::Write "  => $ITEM_LOCATION"
FunctionEnd

Function "ResolveItemLocationBasic"
    LogEx::Write "ResolveItemLocationBasic for $ITEM_LOCATION"
    ; Windows Environment Variables
    ${FillPlaceHolderWithTerms} SystemDrive Systemdrive systemdrive SYSTEMDRIVE "$%systemdrive%"
    ${FillPlaceHolderWithTerms} SystemRoot Systemroot systemroot SYSTEMROOT "$WINDIR"
    ${FillPlaceHolderWithTerms} WinDir Windir windir WINDIR "$WINDIR"
    ${FillPlaceHolderWithTerms} ProgramFiles Programfiles programfiles PROGRAMFILES "$PROGRAMFILES"
    ${FillPlaceHolderWithTerms} CommonProgramFiles Commonprogramfiles commonprogramfiles COMMONPROGRAMFILES "$%commonprogramfiles%"
    ${FillPlaceHolderWithATerm} Tmp tmp TMP "$TEMP"
    ${FillPlaceHolderWithATerm} Temp temp TEMP "$TEMP"
    ${FillPlaceHolderWithTerms} ComputerName Computername computername COMPUTERNAME "$%computername%"
    ${FillPlaceHolderWithTerms} AllUsersProfile Allusersprofile allusersprofile ALLUSERSPROFILE "$%allusersprofile%"

    ; custom
    ${FillPlaceHolderWithATerm} Home home HOME "$PROFILE"
    ${FillPlaceHolderWithTerms} DeskTop Desktop desktop DESKTOP "$DESKTOP"
    ${FillPlaceHolderWithTerms} AppDir Appdir appdir APPDIR "$APP_DIR"
    ${FillPlaceHolderWithTerms} SysDir Sysdir sysdir SYSDIR "$SYSDIR"
    ${FillPlaceHolderWithTerms} ProgramFiles32 Programfiles32 programfiles32 PROGRAMFILES32 "$PROGRAMFILES32"
    ${FillPlaceHolderWithTerms} ProgramFiles64 Programfiles64 programfiles64 PROGRAMFILES64 "$PROGRAMFILES64"
    ${FillPlaceHolderWithTerms} CommonFiles Commonfiles commonfiles COMMONFILES "$COMMONFILES"
    ${FillPlaceHolderWithTerms} CommonFiles32 Commonfiles32 commonfiles32 COMMONFILES32 "$COMMONFILES32"
    ${FillPlaceHolderWithTerms} CommonFiles64 Commonfiles64 commonfiles64 COMMONFILES64 "$COMMONFILES64"
    ${FillPlaceHolderWithTerms} StartMenu Startmenu startmenu STARTMENU "$STARTMENU"
    ${FillPlaceHolderWithATerm} Programs programs PROGRAMS "$SMPROGRAMS"
    ${FillPlaceHolderWithTerms} Startup StartUp startup STARTUP "$SMSTARTUP"

    Call NormalizePathDelimiter
    LogEx::Write "  => $ITEM_LOCATION"
FunctionEnd

Function "un.ResolveItemLocation"
    Call un.ResolveItemLocationBasic

    ; Windows Environment Variables
    ${un.FillPlaceHolderWithTerms} AppData Appdata appdata APPDATA         "$APPDATA"
    ${un.FillPlaceHolderWithTerms} HomePath Homepath homepath HOMEPATH     "$PROFILE"
    ${un.FillPlaceHolderWithTerms} HomeDrive Homedrive homedrive HOMEDRIVE "$%homedrive%"
    ${un.FillPlaceHolderWithTerms} UserName Username username USERNAME     "$%username%"

    Call un.NormalizePathDelimiter
FunctionEnd

Function "un.ResolveItemLocationBasic"
    ; Windows Environment Variables
    ${un.FillPlaceHolderWithTerms} SystemDrive Systemdrive systemdrive SYSTEMDRIVE "$%systemdrive%"
    ${un.FillPlaceHolderWithTerms} SystemRoot Systemroot systemroot SYSTEMROOT "$WINDIR"
    ${un.FillPlaceHolderWithTerms} WinDir Windir windir WINDIR "$WINDIR"
    ${un.FillPlaceHolderWithTerms} ProgramFiles Programfiles programfiles PROGRAMFILES "$PROGRAMFILES"
    ${un.FillPlaceHolderWithTerms} CommonProgramFiles Commonprogramfiles commonprogramfiles COMMONPROGRAMFILES "$%commonprogramfiles%"
    ${un.FillPlaceHolderWithATerm} Tmp tmp TMP "$TEMP"
    ${un.FillPlaceHolderWithATerm} Temp temp TEMP "$TEMP"
    ${un.FillPlaceHolderWithTerms} ComputerName Computername computername COMPUTERNAME "$%computername%"
    ${un.FillPlaceHolderWithTerms} AllUsersProfile Allusersprofile allusersprofile ALLUSERSPROFILE "$%allusersprofile%"

    ; custom
    ${un.FillPlaceHolderWithATerm} Home home HOME "$PROFILE"
    ${un.FillPlaceHolderWithTerms} DeskTop Desktop desktop DESKTOP "$DESKTOP"
    ${un.FillPlaceHolderWithTerms} AppDir Appdir appdir APPDIR "$APP_DIR"
    ${un.FillPlaceHolderWithTerms} SysDir Sysdir sysdir SYSDIR "$SYSDIR"
    ${un.FillPlaceHolderWithTerms} ProgramFiles32 Programfiles32 programfiles32 PROGRAMFILES32 "$PROGRAMFILES32"
    ${un.FillPlaceHolderWithTerms} ProgramFiles64 Programfiles64 programfiles64 PROGRAMFILES64 "$PROGRAMFILES64"
    ${un.FillPlaceHolderWithTerms} CommonFiles Commonfiles commonfiles COMMONFILES "$COMMONFILES"
    ${un.FillPlaceHolderWithTerms} CommonFiles32 Commonfiles32 commonfiles32 COMMONFILES32 "$COMMONFILES32"
    ${un.FillPlaceHolderWithTerms} CommonFiles64 Commonfiles64 commonfiles64 COMMONFILES64 "$COMMONFILES64"
    ${un.FillPlaceHolderWithTerms} StartMenu Startmenu startmenu STARTMENU "$STARTMENU"
    ${un.FillPlaceHolderWithATerm} Programs programs PROGRAMS "$SMPROGRAMS"
    ${un.FillPlaceHolderWithTerms} Startup StartUp startup STARTUP "$SMSTARTUP"

    Call un.NormalizePathDelimiter
FunctionEnd
