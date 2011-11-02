;Copyright (C) 2008-2011 ClearCode Inc.

;===================== SETUP NSIS-DBG FOR DEBUGGING ================

; See http://nsis.sourceforge.net/Nsisdbg_plug-in for details

!ifdef DEBUG

!define MUI_CUSTOMFUNCTION_GUIINIT myGUIInit

Function myGUIInit
  InitPluginsDir
  nsisdbg::init /NOUNLOAD
  nsisdbg::setoption /NOUNLOAD "notifymsgs" "1"
FunctionEnd

!endif
;===================================================================


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
!include "native_message_box.nsh"


;== Basic Information
!include "..\config.nsh"

!if ${APP_NAME} == "Firefox"
  !define APP_EXE "firefox.exe"
  !define APP_KEY "Mozilla\Mozilla Firefox"
  !define APP_DIRECTORY_NAME "Mozilla Firefox"
  !define APP_PROFILE_PATH "$APPDATA\Mozilla\Firefox"
!else if ${APP_NAME} == "Thunderbird"
  !define APP_EXE "thunderbird.exe"
  !define APP_KEY "Mozilla\Mozilla Thunderbird"
  !define APP_DIRECTORY_NAME "Mozilla Thunderbird"
  !define APP_PROFILE_PATH "$APPDATA\Thunderbird"
!else if ${APP_NAME} == "Netscape"
  !define APP_EXE "Netscp.exe"
  !define APP_KEY "Netscape\Netscape"
  !define APP_DIRECTORY_NAME "Netscape"
  !define APP_PROFILE_PATH "$APPDATA\Mozilla\Netscape"
!endif

!ifndef APP_EXE
  !define APP_EXE "${APP_NAME}.exe"
!endif
!ifndef APP_KEY
  !define APP_KEY "${APP_NAME}"
!endif
!ifndef APP_DIRECTORY_NAME
  !define APP_DIRECTORY_NAME "${APP_NAME}"
!endif

!define INSTALLER_NAME      "fainstall"
!define PRODUCT_UNINST_KEY  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_DIR_REGKEY  "${PRODUCT_UNINST_KEY}\InstalledPath"
!define PRODUCT_UNINST_PATH "$INSTDIR\uninst.exe"

!define CLIENTS_KEY  "Software\Clients"

!define LANG_ENGLISH        "1033"
!define LANG_JAPANESE       "1041"

!define APP_INSTALLER_PATH  "$EXEDIR\resources\${APP_NAME}-setup.exe"
!define APP_INSTALLER_INI   "$EXEDIR\resources\${APP_NAME}-setup.ini"
!define APP_EXTENSIONS_DIR  "$APP_DIR\extensions"
!define APP_CONFIG_DIR      "$APP_DIR\defaults\pref"
!define APP_REG_KEY         "Software\${APP_KEY}"

!ifndef APP_DOWNLOAD_PATH
  !define APP_DOWNLOAD_PATH ""
!endif
!ifndef APP_EULA_PATH
  !define APP_EULA_PATH ""
!endif
!ifndef APP_DOWNLOAD_URL
  !define APP_DOWNLOAD_URL ""
!endif
!ifndef APP_EULA_URL
  !define APP_EULA_URL ""
!endif
!ifndef APP_HASH
  !define APP_HASH ""
!endif

!ifndef FX_ENABLED_SEARCH_PLUGINS
  !define FX_ENABLED_SEARCH_PLUGINS "*"
!endif
!ifndef FX_DISABLED_SEARCH_PLUGINS
  !define FX_DISABLED_SEARCH_PLUGINS ""
!endif

; for backward compatibility
!ifdef PRODUCT_SILENT_INSTALL
  !ifndef PRODUCT_INSTALL_MODE
    !define PRODUCT_INSTALL_MODE "QUIET"
  !endif
!endif
!ifdef APP_SILENT_INSTALL
  !ifndef APP_INSTALL_MODE
    !define APP_INSTALL_MODE "QUIET"
  !endif
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
; -ms   : サイレントインストール（INIを無視）
; -ma   : 自動インストール（進行状況をダイアログで表示、Netscape用）
; -ira  : インストール完了後のアプリケーションの自動起動を無効（Netscape用）
; -ispf : インストール完了後のスタートメニュー内フォルダを開く処理を無効（Netscape用）

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
Var APP_VERSION
Var NORMALIZED_APP_VERSION
Var APP_VERSION_NUM
Var APP_EXE_PATH
Var APP_EULA_FINAL_PATH
Var APP_INSTALLER_FINAL_PATH
Var APP_DIR
Var SHORTCUT_DEFAULT_NAME
Var PROGRAM_FOLDER_DEFAULT_NAME
Var PROGRAM_FOLDER_NAME
!if ${APP_NAME} == "Netscape"
  Var EXISTS_SHORTCUT_DESKTOP
  Var EXISTS_SHORTCUT_DESKTOP_IM
  Var EXISTS_SHORTCUT_DESKTOP_MAIL
  Var EXISTS_SHORTCUT_QUICKLAUNCH
  Var EXISTS_SHORTCUT_QUICKLAUNCH_MAIL
  Var EXISTS_SHORTCUT_STARTMENU
  Var EXISTS_SHORTCUT_STARTMENU_PROGRAM
  Var SHORTCUT_PATH_DESKTOP
  Var SHORTCUT_PATH_DESKTOP_IM
  Var SHORTCUT_PATH_DESKTOP_MAIL
  Var SHORTCUT_PATH_QUICKLAUNCH
  Var SHORTCUT_PATH_QUICKLAUNCH_MAIL
  Var SHORTCUT_PATH_STARTMENU
  Var SHORTCUT_PATH_STARTMENU_PROGRAM
!endif
Var APP_EXISTS
Var APP_INSTALLED
Var NORMALIZED_VERSION
Var APP_MAX_VERSION
Var APP_MIN_VERSION
Var APP_ALLOW_DOWNGRADE
Var APP_EULA_DL_FAILED
Var APP_WRONG_VERSION

Var PROCESSING_FILE
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
    !ifdef NSIS_CONFIG_LOG
      LogText "*** LoadINI: ${Name} = ${OutVariable}"
    !endif
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

!if ${PRODUCT_INSTALL_MODE} != "QUIET"
  ;=== MUI: Modern UI
  !include "MUI2.nsh"
  !include "Sections.nsh"
  !include "${PRODUCT_LANGUAGE}.nsh"

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
        !ifdef NSIS_CONFIG_LOG
          LogSet on
        !endif

        StrCpy $APP_EULA_DL_FAILED "0"

        Call GetAppPath
        Call CheckAppVersionWithMessage

        ${If} "$APP_EXISTS" == "1"
          !ifdef NSIS_CONFIG_LOG
            LogText "*** AppEULAPageCheck: EULA does not exist"
          !endif
          Abort
        ${Else}
          !ifdef NSIS_CONFIG_LOG
            LogText "*** AppEULAPageCheck: Application does not exist so show EULA"
          !endif
          StrCpy $APP_EULA_FINAL_PATH "$EXEDIR\EULA"
          ${If} ${FileExists} "$APP_EULA_PATH"
            StrCpy $APP_EULA_FINAL_PATH "$APP_EULA_PATH"
            GoTo EULADownloadDone
          ${EndIf}
          ${Unless} ${FileExists} "$EXEDIR\EULA"
            FindWindow $0 "#32770" "" $HWNDPARENT
            EnableWindow $HWNDPARENT 0
            InetLoad::load /SILENT " " /NOCANCEL \
                "$APP_EULA_URL" "$APP_EULA_FINAL_PATH"
            Pop $R0
            EnableWindow $HWNDPARENT 1
            ${Unless} "$R0" == "OK"
              StrCpy $APP_EULA_DL_FAILED "1"
              Abort
            ${EndUnless}
          ${EndUnless}
          EULADownloadDone:
          !ifdef NSIS_CONFIG_LOG
            LogText "*** AppEULAPageCheck: EULA = &APP_EULA_FINAL_PATH"
          !endif
        ${EndIf}
    FunctionEnd

    Function AppEULAPageSetup
        !ifdef NSIS_CONFIG_LOG
          LogSet on
        !endif

        !insertmacro MUI_HEADER_TEXT $(MSG_APP_EULA_TITLE) $(MSG_APP_EULA_SUBTITLE)
        FindWindow $0 "#32770" "" $HWNDPARENT
        GetDlgItem $0 $0 1000
        CustomLicense::LoadFile "$APP_EULA_FINAL_PATH" $0
    FunctionEnd
  !endif
!endif

Section "Initialize Variables" InitializeVariables
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif
    !if ${APP_INSTALL_MODE} == "SKIP"
      Call GetAppPath
      Call CheckAppVersion
      ${Unless} "$APP_EXISTS" == "1"
        MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_NOT_INSTALLED_ERROR)" /SD IDOK
        Abort
      ${EndUnless}
    !endif
    StrCpy $INSTDIR "$PROGRAMFILES\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}"
    SetOutPath $INSTDIR
    !ifdef NSIS_CONFIG_LOG
      LogText "*** InitializeVariables: install to $INSTDIR"
    !endif
SectionEnd

!if ${APP_INSTALL_MODE} != "SKIP"
  Section "Download Application" DownloadApp
      !ifdef NSIS_CONFIG_LOG
        LogSet on
      !endif

      Call GetAppPath
      !if ${APP_INSTALL_MODE} == "QUIET"
        Call CheckAppVersion
      !else
        Call CheckAppVersionWithMessage
      !endif

      ${Unless} "$APP_EXISTS" == "1"
        !ifdef NSIS_CONFIG_LOG
          LogText "*** DownloadApp: Application not exist so do installation"
        !endif
        StrCpy $APP_INSTALLER_FINAL_PATH "${APP_INSTALLER_PATH}"

        ${IfThen} ${FileExists} "$APP_INSTALLER_FINAL_PATH" ${|} GoTo AppDownloadDone ${|}

        !if ${APP_INSTALL_MODE} == "QUIET"
          !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
            ${If} "$APP_EULA_DL_FAILED" == "1"
              MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_DOWNLOAD_ERROR)" /SD IDOK
              !ifdef NSIS_CONFIG_LOG
                LogText "*** DownloadApp: Application's EULA does not exist"
              !endif
              Abort
            ${EndIf}
          !endif
        !endif

        ${If} "$APP_DOWNLOAD_PATH" != ""
        ${AndIf} ${FileExists} "$APP_DOWNLOAD_PATH"
          StrCpy $APP_INSTALLER_FINAL_PATH "$APP_DOWNLOAD_PATH"
          GoTo AppDownloadDone
        ${EndIf}

        !ifdef NSIS_CONFIG_LOG
          LogText "*** DownloadApp: Let's download from the Internet"
        !endif

        ; overwrite subtitle
        SendMessage $mui.Header.SubText ${WM_SETTEXT} 0 "STR:$(MSG_APP_DOWNLOAD_START)"
        InetLoad::load \
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
          !ifdef NSIS_CONFIG_LOG
            LogText "*** DownloadApp: Download failed"
          !endif
          Abort
        ${EndIf}

        ;; Crypto plug-in 1.1 doesn't work on Windows XP...
        ; Crypto::HashFile "SHA1" "$APP_INSTALLER_FINAL_PATH"
        md5dll::GetMD5File "$APP_INSTALLER_FINAL_PATH"
        Pop $0

        ${If} "$APP_HASH" != ""
        ${AndIf} "$0" != "$APP_HASH"
          MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_HASH_ERROR)" /SD IDOK
          !ifdef NSIS_CONFIG_LOG
            LogText "*** DownloadApp: Downloaded file is broken"
          !endif
          Abort
        ${EndIf}

        AppDownloadDone:
        !ifdef NSIS_CONFIG_LOG
          LogText "*** DownloadApp: installer is $APP_INSTALLER_FINAL_PATH"
        !endif
      ${EndUnless}
  SectionEnd

  Section "Install Application" InstallApp
      !ifdef NSIS_CONFIG_LOG
        LogSet on
      !endif

      Call GetAppPath
      Call CheckAppVersion

      Call CheckShortcutsExistence

      ${Unless} "$APP_EXISTS" == "1"
        !ifdef NSIS_CONFIG_LOG
          LogText "*** InstallApp: Let's run installer"
        !endif
        ${If} ${FileExists} "${APP_INSTALLER_INI}"
          !if ${APP_NAME} == "Netscape"
            ExecWait '"$APP_INSTALLER_FINAL_PATH" ${SILENT_INSTALL_OPTIONS}'
          !else
            ExecWait '"$APP_INSTALLER_FINAL_PATH" /INI="${APP_INSTALLER_INI}"'
          !endif
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
          !ifdef NSIS_CONFIG_LOG
            LogText "*** InstallApp: Version check failed"
          !endif
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
        ; disable crash reporter for Firefox 3.6
        WriteRegDWORD HKCU "Software\Mozilla\${APP_NAME}\Crash Reporter" "SubmitCrashReport" 0
        ; disable crash reporter for Firefox 4
        WriteRegDWORD HKLM "Software\Mozilla\${APP_NAME}\Crash Reporter" "SubmitCrashReport" 0
      ${EndIf}
  SectionEnd
!endif

Function "CheckShortcutsExistence"
    !ifdef NSIS_CONFIG_LOG
      LogSet on
      LogText "*** CheckShortcutsExistence"
    !endif

    StrCpy $SHORTCUT_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"
    StrCpy $PROGRAM_FOLDER_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"
    ${If} ${FileExists} "${APP_INSTALLER_INI}"
      ReadINIStr $SHORTCUT_NAME "${APP_INSTALLER_INI}" "Install" "ShortcutName"
      ReadINIStr $PROGRAM_FOLDER_NAME "${APP_INSTALLER_INI}" "Install" "StartMenuDirectoryName"
    ${EndIf}
    ${IfThen} "$SHORTCUT_NAME" == "" ${|} StrCpy $SHORTCUT_NAME "$SHORTCUT_DEFAULT_NAME" ${|}
    ${IfThen} "$PROGRAM_FOLDER_NAME" == "" ${|} StrCpy $PROGRAM_FOLDER_NAME "$PROGRAM_FOLDER_DEFAULT_NAME" ${|}

    !ifdef NSIS_CONFIG_LOG
      LogText "*** SHORTCUT_NAME : $SHORTCUT_NAME"
      LogText "*** PROGRAM_FOLDER_NAME : $PROGRAM_FOLDER_NAME"
    !endif

    !if ${APP_NAME} == "Netscape"
      SetShellVarContext all
      StrCpy $SHORTCUT_PATH_DESKTOP "$DESKTOP\$SHORTCUT_NAME.lnk"
      ${IfThen} ${FileExists} "$SHORTCUT_PATH_DESKTOP" ${|} StrCpy $EXISTS_SHORTCUT_DESKTOP "1" ${|}
      StrCpy $SHORTCUT_PATH_DESKTOP_IM "$DESKTOP\Instant Messenger.lnk"
      ${IfThen} ${FileExists} "$SHORTCUT_PATH_DESKTOP_IM" ${|} StrCpy $EXISTS_SHORTCUT_DESKTOP_IM "1" ${|}
      StrCpy $SHORTCUT_PATH_DESKTOP_MAIL "$DESKTOP\Netscape Mail & Newsgroups.lnk"
      ${IfThen} ${FileExists} "$SHORTCUT_PATH_DESKTOP_MAIL" ${|} StrCpy $EXISTS_SHORTCUT_DESKTOP_MAIL "1" ${|}

      StrCpy $SHORTCUT_PATH_STARTMENU "$STARTMENU\$SHORTCUT_NAME.lnk"
      ${IfThen} ${FileExists} "$SHORTCUT_PATH_STARTMENU" ${|} StrCpy $EXISTS_SHORTCUT_STARTMENU "1" ${|}

      StrCpy $SHORTCUT_PATH_STARTMENU_PROGRAM "$SMPROGRAMS\$PROGRAM_FOLDER_NAME"
      ${If} ${FileExists} "$SHORTCUT_PATH_STARTMENU_PROGRAM"
      ${OrIf} ${FileExists} "$SHORTCUT_PATH_STARTMENU_PROGRAM\*.*"
        StrCpy $EXISTS_SHORTCUT_STARTMENU_PROGRAM "1"
      ${EndIf}

      SetShellVarContext current
      StrCpy $SHORTCUT_PATH_QUICKLAUNCH "$QUICKLAUNCH\$SHORTCUT_NAME.lnk"
      ${IfThen} ${FileExists} "$SHORTCUT_PATH_QUICKLAUNCH" ${|} StrCpy $EXISTS_SHORTCUT_QUICKLAUNCH "1" ${|}
      StrCpy $SHORTCUT_PATH_QUICKLAUNCH_MAIL "$QUICKLAUNCH\Netscape Mail & Newsgroups.lnk"
      ${IfThen} ${FileExists} "$SHORTCUT_PATH_QUICKLAUNCH_MAIL" ${|} StrCpy $EXISTS_SHORTCUT_QUICKLAUNCH_MAIL "1" ${|}

      !ifdef NSIS_CONFIG_LOG
        LogText "*** EXISTS_SHORTCUT_DESKTOP           : $EXISTS_SHORTCUT_DESKTOP"
        LogText "*** EXISTS_SHORTCUT_DESKTOP_IM        : $EXISTS_SHORTCUT_DESKTOP_IM"
        LogText "*** EXISTS_SHORTCUT_DESKTOP_MAIL      : $EXISTS_SHORTCUT_DESKTOP_MAIL"
        LogText "*** EXISTS_SHORTCUT_STARTMENU         : $EXISTS_SHORTCUT_STARTMENU"
        LogText "*** EXISTS_SHORTCUT_STARTMENU_PROGRAM : $EXISTS_SHORTCUT_STARTMENU_PROGRAM"
        LogText "*** EXISTS_SHORTCUT_QUICKLAUNCH       : $EXISTS_SHORTCUT_QUICKLAUNCH"
        LogText "*** EXISTS_SHORTCUT_QUICKLAUNCH_MAIL  : $EXISTS_SHORTCUT_QUICKLAUNCH_MAIL"
      !endif
    !endif
FunctionEnd

Function "UpdateShortcutsExistence"
    !ifdef NSIS_CONFIG_LOG
      LogSet on
      LogText "*** UpdateShortcutsExistence"
    !endif

    StrCpy $SHORTCUT_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"
    StrCpy $PROGRAM_FOLDER_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"

    ${If} ${FileExists} "${APP_INSTALLER_INI}"
      !if ${APP_NAME} == "Netscape"
        ReadINIStr $1 "${APP_INSTALLER_INI}" "Install" "DesktopShortcut"
        !ifdef NSIS_CONFIG_LOG
          LogText "*** DesktopShortcut: $1"
        !endif
        ${If} "$1" == "false"
          ${If} "$EXISTS_SHORTCUT_DESKTOP" == ""
          ${AndIf} ${FileExists} "$SHORTCUT_PATH_DESKTOP"
            Delete "$SHORTCUT_PATH_DESKTOP"
          ${EndIf}
          ${If} "$EXISTS_SHORTCUT_DESKTOP_IM" == ""
          ${AndIf} ${FileExists} "$SHORTCUT_PATH_DESKTOP_IM"
            Delete "$SHORTCUT_PATH_DESKTOP_IM"
          ${EndIf}
          ${If} "$EXISTS_SHORTCUT_DESKTOP_MAIL" == ""
          ${AndIf} ${FileExists} "$SHORTCUT_PATH_DESKTOP_MAIL"
            Delete "$SHORTCUT_PATH_DESKTOP_MAIL"
          ${EndIf}
        ${Else}
          SetShellVarContext all
          ${If} ${FileExists} "$DESKTOP\$SHORTCUT_DEFAULT_NAME.lnk"
            Rename "$DESKTOP\$SHORTCUT_DEFAULT_NAME.lnk" "$SHORTCUT_PATH_DESKTOP"
          ${EndIf}
          SetShellVarContext current
        ${EndIf}

        ReadINIStr $1 "${APP_INSTALLER_INI}" "Install" "StartMenuShortcuts"
        !ifdef NSIS_CONFIG_LOG
          LogText "*** StartMenuShortcuts: $1"
        !endif
        ${If} "$1" == "false"
          ${If} "$EXISTS_SHORTCUT_STARTMENU" == ""
          ${AndIf} ${FileExists} "$SHORTCUT_PATH_STARTMENU"
            Delete "$SHORTCUT_PATH_STARTMENU"
          ${EndIf}
          ${If} ${FileExists} "$SHORTCUT_PATH_STARTMENU_PROGRAM"
          ${OrIf} ${FileExists} "$SHORTCUT_PATH_STARTMENU_PROGRAM\*.*"
            ${IfThen} "$EXISTS_SHORTCUT_STARTMENU_PROGRAM" == "" ${|} RMDir /r "$SHORTCUT_PATH_STARTMENU_PROGRAM" ${|}
          ${EndIf}
        ${Else}
          SetShellVarContext all
          ${If} ${FileExists} "$SMPROGRAMS\$PROGRAM_FOLDER_DEFAULT_NAME"
          ${OrIf} ${FileExists} "$SMPROGRAMS\$PROGRAM_FOLDER_DEFAULT_NAME\*.*"
            Rename "$SMPROGRAMS\$PROGRAM_FOLDER_DEFAULT_NAME" "$SHORTCUT_PATH_STARTMENU_PROGRAM"
          ${EndIf}
          SetShellVarContext current
        ${EndIf}
      !endif

      ReadINIStr $1 "${APP_INSTALLER_INI}" "Install" "QuickLaunchShortcutAllUsers"
      !ifdef NSIS_CONFIG_LOG
        LogText "*** QuickLaunchShortcutAllUsers: $1"
      !endif
      ${If} "$1" == "true"
        SetShellVarContext current
        StrCpy $ITEM_LOCATION_BASE "$APPDATA\Microsoft\Internet Explorer\Quick Launch"
        ${WordReplace} "$ITEM_LOCATION_BASE" "$PROFILE" "" "+*" $ITEM_LOCATION_BASE
        ${GetParent} "$PROFILE" $1 ; $1 is parent of "HOME"
        StrCpy $ITEM_LOCATION_BASE "$1\%USERNAME%$ITEM_LOCATION_BASE"
        !ifdef NSIS_CONFIG_LOG
          LogText "*** parent of HOME: $1"
          LogText "*** ITEM_LOCATION_BASE: $ITEM_LOCATION_BASE"
        !endif
        StrCpy $ITEM_INDEX 0
        ReadINIStr $INI_TEMP "${APP_INSTALLER_INI}" "Install" "QuickLaunchShortcut"
        ${Locate} "$1" "/L=D /G=0 /M=*" "UpdateQuickLaunchShortcutForOneUser"
        SetShellVarContext current
    !if ${APP_NAME} == "Netscape"
      ${Else}
        ReadINIStr $1 "${APP_INSTALLER_INI}" "Install" "QuickLaunchShortcut"
        ${If} "$1" == "false"
          ${If} "$EXISTS_SHORTCUT_QUICKLAUNCH" == ""
          ${AndIf} ${FileExists} "$SHORTCUT_PATH_QUICKLAUNCH"
            Delete "$SHORTCUT_PATH_QUICKLAUNCH"
          ${EndIf}
          ${If} "$EXISTS_SHORTCUT_QUICKLAUNCH_MAIL" == ""
          ${AndIf} ${FileExists} "$SHORTCUT_PATH_QUICKLAUNCH_MAIL"
            Delete "$SHORTCUT_PATH_QUICKLAUNCH_MAIL"
          ${EndIf}
        ${Else}
          SetShellVarContext current
          ${If} ${FileExists} "$QUICKLAUNCH\$SHORTCUT_DEFAULT_NAME.lnk"
            Rename "$QUICKLAUNCH\$SHORTCUT_DEFAULT_NAME.lnk" "$SHORTCUT_PATH_QUICKLAUNCH"
          ${EndIf}
        ${EndIf}
    !endif
      ${EndIf}
    ${EndIf}
FunctionEnd

Var USER_NAME
Function "UpdateQuickLaunchShortcutForOneUser"
    !ifdef NSIS_CONFIG_LOG
      LogSet on
      LogText "*** UpdateQuickLaunchShortcutForOneUser"
    !endif

    StrCpy $USER_NAME "$R7"
    !ifdef NSIS_CONFIG_LOG
      LogText "*** USER_NAME: $USER_NAME"
    !endif
    ${WordReplace} "$ITEM_LOCATION_BASE" "%USERNAME%" "$USER_NAME" "+*" $ITEM_LOCATION
    !ifdef NSIS_CONFIG_LOG
      LogText "*** ITEM_LOCATION: $ITEM_LOCATION"
    !endif

    ${If} "$INI_TEMP" == "false"
      Delete "$ITEM_LOCATION\$SHORTCUT_NAME.lnk"
    ${Else}
      ${Unless} ${FileExists} "$ITEM_LOCATION\$SHORTCUT_NAME.lnk"
        SetOutPath "$ITEM_LOCATION"
        CreateShortCut "$ITEM_LOCATION\$SHORTCUT_NAME.lnk" "$APP_EXE_PATH" "" "$APP_EXE_PATH" 0
      ${EndUnless}
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledQuickLaunchShortcut$ITEM_INDEX" "$ITEM_LOCATION\$SHORTCUT_NAME.lnk"
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndIf}

    Push $USER_NAME ; for ${Locate}
FunctionEnd

Section "Set Default Client" SetDefaultClient
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif
    ReadINIStr $ITEM_NAME "${INIPATH}" "${INSTALLER_NAME}" "DefaultClient"
    ${Unless} "$ITEM_NAME" == ""
      !ifdef NSIS_CONFIG_LOG
        LogText "*** SetDefaultClient: $ITEM_NAME"
      !endif

      ReadRegDWORD $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "IconsVisible"
      ${If} $COMMAND_STRING < 1
        !ifdef NSIS_CONFIG_LOG
          LogText "*** Hidden => Visible: $ITEM_NAME"
        !endif
        ReadRegStr $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "ShowIconsCommand"
        !ifdef NSIS_CONFIG_LOG
          LogText "*** Command: $COMMAND_STRING"
        !endif
        ${Unless} "$COMMAND_STRING" == ""
          StrCpy $ITEM_LOCATION "$COMMAND_STRING"
          Call ResolveItemLocation
          StrCpy $COMMAND_STRING "$ITEM_LOCATION"
          ExecWait "$COMMAND_STRING"
          WriteRegDWORD HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "IconsVisible" 1
          WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DefaultClient" "$ITEM_NAME"
          WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DefaultClientShown" "true"
        ${EndUnless}
      ${EndIf}

      ReadRegStr $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "ReinstallCommand"
      ${If} "$COMMAND_STRING" != ""
        StrCpy $ITEM_LOCATION "$COMMAND_STRING"
        Call ResolveItemLocation
        StrCpy $COMMAND_STRING "$ITEM_LOCATION"
        ExecWait "$COMMAND_STRING"
      ${EndIf}

      !ifdef NSIS_CONFIG_LOG
        LogText "*** Complete: $ITEM_NAME"
      !endif
    ${EndUnless}
SectionEnd

Section "Disable Clients" DisableClients
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif
    StrCpy $ITEM_INDEX 0
    ReadINIStr $ITEMS_LIST "${INIPATH}" "${INSTALLER_NAME}" "DisabledClients"
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
    !ifdef NSIS_CONFIG_LOG
      LogSet on
      LogText "*** DisableClient: $ITEM_NAME"
    !endif

    ReadRegDWORD $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "IconsVisible"
    ${If} $COMMAND_STRING > 0
      !ifdef NSIS_CONFIG_LOG
        LogText "*** Visible => Hidden: $ITEM_NAME"
      !endif
      ReadRegStr $COMMAND_STRING HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "HideIconsCommand"
      !ifdef NSIS_CONFIG_LOG
        LogText "*** Command: $COMMAND_STRING"
      !endif
      ${Unless} "$COMMAND_STRING" == ""
        StrCpy $ITEM_LOCATION "$COMMAND_STRING"
        Call ResolveItemLocation
        StrCpy $COMMAND_STRING "$ITEM_LOCATION"
        ExecWait "$COMMAND_STRING"
        WriteRegDWORD HKLM "${CLIENTS_KEY}\$ITEM_NAME\InstallInfo" "IconsVisible" 0
        WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "HiddenClient$ITEM_INDEX" "$ITEM_NAME"
      ${EndUnless}
    ${EndIf}

    ;Push $R0
FunctionEnd

Section "Install Profiles" InstallProfiles
    !ifdef NSIS_CONFIG_LOG
      LogSet on
      LogText "*** InstallProfiles: start"
    !endif

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

    ${If} ${FileExists} "$EXEDIR\resources\profile.zip"
      !ifdef NSIS_CONFIG_LOG
        LogText "*** Install Default Profile"
      !endif
      StrCpy $DIST_PATH "$APP_DIR\defaults\profile"
      StrCpy $BACKUP_PATH "$DIST_PATH.bakup.0"
      StrCpy $BACKUP_COUNT 0
      ${While} ${FileExists} "$DIST_PATH.bakup.$BACKUP_COUNT"
        IntOp $BACKUP_COUNT $BACKUP_COUNT + 1
        StrCpy $BACKUP_PATH "$DIST_PATH.bakup.$BACKUP_COUNT"
      ${EndWhile}
      Rename "$DIST_PATH" "$BACKUP_PATH"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DefaultProfileBackups$ITEM_INDEX" "$BACKUP_PATH"

      ZipDLL::extractall "$EXEDIR\resources\profile.zip" "$DIST_PATH"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledDefaultProfiles$ITEM_INDEX" "$DIST_PATH"
    ${EndIf}

SectionEnd

Var PROFILE_INDEX
Function "InstallProfile"
    !ifdef NSIS_CONFIG_LOG
      LogSet on
      LogText "*** InstallProfile: start for $ITEM_LOCATION"
    !endif

    StrCpy $1 "$ITEM_LOCATION"
    StrCpy $REQUIRED_DIRECTORY "$1\Profiles\$INI_TEMP"
    Call SetUpRequiredDirectories
    StrCpy $ITEM_LOCATION "$1"

    ReadINIStr $INI_TEMP "$ITEM_LOCATION\profiles.ini" "General" "StartWithLastProfile"
    ${If} "$INI_TEMP" == ""
      !ifdef NSIS_CONFIG_LOG
        LogText "*** CreateProfile: there is no profile"
      !endif

      ReadINIStr $INI_TEMP "${INIPATH}" "profile" "Name"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "General" "StartWithLastProfile" "1"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile0" "Name" "$INI_TEMP"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile0" "IsRelative" "1"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile0" "Path" "Profiles/$INI_TEMP"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile0" "Default" "1"

    ${Else}
      !ifdef NSIS_CONFIG_LOG
        LogText "*** CreateProfile: profile exists"
      !endif

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
        ; 新たにプロファイルを追加する場合、次回起動時にはプロファイルマネージャを常に表示する
        WriteINIStr "$ITEM_LOCATION\profiles.ini" "General" "StartWithLastProfile" "0"
      ${EndIf}

      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile$PROFILE_INDEX" "Name" "$INI_TEMP"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile$PROFILE_INDEX" "IsRelative" "1"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile$PROFILE_INDEX" "Path" "Profiles/$INI_TEMP"
      WriteINIStr "$ITEM_LOCATION\profiles.ini" "Profile$PROFILE_INDEX" "Default" "1"

    ${EndIf}

    ${If} ${FileExists} "$EXEDIR\resources\profile.zip"
      ${Unless} ${FileExists} "$ITEM_LOCATION\Profiles\$INI_TEMP"
        ZipDLL::extractall "$EXEDIR\resources\profile.zip" "$ITEM_LOCATION\Profiles\$INI_TEMP"
      ${EndUnless}
    ${EndIf}
FunctionEnd

Section "Install Add-ons" InstallAddons
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif
    StrCpy $ITEM_INDEX 0
    ReadINIStr $ITEMS_LIST "${INIPATH}" "${INSTALLER_NAME}" "Addons"
    ${If} "$ITEMS_LIST" == ""
      ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.xpi" "CollectAddonFiles"
    ${EndIf}
    !ifdef NSIS_CONFIG_LOG
      LogText "*** ADDONS: $ITEMS_LIST"
    !endif
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
    !ifdef NSIS_CONFIG_LOG
      LogSet on
      LogText "*** CollectAddonFiles: $R7"
    !endif
    ${If} "$ITEMS_LIST" == ""
      StrCpy $ITEMS_LIST "$R7"
    ${Else}
      StrCpy $ITEMS_LIST "$ITEMS_LIST${SEPARATOR}$R7"
    ${EndIf}

    Push $ITEMS_LIST ; for ${Locate}
FunctionEnd

Var ADDON_NAME
Function "InstallAddon"
    !ifdef NSIS_CONFIG_LOG
      LogSet on
      LogText "*** InstallAddon: install $ITEM_NAME"
    !endif

    ReadINIStr $ADDON_NAME "${INIPATH}" "$ITEM_NAME" "AddonId"
    ${If} "$ADDON_NAME" == ""
      ${GetBaseName} $ITEM_NAME $ADDON_NAME
      StrCpy $ADDON_NAME "$ADDON_NAME@${PRODUCT_DOMAIN}"
    ${EndIf}

    !ifdef NSIS_CONFIG_LOG
      LogText "*** InstallAddon: ADDON_NAME = $ADDON_NAME"
    !endif

    ReadINIStr $ITEM_LOCATION "${INIPATH}" "$ITEM_NAME" "TargetLocation"
    ${Unless} "$ITEM_LOCATION" == ""
      Call ResolveItemLocation
      StrCpy $ITEM_LOCATION "$ITEM_LOCATION\$ADDON_NAME"
    ${Else}
      StrCpy $ITEM_LOCATION "${APP_EXTENSIONS_DIR}\$ADDON_NAME"
    ${EndUnless}

    ReadINIStr $INI_TEMP "${INIPATH}" "$ITEM_NAME" "Overwrite"
    ${If} "$INI_TEMP" == "false"
    ${AndIf} ${FileExists} "$ITEM_LOCATION"
    ${AndIf} ${FileExists} "$ITEM_LOCATION\*.*"
      !ifdef NSIS_CONFIG_LOG
        LogText "*** InstallAddon: $ADDON_NAME installation is canceled (already installed)"
      !endif
      GoTo CANCELED
    ${EndIf}

    SetOutPath $ITEM_LOCATION

    ZipDLL::extractall "$EXEDIR\resources\$ITEM_NAME" "$ITEM_LOCATION"
    ; AccessControl::GrantOnFile "$ITEM_LOCATION" "(BU)" "GenericRead"

    ReadINIStr $INI_TEMP "${INIPATH}" "$ITEM_NAME" "Uninstall"
    ${If} "$INI_TEMP" != "false"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledAddon$ITEM_INDEX" "$ITEM_LOCATION"
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndIf}

    !ifdef NSIS_CONFIG_LOG
      LogText "*** InstallAddon: $ADDON_NAME successfully installed"
    !endif
  CANCELED:
FunctionEnd

Section "Install Shortcuts" InstallShortcuts
    ReadINIStr $ITEMS_LIST "${INIPATH}" "${INSTALLER_NAME}" "Shortcuts"
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
Var SHORTCUT_ICON_INDEX
Function "InstallShortcut"
    !ifdef NSIS_CONFIG_LOG
      LogSet on
      LogText "*** InstallShortcut: install $ITEM_NAME"
    !endif

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

    ReadINIStr $ITEM_LOCATION "${INIPATH}" "$ITEM_NAME" "Options"
    Call ResolveItemLocationBasic
    StrCpy $SHORTCUT_OPTIONS "$ITEM_LOCATION"

    ReadINIStr $SHORTCUT_ICON_INDEX "${INIPATH}" "$ITEM_NAME" "IconIndex"
;    ReadINIStr $SHORTCUT_DESCRIPTION "${INIPATH}" "$ITEM_NAME" "Description"
    ReadINIStr $ITEM_LOCATION "${INIPATH}" "$ITEM_NAME" "Path"
    Call ResolveItemLocation
    StrCpy $SHORTCUT_PATH "$ITEM_LOCATION"

    ReadINIStr $ITEM_LOCATION "${INIPATH}" "$ITEM_NAME" "TargetLocation"
    ${If} "$ITEM_LOCATION" == ""
      StrCpy $ITEM_LOCATION "%Desktop%"
    ${EndIf}
    Call ResolveItemLocation
;    SetOutPath $ITEM_LOCATION
    StrCpy $ITEM_LOCATION "$ITEM_LOCATION\$SHORTCUT_NAME.lnk"

    SetOutPath $SHORTCUT_PATH

    ${If} "$SHORTCUT_ICON_INDEX" == ""
    ${OrIf} "$SHORTCUT_ICON_INDEX" == "0"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_PATH" 0
    ${ElseIf} "$SHORTCUT_ICON_INDEX" == "1"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_PATH" 1
    ${ElseIf} "$SHORTCUT_ICON_INDEX" == "2"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_PATH" 2
    ${ElseIf} "$SHORTCUT_ICON_INDEX" == "3"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_PATH" 3
    ${ElseIf} "$SHORTCUT_ICON_INDEX" == "4"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_PATH" 4
    ${ElseIf} "$SHORTCUT_ICON_INDEX" == "5"
      CreateShortCut "$ITEM_LOCATION" "$SHORTCUT_PATH" "$SHORTCUT_OPTIONS" "$SHORTCUT_PATH" 5
    ${EndIf}

    ; AccessControl::GrantOnFile "$ITEM_LOCATION" "(BU)" "GenericRead"
    ${If} "$CREATED_TOP_REQUIRED_DIRECTORY" == ""
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledShortcut$ITEM_INDEX" "$ITEM_LOCATION"
      IntOp $ITEM_INDEX $ITEM_INDEX + 1
    ${EndIf}

    SetShellVarContext current

    !ifdef NSIS_CONFIG_LOG
      LogText "*** InstallShortcut: $ITEM_NAME successfully installed"
    !endif
FunctionEnd

Section "Install Extra Installers" InstallExtraInstallers
    !ifdef NSIS_CONFIG_LOG
      LogSet on
      LogText "*** InstallExtraInstallers"
    !endif
    ReadINIStr $ITEMS_LIST "${INIPATH}" "${INSTALLER_NAME}" "Installers"
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
    !ifdef NSIS_CONFIG_LOG
      LogSet on
      LogText "*** InstallExtraInstaller: install $ITEM_NAME"
    !endif

    ReadINIStr $EXTRA_INSTALLER_NAME "${INIPATH}" "$ITEM_NAME" "Name"
    !ifdef NSIS_CONFIG_LOG
      LogText "*** EXTRA_INSTALLER_NAME from INI: $EXTRA_INSTALLER_NAME"
    !endif
    ${If} "$EXTRA_INSTALLER_NAME" == ""
      StrCpy $EXTRA_INSTALLER_NAME "$ITEM_NAME"
    ${EndIf}

    ReadINIStr $EXTRA_INSTALLER_OPTIONS "${INIPATH}" "$ITEM_NAME" "Options"
    !ifdef NSIS_CONFIG_LOG
      LogText "*** EXTRA_INSTALLER_OPTIONS from INI: $EXTRA_INSTALLER_OPTIONS"
    !endif

    ExecWait '"$EXEDIR\resources\$EXTRA_INSTALLER_NAME" $EXTRA_INSTALLER_OPTIONS'

    !ifdef NSIS_CONFIG_LOG
      LogText "*** InstallExtraInstaller: $ITEM_NAME successfully installed"
    !endif
FunctionEnd

Section "Install Additional Files" InstallAdditionalFiles
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif

    StrCpy $ITEM_INDEX 0

    StrCpy $DIST_DIR "$APP_DIR"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.cfg" "InstallNormalFile"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.properties" "InstallNormalFile"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=override.ini" "InstallNormalFile"

    StrCpy $DIST_DIR "$APP_DIR\defaults"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.cer" "InstallNormalFile"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.crt" "InstallNormalFile"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.pem" "InstallNormalFile"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.cer.override" "InstallNormalFile"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.crt.override" "InstallNormalFile"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.pem.override" "InstallNormalFile"

    StrCpy $DIST_DIR "$APP_DIR\defaults\profile"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=bookmarks.html" "InstallNormalFile"
    StrCpy $DIST_DIR "$APP_DIR\defaults\profile"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.rdf" "InstallNormalFile"

    StrCpy $DIST_DIR "${APP_CONFIG_DIR}"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.js" "InstallNormalFile"

    StrCpy $DIST_DIR "$APP_DIR\chrome"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.css" "InstallNormalFile"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.jar" "InstallNormalFile"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.manifest" "InstallNormalFile"

    StrCpy $DIST_DIR "$APP_DIR\components"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.xpt" "InstallNormalFile"

    StrCpy $DIST_DIR "$APP_DIR\plugins"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.dll" "InstallNormalFile"

    !if ${APP_NAME} == "Netscape"
      ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=installed-chrome.txt" "AppendTextFile"
    !endif

    StrCpy $DIST_DIR "$DESKTOP"
    ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.lnk" "InstallNormalFile"
  ;  StrCpy $DIST_DIR "$QUICKLAUNCH"
  ;  ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.lnk" "InstallNormalFile"
  ;  StrCpy $DIST_DIR "$SMPROGRAMS"
  ;  ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.lnk" "InstallNormalFile"
SectionEnd

Function "InstallNormalFile"
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif

    StrCpy $PROCESSING_FILE "$R7"
    StrCpy $DIST_PATH "$DIST_DIR\$PROCESSING_FILE"
    !ifdef NSIS_CONFIG_LOG
      LogText "*** InstallNormalFile: install $PROCESSING_FILE to $DIST_PATH"
    !endif
    ${If} ${FileExists} "$DIST_PATH"
      StrCpy $BACKUP_PATH "$DIST_PATH.bakup.0"
      StrCpy $BACKUP_COUNT 0
      ${While} ${FileExists} "$DIST_PATH.bakup.$BACKUP_COUNT"
        IntOp $BACKUP_COUNT $BACKUP_COUNT + 1
        StrCpy $BACKUP_PATH "$DIST_PATH.bakup.$BACKUP_COUNT"
      ${EndWhile}
      !ifdef NSIS_CONFIG_LOG
        LogText "*** InstallNormalFile: backup old file as $BACKUP_PATH"
      !endif
      Rename "$DIST_PATH" "$BACKUP_PATH"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$ITEM_INDEXBackup" "$BACKUP_PATH"
    ${EndIf}

    SetOutPath $DIST_DIR

    CopyFiles /SILENT "$EXEDIR\resources\$PROCESSING_FILE" "$DIST_PATH"
    ; AccessControl::GrantOnFile "$DIST_PATH" "(BU)" "GenericRead"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$ITEM_INDEX" "$DIST_PATH"
    IntOp $ITEM_INDEX $ITEM_INDEX + 1

    !ifdef NSIS_CONFIG_LOG
      LogText "*** InstallNormalFile: $PROCESSING_FILE is successfully installed"
    !endif

    Push $PROCESSING_FILE ; for ${Locate}
FunctionEnd

!if ${APP_NAME} == "Netscape"
  Function "AppendTextFile"
      !ifdef NSIS_CONFIG_LOG
        LogSet on
      !endif

      StrCpy $PROCESSING_FILE "$R7"
      StrCpy $DIST_PATH "$DIST_DIR\$PROCESSING_FILE"
      ${If} ${FileExists} "$DIST_PATH"
        StrCpy $BACKUP_PATH "$DIST_PATH.bakup.0"
        StrCpy $BACKUP_COUNT 0
        ${While} ${FileExists} "$DIST_PATH.bakup.$BACKUP_COUNT"
          IntOp $BACKUP_COUNT $BACKUP_COUNT + 1
          StrCpy $BACKUP_PATH "$DIST_PATH.bakup.$BACKUP_COUNT"
        ${EndWhile}
        CopyFiles /SILENT "$DIST_PATH" "$BACKUP_PATH"
        WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$ITEM_INDEXBackup" "$BACKUP_PATH"
      ${EndIf}

      ClearErrors
      FileOpen $DIST_FILE "$DIST_PATH" a
      FileOpen $PROCESSING_FILE "$EXEDIR\resources\$PROCESSING_FILE" r
      MOVE_TO_END:
        FileRead $DIST_FILE $1
        IfErrors READ_AND_WRITE
        GoTo MOVE_TO_END
      READ_AND_WRITE:
        FileRead $PROCESSING_FILE $1
        FileWrite $DIST_FILE "$1$\n"
        IfErrors END_WRITE
        GoTo READ_AND_WRITE
      END_WRITE:
      FileClose $DIST_FILE
      FileClose $PROCESSING_FILE

      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$ITEM_INDEX" "$DIST_PATH"
      IntOp $ITEM_INDEX $ITEM_INDEX + 1

      Push $R0
  FunctionEnd
!endif

Section "Initialize Search Plugins" InitSearchPlugins
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif

    StrCpy $DIST_PATH   "$APP_DIR\searchplugins"
    StrCpy $BACKUP_PATH "$DIST_PATH.bakup.0"
    StrCpy $BACKUP_COUNT 0
    !ifdef NSIS_CONFIG_LOG
      LogText "*** InitSearchPlugins: install to $DIST_PATH"
    !endif
    ${While} ${FileExists} "$DIST_PATH.bakup.$BACKUP_COUNT"
      IntOp $BACKUP_COUNT $BACKUP_COUNT + 1
      StrCpy $BACKUP_PATH "$DIST_PATH.bakup.$BACKUP_COUNT"
    ${EndWhile}

    CreateDirectory "$BACKUP_PATH"
    !ifdef NSIS_CONFIG_LOG
      LogText "*** InitSearchPlugins: BACKUP_PATH = $BACKUP_PATH"
    !endif

    ${If} "$FX_ENABLED_SEARCH_PLUGINS" != ""
    ${AndIf} "$FX_ENABLED_SEARCH_PLUGINS" != "*"
      ${Locate} "$APP_DIR\searchplugins" "/L=F /G=0 /M=*.xml" "CheckDisableSearchPlugin"
    ${EndIf}
    ${If} "$FX_DISABLED_SEARCH_PLUGINS" == "*"
    ${OrIf} "$FX_DISABLED_SEARCH_PLUGINS" != ""
      ${Locate} "$APP_DIR\searchplugins" "/L=F /G=0 /M=*.xml" "CheckDisableSearchPlugin"
    ${EndIf}

    ${If} ${FileExists} "$BACKUP_PATH\*.xml"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisabledSearchPlugins" "$BACKUP_PATH"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "EnabledSearchPlugins" "$APP_DIR\searchplugins"
    ${Else}
      RMDir /r "$BACKUP_PATH"
    ${EndIf}

    ; install additional engines
    StrCpy $DIST_DIR "$APP_DIR\searchplugins"
    ${If} ${FileExists} "$EXEDIR\resources\*.xml"
      ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=*.xml" "InstallNormalFile"
    ${EndIf}
SectionEnd

Function "CheckDisableSearchPlugin"
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif

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
    Rename "$DIST_PATH\$PROCESSING_FILE" "$BACKUP_PATH\$PROCESSING_FILE"
  RETURN:



    Push $PROCESSING_FILE ; for ${Locate}
FunctionEnd

Section "Initialize Distribution Customizer" InitDistributonCustomizer
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif

    StrCpy $DIST_PATH   "$APP_DIR\distribution"
    StrCpy $BACKUP_PATH "$DIST_PATH.bakup.0"
    StrCpy $BACKUP_COUNT 0
    !ifdef NSIS_CONFIG_LOG
      LogText "*** InitDistributonCustomizer: install to $DIST_PATH"
    !endif
    ${While} ${FileExists} "$DIST_PATH.bakup.$BACKUP_COUNT"
      IntOp $BACKUP_COUNT $BACKUP_COUNT + 1
      StrCpy $BACKUP_PATH "$DIST_PATH.bakup.$BACKUP_COUNT"
    ${EndWhile}

    StrCpy $DIST_DIR "$DIST_PATH"
    ${If} ${FileExists} "$EXEDIR\resources\distribution.*"
      ${If} ${FileExists} "$DIST_PATH"
        WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DistributonCustomizerBackup" "$BACKUP_PATH"
        Rename "$DIST_PATH" "$BACKUP_PATH"
        !ifdef NSIS_CONFIG_LOG
          LogText "*** InitDistributonCustomizer: BACKUP_PATH = $BACKUP_PATH"
        !endif
      ${EndIf}
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledDistributonCustomizer" "$DIST_PATH"
      CreateDirectory "$DIST_PATH"
      ; AccessControl::GrantOnFile "$DIST_PATH" "(BU)" "GenericRead"
      ${Locate} "$EXEDIR\resources" "/L=F /G=0 /M=distribution.*" "InstallNormalFile"
    ${EndIf}
SectionEnd

Section -Post
    WriteUninstaller "${PRODUCT_UNINST_PATH}"
    WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName"     "${PRODUCT_FULL_NAME}"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" "${PRODUCT_UNINST_PATH}"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon"     "${PRODUCT_UNINST_PATH}"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion"  "${PRODUCT_VERSION}"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "URLInfoAbout"    "${PRODUCT_WEB_SITE}"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher"       "${PRODUCT_PUBLISHER}"
    ${If} "$APP_INSTALLED" == "1"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledAppVersion" "$APP_VERSION"
    ${EndIf}
SectionEnd

Section "Show Finish Message" ShowFinishMessage
    ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "FinishMessage"
    ReadINIStr $INI_TEMP2 "${INIPATH}" "${INSTALLER_NAME}" "FinishTitle"
    ${Unless} "$INI_TEMP" == ""
      ${WordReplace} "$INI_TEMP" "\n" "$\n" "+*" $INI_TEMP
      ${If} "$INI_TEMP2" == ""
        MessageBox MB_OK "$INI_TEMP" /SD IDOK
      ${Else}
        !insertmacro NativeMessageBox ${NATIVE_MB_OK} "$INI_TEMP2" "$INI_TEMP" $0
      ${EndIf}
    ${EndUnless}
SectionEnd

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
      RMDir /r "$ITEM_LOCATION"
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
FunctionEnd

Function un.onUninstSuccess
    HideWindow
    !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
      MessageBox MB_ICONINFORMATION|MB_OK "$(MSG_UNINST_SUCCESS)"
    !endif

    ${un.GetParameters} $0
    ${un.GetOptions} "$0" "/AddonOnly" $1
    ${If} ${Errors}
    ${AndIf} "$APP_VERSION" != ""
      ReadRegStr $APP_VERSION HKLM "${APP_REG_KEY}" "CurrentVersion"
      ${IfThen} "$APP_VERSION" == "" ${|} GoTo RETURN ${|}
      StrCpy $0 "${APP_REG_KEY}\$APP_VERSION\Main"
      ReadRegStr $APP_DIR HKLM $0 "Install Directory"
      ${IfThen} "$APP_DIR" == "" ${|} GoTo RETURN ${|}

    !if ${APP_NAME} == "Netscape"
      ${If} ${FileExists} "$APP_DIR\uninstall\install_wizard*.log"
    !else
      ${If} ${FileExists} "$APP_DIR\uninstall\uninstall.log"
    !endif
        !if ${APP_INSTALL_MODE} != "SKIP"
          !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
            MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(MSG_UNINST_APP_CONFIRM)" IDYES +2
            GoTo SKIP_APP_UNINSTALLATION
          !endif
          !if ${APP_INSTALL_MODE} == "QUIET"
            !if ${APP_NAME} == "Netscape"
              ExecWait `"$APP_DIR\uninstall\NSUninst.exe" -ms`
            !else
              ExecWait `"$APP_DIR\uninstall\helper.exe" /S`
            !endif
          !else
            !if ${APP_NAME} == "Netscape"
              ExecWait "$APP_DIR\uninstall\NSUninst.exe"
            !else
              ExecWait "$APP_DIR\uninstall\helper.exe"
            !endif
          !endif
        !endif
        SKIP_APP_UNINSTALLATION:
      ${EndIf}

      RETURN:
    ${EndIf}
FunctionEnd

;=== Utility functions
Function CheckCleanInstall
  !ifdef NSIS_CONFIG_LOG
    LogSet on
  !endif

  ${If} ${FileExists} "${APP_PROFILE_PATH}"
    ${If} "$CLEAN_INSTALL" == "REQUIRED"
      ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "CleanInstallRequiredMessage"
      ${WordReplace} "$INI_TEMP" "\n" "$\n" "+*" $INI_TEMP
      ReadINIStr $INI_TEMP2 "${INIPATH}" "${INSTALLER_NAME}" "CleanInstallRequiredTitle"
      ${IfThen} "$INI_TEMP" == "" ${|} StrCpy $INI_TEMP "$(MSG_CLEAN_INSTALL_REQUIRED)" ${|}
      ${If} "$INI_TEMP2" == ""
        MessageBox MB_OK|MB_ICONEXCLAMATION "$INI_TEMP" /SD IDOK
      ${Else}
        !insertmacro NativeMessageBox ${NATIVE_MB_OK}|${NATIVE_MB_ICONEXCLAMATION} "$INI_TEMP2" "$INI_TEMP" $0
      ${EndIf}
      Abort
    ${ElseIf} "$CLEAN_INSTALL" == "PREFERRED"
      ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "CleanInstallPreferredMessage"
      ${WordReplace} "$INI_TEMP" "\n" "$\n" "+*" $INI_TEMP
      ReadINIStr $INI_TEMP2 "${INIPATH}" "${INSTALLER_NAME}" "CleanInstallPreferredTitle"
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

Var REQUIRE_ADMIN_PRIVILEGE
Function CheckAdminPrivilege
    ReadINIStr $REQUIRE_ADMIN_PRIVILEGE "${INIPATH}" "${INSTALLER_NAME}" "RequireAdminPrivilege"
    ${If} "$REQUIRE_ADMIN_PRIVILEGE" == "false"
      GoTo PRIVILEGE_TEST_DONE
    ${EndIf}

    AccessControl::GetCurrentUserName
    Pop $0
    AccessControl::IsUserTheAdministrator $0
    Pop $0
    Pop $1
    ${If} "$1" == "yes"
      GoTo PRIVILEGE_TEST_DONE
    ${EndIf}

    ; check by local group
    UserMgr::GetCurrentUserName
    Pop $0
    UserMgr::IsMemberOfGroup "$0" "Administrators"
    Pop $0
    ${If} "$0" == "TRUE"
      GoTo PRIVILEGE_TEST_DONE
    ${EndIf}

    ; check by file writing
    ReadINIStr $ITEM_LOCATION "${INIPATH}" "${INSTALLER_NAME}" "AdminPrivilegeCheckDirectory"
    Call ResolveItemLocation
    ${IfThen} "$ITEM_LOCATION" == "" ${|} StrCpy $ITEM_LOCATION "$PROGRAMFILES" ${|}
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

    MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_NOT_ADMIN_ERROR)" /SD IDOK
    Abort

  PRIVILEGE_TEST_DONE:
FunctionEnd

Function CheckInstalled
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif

    ReadRegStr $R0 HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
    ${Unless} "$R0" == ""
      !if ${APP_INSTALL_MODE} != "SKIP"
        !if ${PRODUCT_INSTALL_MODE} == "NORMAL"
          MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION "$(MSG_ALREADY_INSTALLED)" IDOK UNINST
          Abort
        !endif

      UNINST:
        !ifdef NSIS_CONFIG_LOG
          LogText "CheckInstalled: Application is installed by meta installer"
        !endif
        ; アプリケーションがこのアドオンの旧バージョンによって
        ; 自動インストールされたものである場合、状態を引き継ぐ
        ReadRegStr $APP_VERSION HKLM "${PRODUCT_UNINST_KEY}" "InstalledAppVersion"
        ${IfThen} "$APP_VERSION" != "" ${|} StrCpy $APP_INSTALLED "1" ${|}
        ; アンインストーラを一時ファイルにコピーしないでそのまま実行
        ; こうしないと，すぐに終了して戻ってきてしまうみたい
        ExecWait '$R0 /AddonOnly _?=$INSTDIR'
      !endif
    ${EndUnless}
FunctionEnd

Function LoadINI
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif

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

Function CheckAppProc
    FindProcDLL::FindProc "${APP_EXE}" $R0
    ${If} "$R0" == "1"
      MessageBox MB_OK|MB_ICONINFORMATION `$(MSG_APP_IS_RUNNING)`
      Abort
    ${EndIf}
FunctionEnd

Function un.CheckAppProc
    FindProcDLL::FindProc "${APP_EXE}" $R0
    ${If} "$R0" == "1"
      MessageBox MB_OK|MB_ICONINFORMATION `$(MSG_APP_IS_RUNNING)`
      Abort
    ${EndIf}
FunctionEnd

Function GetAppPath
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif

    ${IfThen} "$APP_INSTALLED" != "1" ${|} StrCpy $APP_INSTALLED "0" ${|}

    !ifdef NSIS_CONFIG_LOG
      LogText "*** GetAppPath: Application installed"
    !endif

    ReadRegStr $APP_VERSION HKLM "${APP_REG_KEY}" "CurrentVersion"
    ${IfThen} "$APP_VERSION" == "" ${|} GoTo ERR ${|}
    StrCpy $0 "${APP_REG_KEY}\$APP_VERSION\Main"

    ; EXE path
    ReadRegStr $APP_EXE_PATH HKLM $0 "PathToExe"
    ${IfThen} "$APP_EXE_PATH" == "" ${|} GoTo ERR ${|}

    !ifdef NSIS_CONFIG_LOG
      LogText "*** GetAppPath: APP_EXE_PATH = $APP_EXE_PATH"
    !endif

    ; Application directory
    ReadRegStr $APP_DIR HKLM $0 "Install Directory"
    ${IfThen} "$APP_DIR" == "" ${|} GoTo ERR ${|}

    !ifdef NSIS_CONFIG_LOG
      LogText "*** GetAppPath: APP_DIR = $APP_DIR"
    !endif

    ${If} ${FileExists} "${APP_INSTALLER_INI}"
      ReadINIStr $INI_TEMP "${APP_INSTALLER_INI}" "Install" "InstallDirectoryName"
      ReadINIStr $INI_TEMP2 "${APP_INSTALLER_INI}" "Install" "InstallDirectoryPath"
      ${If} $INI_TEMP != ""
      ${OrIf} $INI_TEMP2 != ""
        ${IfThen} "$INI_TEMP" == "" ${|} StrCpy $INI_TEMP "${APP_DIRECTORY_NAME}" ${|}
        ${IfThen} "$INI_TEMP2" == "" ${|} StrCpy $INI_TEMP2 "$PROGRAMFILES" ${|}
        ${If} "$APP_DIR" != "$INI_TEMP2\$INI_TEMP"
          !ifdef NSIS_CONFIG_LOG
            LogText "*** GetAppPath: APP_DIR must be $INI_TEMP2\$INI_TEMP"
          !endif
          GoTo ERR
        ${EndIf}
      ${EndIf}
    ${EndIf}

    ${If} ${FileExists} "$APP_EXE_PATH"
      ${If} ${FileExists} "$APP_DIR"
      ${OrIf} ${FileExists} "$APP_DIR\*.*"
        !ifdef NSIS_CONFIG_LOG
          LogText "*** GetAppPath: Application exists"
        !endif
        StrCpy $APP_EXISTS "1"
      ${EndIf}
    ${EndIf}

  ERR:
FunctionEnd

Function GetFirstStrPart
  Exch $R0
  Push $R1
  Push $R2
  StrLen $R1 $R0
  IntOp $R1 $R1 + 1
  loop:
    IntOp $R1 $R1 - 1
    StrCpy $R2 $R0 1 -$R1
    StrCmp $R2 "" exit2
    StrCmp $R2 " " exit1 ; Change " " to "\" if ur inputting dir path str
  Goto loop
  exit1:
    StrCpy $R0 $R0 -$R1
  exit2:
    Pop $R2
    Pop $R1
    Exch $R0
FunctionEnd

Function CheckAppVersion
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif

    Push $APP_VERSION
    Call GetFirstStrPart
    Pop $NORMALIZED_APP_VERSION

    !ifdef NSIS_CONFIG_LOG
      LogText "*** CheckAppVersion: APP_VERSION = $APP_VERSION"
      LogText "*** CheckAppVersion: NORMALIZED_APP_VERSION = $NORMALIZED_APP_VERSION"
      LogText "*** CheckAppVersion: APP_MIN_VERSION = $APP_MIN_VERSION"
      LogText "*** CheckAppVersion: APP_MAX_VERSION = $APP_MAX_VERSION"
      LogText "*** CheckAppVersion: APP_ALLOW_DOWNGRADE = $APP_ALLOW_DOWNGRADE"
    !endif

    ${VersionConvert} "$NORMALIZED_APP_VERSION" "abcdefghijklmnopqrstuvwxyz" $APP_VERSION_NUM
    StrCpy $APP_WRONG_VERSION "0"

    ${ReadINIStrWithDefault} $APP_ALLOW_DOWNGRADE "${INIPATH}" "${INSTALLER_NAME}" "AppAllowDowngrade" "${APP_ALLOW_DOWNGRADE}"
    ${If} "$APP_ALLOW_DOWNGRADE" == "1"
    ${OrIf} "$APP_ALLOW_DOWNGRADE" == "yes"
      StrCpy $APP_ALLOW_DOWNGRADE "true"
    ${EndIf}

    ${IfThen} "$APP_EXISTS" != "1" ${|} GoTo RETURN ${|}

    !ifdef NSIS_CONFIG_LOG
      LogText "*** CheckAppVersion: Application exists"
    !endif

    ${ReadINIStrWithDefault} $0 "${INIPATH}" "${INSTALLER_NAME}" "AppMaxVersion" "${APP_MAX_VERSION}"
    ${VersionConvert} "$0" "abcdefghijklmnopqrstuvwxyz" $1
    ${VersionCompare} "$APP_VERSION_NUM" "$1" $0
    ${If} "$0" == "1"
      StrCpy $APP_WRONG_VERSION "2"
      StrCpy $APP_EXISTS "0"
      !ifdef NSIS_CONFIG_LOG
        LogText "*** CheckAppVersion: Installed version is too new"
      !endif
      GoTo RETURN
    ${EndIf}

    ${ReadINIStrWithDefault} $0 "${INIPATH}" "${INSTALLER_NAME}" "AppMinVersion" "${APP_MIN_VERSION}"
    ${VersionConvert} "$0" "abcdefghijklmnopqrstuvwxyz" $1
    ${VersionCompare} "$APP_VERSION_NUM" "$1" $0
    ${If} "$0" == "2"
      StrCpy $APP_WRONG_VERSION "1"
      StrCpy $APP_EXISTS "0"
      !ifdef NSIS_CONFIG_LOG
        LogText "*** CheckAppVersion: Installed version is too old"
      !endif
      GoTo RETURN
    ${EndIf}
  RETURN:
FunctionEnd

Function CheckAppVersionWithMessage
    !ifdef NSIS_CONFIG_LOG
      LogSet on
    !endif

    ${IfThen} "$APP_EXISTS" != "1" ${|} GoTo RETURN ${|}

    Call CheckAppVersion

    !ifdef NSIS_CONFIG_LOG
      LogText "*** CheckAppVersionWithMessage: APP_WRONG_VERSION = $APP_WRONG_VERSION"
    !endif
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
    !ifdef NSIS_CONFIG_LOG
      LogText "*** SetUpRequiredDirectories: setup $REQUIRED_DIRECTORY"
    !endif

    StrCpy $CREATED_TOP_REQUIRED_DIRECTORY ""
    StrCpy $REQUIRED_DIRECTORIES "$REQUIRED_DIRECTORY"

    StrCpy $R0 "$REQUIRED_DIRECTORIES"
    ${While} 1 == 1
      ${GetParent} "$R0" $R1
      ${IfThen} "$R1" == "" ${|} ${Break} ${|}
      StrCpy $REQUIRED_DIRECTORIES "$R1${SEPARATOR}$REQUIRED_DIRECTORIES"
      StrCpy $R0 "$R1"
    ${EndWhile}

    !ifdef NSIS_CONFIG_LOG
      LogText "*** SetUpRequiredDirectories: folders = $REQUIRED_DIRECTORIES"
    !endif

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
      !ifdef NSIS_CONFIG_LOG
        LogText "*** SetUpRequiredDirectories: create $ITEM_LOCATION"
      !endif
      CreateDirectory "$ITEM_LOCATION"
      ${If} "$CREATED_TOP_REQUIRED_DIRECTORY" == ""
        StrCpy $CREATED_TOP_REQUIRED_DIRECTORY "$ITEM_LOCATION"
        !ifdef NSIS_CONFIG_LOG
          LogText "*** SetUpRequiredDirectories: top level = $ITEM_LOCATION"
        !endif
      ${EndIf}
    ${EndWhile}
FunctionEnd

Function "ResolveItemLocation"
    Call ResolveItemLocationBasic

    ; Windows Environment Variables
    ${WordReplace} "$ITEM_LOCATION" "%AppData%" "$APPDATA" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Appdata%" "$APPDATA" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%appdata%" "$APPDATA" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%APPDATA%" "$APPDATA" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%HomePath%" "$PROFILE" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Homepath%" "$PROFILE" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%homepath%" "$PROFILE" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%HOMEPATH%" "$PROFILE" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%HomeDrive%" "$%homedrive%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Homedrive%" "$%homedrive%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%homedrive%" "$%homedrive%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%HOMEDRIVE%" "$%homedrive%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%UserName%" "$%username%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Username%" "$%username%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%username%" "$%username%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%USERNAME%" "$%username%" "+*" $ITEM_LOCATION
FunctionEnd

Function "ResolveItemLocationBasic"
    ; Windows Environment Variables
    ${WordReplace} "$ITEM_LOCATION" "%SystemDrive%" "$%systemdrive%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Systemdrive%" "$%systemdrive%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%systemdrive%" "$%systemdrive%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%SYSTEMDRIVE%" "$%systemdrive%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%SystemRoot%" "$WINDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Systemroot%" "$WINDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%systemroot%" "$WINDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%SYSTEMROOT%" "$WINDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%WinDir%" "$WINDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Windir%" "$WINDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%windir%" "$WINDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%WINDIR%" "$WINDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%ProgramFiles%" "$PROGRAMFILES" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Programfiles%" "$PROGRAMFILES" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%programfiles%" "$PROGRAMFILES" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%PROGRAMFILES%" "$PROGRAMFILES" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%CommonProgramFiles%" "$%commonprogramfiles%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Commonprogramfiles%" "$%commonprogramfiles%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%commonprogramfiles%" "$%commonprogramfiles%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%COMMONPROGRAMFILES%" "$%commonprogramfiles%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Tmp%" "$TEMP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%tmp%" "$TEMP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%TMP%" "$TEMP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Temp%" "$TEMP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%temp%" "$TEMP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%TEMP%" "$TEMP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%ComputerName%" "$%computername%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Computername%" "$%computername%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%computername%" "$%computername%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%COMPUTERNAME%" "$%computername%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%AllUsersProfile%" "$%allusersprofile%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Allusersprofile%" "$%allusersprofile%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%allusersprofile%" "$%allusersprofile%" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%ALLUSERSPROFILE%" "$%allusersprofile%" "+*" $ITEM_LOCATION

    ; custom
    ${WordReplace} "$ITEM_LOCATION" "%Home%" "$PROFILE" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%home%" "$PROFILE" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%HOME%" "$PROFILE" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%DeskTop%" "$DESKTOP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Desktop%" "$DESKTOP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%desktop%" "$DESKTOP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%DESKTOP%" "$DESKTOP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%AppDir%" "$APP_DIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Appdir%" "$APP_DIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%appdir%" "$APP_DIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%APPDIR%" "$APP_DIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%SysDir%" "$SYSDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Sysdir%" "$SYSDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%sysdir%" "$SYSDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%SYSDIR%" "$SYSDIR" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%ProgramFiles32%" "$PROGRAMFILES32" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Programfiles32%" "$PROGRAMFILES32" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%programfiles32%" "$PROGRAMFILES32" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%PROGRAMFILES32%" "$PROGRAMFILES32" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%ProgramFiles64%" "$PROGRAMFILES64" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Programfiles64%" "$PROGRAMFILES64" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%programfiles64%" "$PROGRAMFILES64" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%PROGRAMFILES64%" "$PROGRAMFILES64" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%CommonFiles%" "$COMMONFILES" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Commonfiles%" "$COMMONFILES" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%commonfiles%" "$COMMONFILES" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%COMMONFILES%" "$COMMONFILES" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%CommonFiles32%" "$COMMONFILES32" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Commonfiles32%" "$COMMONFILES32" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%commonfiles32%" "$COMMONFILES32" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%COMMONFILES32%" "$COMMONFILES32" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%CommonFiles64%" "$COMMONFILES64" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Commonfiles64%" "$COMMONFILES64" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%commonfiles64%" "$COMMONFILES64" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%COMMONFILES64%" "$COMMONFILES64" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Startmenu%" "$STARTMENU" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%StartMenu%" "$STARTMENU" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%startmenu%" "$STARTMENU" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%STARTMENU%" "$STARTMENU" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Programs%" "$SMPROGRAMS" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%programs%" "$SMPROGRAMS" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%PROGRAMS%" "$SMPROGRAMS" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%Startup%" "$SMSTARTUP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%StartUp%" "$SMSTARTUP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%startup%" "$SMSTARTUP" "+*" $ITEM_LOCATION
    ${WordReplace} "$ITEM_LOCATION" "%STARTUP%" "$SMSTARTUP" "+*" $ITEM_LOCATION
FunctionEnd

Function "un.ResolveItemLocation"
    Call un.ResolveItemLocationBasic

    ; Windows Environment Variables
    ${un.WordReplace} "$ITEM_LOCATION" "%AppData%" "$APPDATA" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Appdata%" "$APPDATA" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%appdata%" "$APPDATA" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%APPDATA%" "$APPDATA" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%HomePath%" "$PROFILE" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Homepath%" "$PROFILE" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%homepath%" "$PROFILE" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%HOMEPATH%" "$PROFILE" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%HomeDrive%" "$%homedrive%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Homedrive%" "$%homedrive%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%homedrive%" "$%homedrive%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%HOMEDRIVE%" "$%homedrive%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%UserName%" "$%username%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Username%" "$%username%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%username%" "$%username%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%USERNAME%" "$%username%" "+*" $ITEM_LOCATION
FunctionEnd

Function "un.ResolveItemLocationBasic"
    ; Windows Environment Variables
    ${un.WordReplace} "$ITEM_LOCATION" "%SystemDrive%" "$%systemdrive%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Systemdrive%" "$%systemdrive%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%systemdrive%" "$%systemdrive%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%SYSTEMDRIVE%" "$%systemdrive%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%SystemRoot%" "$WINDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Systemroot%" "$WINDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%systemroot%" "$WINDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%SYSTEMROOT%" "$WINDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%WinDir%" "$WINDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Windir%" "$WINDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%windir%" "$WINDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%WINDIR%" "$WINDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%ProgramFiles%" "$PROGRAMFILES" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Programfiles%" "$PROGRAMFILES" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%programfiles%" "$PROGRAMFILES" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%PROGRAMFILES%" "$PROGRAMFILES" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%CommonProgramFiles%" "$%commonprogramfiles%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Commonprogramfiles%" "$%commonprogramfiles%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%commonprogramfiles%" "$%commonprogramfiles%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%COMMONPROGRAMFILES%" "$%commonprogramfiles%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Tmp%" "$TEMP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%tmp%" "$TEMP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%TMP%" "$TEMP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Temp%" "$TEMP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%temp%" "$TEMP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%TEMP%" "$TEMP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%ComputerName%" "$%computername%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Computername%" "$%computername%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%computername%" "$%computername%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%COMPUTERNAME%" "$%computername%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%AllUsersProfile%" "$%allusersprofile%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Allusersprofile%" "$%allusersprofile%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%allusersprofile%" "$%allusersprofile%" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%ALLUSERSPROFILE%" "$%allusersprofile%" "+*" $ITEM_LOCATION

    ; custom
    ${un.WordReplace} "$ITEM_LOCATION" "%Home%" "$PROFILE" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%home%" "$PROFILE" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%HOME%" "$PROFILE" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%DeskTop%" "$DESKTOP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Desktop%" "$DESKTOP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%desktop%" "$DESKTOP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%DESKTOP%" "$DESKTOP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%AppDir%" "$APP_DIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Appdir%" "$APP_DIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%appdir%" "$APP_DIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%APPDIR%" "$APP_DIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%SysDir%" "$SYSDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Sysdir%" "$SYSDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%sysdir%" "$SYSDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%SYSDIR%" "$SYSDIR" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%ProgramFiles32%" "$PROGRAMFILES32" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Programfiles32%" "$PROGRAMFILES32" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%programfiles32%" "$PROGRAMFILES32" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%PROGRAMFILES32%" "$PROGRAMFILES32" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%ProgramFiles64%" "$PROGRAMFILES64" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Programfiles64%" "$PROGRAMFILES64" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%programfiles64%" "$PROGRAMFILES64" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%PROGRAMFILES64%" "$PROGRAMFILES64" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%CommonFiles%" "$COMMONFILES" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Commonfiles%" "$COMMONFILES" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%commonfiles%" "$COMMONFILES" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%COMMONFILES%" "$COMMONFILES" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%CommonFiles32%" "$COMMONFILES32" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Commonfiles32%" "$COMMONFILES32" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%commonfiles32%" "$COMMONFILES32" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%COMMONFILES32%" "$COMMONFILES32" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%CommonFiles64%" "$COMMONFILES64" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Commonfiles64%" "$COMMONFILES64" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%commonfiles64%" "$COMMONFILES64" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%COMMONFILES64%" "$COMMONFILES64" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Startmenu%" "$STARTMENU" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%StartMenu%" "$STARTMENU" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%startmenu%" "$STARTMENU" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%STARTMENU%" "$STARTMENU" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Programs%" "$SMPROGRAMS" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%programs%" "$SMPROGRAMS" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%PROGRAMS%" "$SMPROGRAMS" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%Startup%" "$SMSTARTUP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%StartUp%" "$SMSTARTUP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%startup%" "$SMSTARTUP" "+*" $ITEM_LOCATION
    ${un.WordReplace} "$ITEM_LOCATION" "%STARTUP%" "$SMSTARTUP" "+*" $ITEM_LOCATION
FunctionEnd
