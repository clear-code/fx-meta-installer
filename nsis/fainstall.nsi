;Copyright (C) 2008-2009 ClearCode Inc.

;=== Libraries
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!insertmacro Locate
!insertmacro un.Locate
!insertmacro GetBaseName
!insertmacro un.GetParameters
!insertmacro un.GetOptions
!include "WordFunc.nsh"
!insertmacro WordFind
!insertmacro WordReplace
!insertmacro VersionCompare
!insertmacro VersionConvert

;== Basic Information
!include "..\config.nsh"

!if ${APP_NAME} == "Firefox"
  !define APP_EXE "firefox.exe"
  !define APP_KEY "Mozilla\Mozilla Firefox"
!else if ${APP_NAME} == "Thunderbird"
  !define APP_EXE "thunderbird.exe"
  !define APP_KEY "Mozilla\Mozilla Thunderbird"
!else if ${APP_NAME} == "Netscape"
  !define APP_EXE "Netscp.exe"
  !define APP_KEY "Netscape\Netscape"
!endif

!ifndef APP_EXE
  !define APP_EXE "${APP_NAME}.exe"
!endif
!ifndef APP_KEY
  !define APP_KEY "${APP_NAME}"
!endif

!define INSTALLER_NAME      "fainstall"
!define PRODUCT_UNINST_KEY  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_DIR_REGKEY  "${PRODUCT_UNINST_KEY}\InstalledPath"
!define PRODUCT_UNINST_PATH "$INSTDIR\uninst.exe"

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

!ifndef FX_ENABLED_SEARCH_PLUGINS
  !define FX_ENABLED_SEARCH_PLUGINS "*"
!endif
!ifndef FX_DISABLED_SEARCH_PLUGINS
  !define FX_DISABLED_SEARCH_PLUGINS ""
!endif

!define INIPATH             "$EXEDIR\${INSTALLER_NAME}.ini"

!define SILENT_INSTALL_OPTIONS "-ms -ira -ispf"
; -ms   : サイレントインストール（INIを無視）
; -ma   : 自動インストール（進行状況をダイアログで表示、Netscape用）
; -ira  : インストール完了後のアプリケーションの自動起動を無効（Netscape用）
; -ispf : インストール完了後のスタートメニュー内フォルダを開く処理を無効（Netscape用）

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
!if ${APP_NAME} == "Netscape"
Var SHORTCUT_DEFAULT_NAME
Var SHORTCUT_NAME
Var PROGRAM_FOLDER_DEFAULT_NAME
Var PROGRAM_FOLDER_NAME
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
!ifdef APP_SILENT_INSTALL
Var APP_EULA_DL_FAILED
!endif
Var APP_WRONG_VERSION

Var PROCESSING_FILE
Var DIST_DIR
Var DIST_PATH
Var DIST_FILE
Var BACKUP_PATH
Var BACKUP_COUNT
Var INSTALLED_FILE
Var INSTALLED_FILE_INDEX

Var ADDON_LIST
Var ADDON_LIST_INDEX
Var ADDON_FILE
Var ADDON_NAME
Var ADDON_TARGET_LOCATION
Var ADDON_DIR
Var ADDON_INDEX

Var UNINSTALL_FAILED

Var INI_TEMP

Var APP_DOWNLOAD_PATH
Var APP_DOWNLOAD_URL
Var APP_EULA_PATH
Var APP_EULA_URL
Var APP_HASH
Var APP_INSTALL_TALKBACK

Var FX_ENABLED_SEARCH_PLUGINS
Var FX_DISABLED_SEARCH_PLUGINS
Var SEARCH_PLUGINS_PATH

;=== MUI
!include "MUI2.nsh"
!include "Sections.nsh"
!include "Japanese.nsh"

; hide the footer "Nullsoft Install System v*.*"
BrandingText " "

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON                     "${INSTALLER_NAME}.ico"
!define MUI_UNICON                   "${INSTALLER_NAME}.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\icon\welcome.bmp"
!define MUI_FINISHPAGE_RUN           "$APP_EXE_PATH"
!define MUI_FINISHPAGE_RUN_TEXT      $(MSG_APP_RUN_TEXT)
!define MUI_FINISHPAGE_LINK          "${PRODUCT_WEB_LABEL}"
!define MUI_FINISHPAGE_LINK_LOCATION "${PRODUCT_WEB_SITE}"

; MUI Pages

!insertmacro MUI_PAGE_WELCOME

!ifndef PRODUCT_SILENT_INSTALL
;!define MUI_LICENSEPAGE_RADIOBUTTONS
!insertmacro MUI_PAGE_LICENSE "..\resources\COPYING.txt"
!endif

!ifdef APP_SILENT_INSTALL
!define MUI_LICENSEPAGE_RADIOBUTTONS
!define MUI_PAGE_CUSTOMFUNCTION_PRE "AppEULAPageCheck"
!define MUI_PAGE_CUSTOMFUNCTION_SHOW "AppEULAPageSetup"
!insertmacro MUI_PAGE_LICENSE "dummy.txt"
!endif

!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_PAGE_FINISH


; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "Japanese" #  ${LANG_JAPANESE}
;=== MUI end

;=== MUI sections
!ifdef APP_SILENT_INSTALL
Function AppEULAPageCheck
!ifdef NSIS_CONFIG_LOG
    LogSet on
!endif

    StrCpy $APP_EULA_DL_FAILED "0"

    Call GetAppPath
    Call CheckAppVersionWithMessage

    ${If} $APP_EXISTS != "1"
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
        ${If} $R0 != "OK"
          StrCpy $APP_EULA_DL_FAILED "1"
          Abort
        ${EndIf}
      ${EndUnless}
      EULADownloadDone:
!ifdef NSIS_CONFIG_LOG
      LogText "*** AppEULAPageCheck: EULA = &APP_EULA_FINAL_PATH"
!endif
    ${Else}
!ifdef NSIS_CONFIG_LOG
      LogText "*** AppEULAPageCheck: EULA does not exist"
!endif
      Abort
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

Section "Download Application" DownloadApp
!ifdef NSIS_CONFIG_LOG
    LogSet on
!endif

!ifdef APP_SILENT_INSTALL
    ${If} $APP_EULA_DL_FAILED == "1"
      MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_DOWNLOAD_ERROR)" /SD IDOK
!ifdef NSIS_CONFIG_LOG
      LogText "*** DownloadApp: Application's EULA does not exist"
!endif
      Abort
    ${EndIf}
!endif

    Call GetAppPath
!ifdef APP_SILENT_INSTALL
    Call CheckAppVersion
!else
    Call CheckAppVersionWithMessage
!endif

    ${If} $APP_EXISTS != "1"
!ifdef NSIS_CONFIG_LOG
      LogText "*** DownloadApp: Application dest not exist so do installation"
!endif
      StrCpy $APP_INSTALLER_FINAL_PATH "${APP_INSTALLER_PATH}"

      ${IfThen} ${FileExists} "$APP_INSTALLER_FINAL_PATH" ${|} GoTo AppDownloadDone ${|}

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

      ${If} $R0 != "OK"
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
        ${If} $0 != "$APP_HASH"
          MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_HASH_ERROR)" /SD IDOK
!ifdef NSIS_CONFIG_LOG
          LogText "*** DownloadApp: Downloaded file is broken"
!endif
          Abort
        ${EndIf}
      ${EndIf}

      AppDownloadDone:
!ifdef NSIS_CONFIG_LOG
      LogText "*** DownloadApp: installer is $APP_INSTALLER_FINAL_PATH"
!endif
    ${EndIf}
SectionEnd

Section "Install Application" InstallApp
!ifdef NSIS_CONFIG_LOG
    LogSet on
!endif

    Call GetAppPath
    Call CheckAppVersion

!if ${APP_NAME} == "Netscape"
    Call CheckShortcutsExistence
!endif

    ${If} $APP_EXISTS != "1"
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
!ifdef APP_SILENT_INSTALL
        ExecWait '"$APP_INSTALLER_FINAL_PATH" ${SILENT_INSTALL_OPTIONS}'
!else
        ExecWait '$APP_INSTALLER_FINAL_PATH'
!endif
      ${EndIf}

      Call GetAppPath
      Call CheckAppVersion

!if ${APP_NAME} == "Netscape"
      Call UpdateShortcutsExistence
!endif

      ${If} $APP_EXISTS != "1"
        ${If} $APP_WRONG_VERSION == "1"
          MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_VERSION_TOO_LOW_ERROR)" /SD IDOK
        ${Else}
          MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_INSTALL_ERROR)" /SD IDOK
        ${EndIf}
!ifdef NSIS_CONFIG_LOG
        LogText "*** InstallApp: Version check failed"
!endif
        Abort
      ${EndIf}

      StrCpy $APP_INSTALLED "1"

      ${If} $APP_INSTALL_TALKBACK == "false"
        RMDir /r "${APP_EXTENSIONS_DIR}\talkback@mozilla.org"
      ${EndIf}

      ; overwrite subtitle
      SendMessage $mui.Header.SubText ${WM_SETTEXT} 0 "STR:$(MSG_PRODUCT_INSTALLING)"
    ${EndIf}

    StrCpy $INSTDIR "$PROGRAMFILES\${PRODUCT_PUBLISHER}\${PRODUCT_NAME}"
    SetOutPath $INSTDIR
!ifdef NSIS_CONFIG_LOG
    LogText "*** InstallApp: install to $INSTDIR"
!endif
SectionEnd

!if ${APP_NAME} == "Netscape"
Function "CheckShortcutsExistence"
!ifdef NSIS_CONFIG_LOG
    LogSet on
!endif

    StrCpy $SHORTCUT_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"
    StrCpy $PROGRAM_FOLDER_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"
    ${If} ${FileExists} "${APP_INSTALLER_INI}"
      ReadINIStr $SHORTCUT_NAME "${APP_INSTALLER_INI}" "Install" "ShortcutName"
      ReadINIStr $PROGRAM_FOLDER_NAME "${APP_INSTALLER_INI}" "Install" "StartMenuDirectoryName"
    ${EndIf}
    ${IfThen} $SHORTCUT_NAME" == "" ${|} StrCpy $SHORTCUT_NAME "$SHORTCUT_DEFAULT_NAME" ${|}
    ${IfThen} $PROGRAM_FOLDER_NAME" == "" ${|} StrCpy $PROGRAM_FOLDER_NAME "$PROGRAM_FOLDER_DEFAULT_NAME" ${|}

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
FunctionEnd

Function "UpdateShortcutsExistence"
!ifdef NSIS_CONFIG_LOG
    LogSet on
!endif

    StrCpy $SHORTCUT_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"
    StrCpy $PROGRAM_FOLDER_DEFAULT_NAME "${APP_NAME} $APP_VERSION_NUM"

    ${If} ${FileExists} "${APP_INSTALLER_INI}"
      ReadINIStr $1 "${APP_INSTALLER_INI}" "Install" "DesktopShortcut"
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
        ${If} ${FileExists} "$QUICKLAUNCH\$SHORTCUT_DEFAULT_NAME.lnk"
          Rename "$QUICKLAUNCH\$SHORTCUT_DEFAULT_NAME.lnk" "$SHORTCUT_PATH_QUICKLAUNCH"
        ${EndIf}
      ${EndIf}

      ReadINIStr $1 "${APP_INSTALLER_INI}" "Install" "StartMenuShortcuts"
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
    ${EndIf}
FunctionEnd
!endif

Section "Install Add-ons" InstallAddons
    StrCpy $ADDON_INDEX 0
    ReadINIStr $ADDON_LIST "${INIPATH}" "${INSTALLER_NAME}" "Addons"
    ${If} $ADDON_LIST == ""
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.xpi" "InstallAddon"
    ${Else}
      ${While} 1 == 1
        IntOp $ADDON_LIST_INDEX $ADDON_LIST_INDEX + 1
        ${WordFind} $ADDON_LIST " " "+$ADDON_LIST_INDEX" $ADDON_NAME
        ${If} $ADDON_LIST_INDEX > 1
          ${IfThen} $ADDON_NAME == $ADDON_LIST ${|} ${Break} ${|}
        ${EndIf}
        StrCpy $R7 $ADDON_NAME
        Call InstallAddon
      ${EndWhile}
    ${EndIf}
SectionEnd

Function "InstallAddon"
!ifdef NSIS_CONFIG_LOG
    LogSet on
!endif

    StrCpy $ADDON_FILE "$R7"
!ifdef NSIS_CONFIG_LOG
    LogText "*** InstallAddon: install $ADDON_FILE"
!endif

    ReadINIStr $ADDON_NAME "${INIPATH}" "$ADDON_FILE" "AddonId"
    ${If} $ADDON_NAME == ""
      ${GetBaseName} $ADDON_FILE $ADDON_NAME
      StrCpy $ADDON_NAME "$ADDON_NAME@${PRODUCT_DOMAIN}"
    ${EndIf}

!ifdef NSIS_CONFIG_LOG
    LogText "*** InstallAddon: ADDON_NAME = $ADDON_NAME"
!endif

    ReadINIStr $ADDON_TARGET_LOCATION "${INIPATH}" "$ADDON_FILE" "TargetLocation"
    ${If} $ADDON_TARGET_LOCATION != ""
      StrCpy $ADDON_DIR "$APP_DIR\$ADDON_TARGET_LOCATION\$ADDON_NAME"
    ${Else}
      StrCpy $ADDON_DIR "${APP_EXTENSIONS_DIR}\$ADDON_NAME"
    ${EndIf}
    ZipDLL::extractall "$EXEDIR\resources\$ADDON_FILE" "$ADDON_DIR"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledAddon$ADDON_INDEX" "$ADDON_DIR"

    IntOp $ADDON_INDEX $ADDON_INDEX + 1

!ifdef NSIS_CONFIG_LOG
    LogText "*** InstallAddon: $ADDON_NAME successfully installed"
!endif

;    Push $R0
FunctionEnd

Section "Install Additional Files" InstallAdditionalFiles
!ifdef NSIS_CONFIG_LOG
    LogSet on
!endif

    StrCpy $INSTALLED_FILE_INDEX 0

    StrCpy $DIST_DIR "$APP_DIR"
    ${If} ${FileExists} "$EXEDIR\resources\*.cfg"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.cfg" "InstallNormalFile"
    ${EndIf}
    ${If} ${FileExists} "$EXEDIR\resources\*.properties"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.properties" "InstallNormalFile"
    ${EndIf}

    StrCpy $DIST_DIR "$APP_DIR\defaults"
    ${If} ${FileExists} "$EXEDIR\resources\*.cer"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.cer" "InstallNormalFile"
    ${EndIf}
    ${If} ${FileExists} "$EXEDIR\resources\*.crt"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.crt" "InstallNormalFile"
    ${EndIf}
    ${If} ${FileExists} "$EXEDIR\resources\*.pem"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.pem" "InstallNormalFile"
    ${EndIf}
    ${If} ${FileExists} "$EXEDIR\resources\*.cer.override"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.cer.override" "InstallNormalFile"
    ${EndIf}
    ${If} ${FileExists} "$EXEDIR\resources\*.crt.override"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.crt.override" "InstallNormalFile"
    ${EndIf}
    ${If} ${FileExists} "$EXEDIR\resources\*.pem.override"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.pem.override" "InstallNormalFile"
    ${EndIf}

    StrCpy $DIST_DIR "$APP_DIR\defaults\profile"
    ${If} ${FileExists} "$EXEDIR\resources\bookmarks.html"
      ${Locate} "$EXEDIR\resources" "/L=F /M=bookmarks.html" "InstallNormalFile"
    ${EndIf}
    StrCpy $DIST_DIR "$APP_DIR\defaults\profile"
    ${If} ${FileExists} "$EXEDIR\resources\*.rdf"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.rdf" "InstallNormalFile"
    ${EndIf}

    StrCpy $DIST_DIR "${APP_CONFIG_DIR}"
    ${If} ${FileExists} "$EXEDIR\resources\*.js"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.js" "InstallNormalFile"
    ${EndIf}

    StrCpy $DIST_DIR "$APP_DIR\chrome"
    ${If} ${FileExists} "$EXEDIR\resources\*.css"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.css" "InstallNormalFile"
    ${EndIf}
    ${If} ${FileExists} "$EXEDIR\resources\*.jar"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.jar" "InstallNormalFile"
    ${EndIf}
    ${If} ${FileExists} "$EXEDIR\resources\*.manifest"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.manifest" "InstallNormalFile"
    ${EndIf}

!if ${APP_NAME} == "Netscape"
    ${If} ${FileExists} "$EXEDIR\resources\installed-chrome.txt"
      ${Locate} "$EXEDIR\resources" "/L=F /M=installed-chrome.txt" "AppendTextFile"
    ${EndIf}
!endif

    ${If} ${FileExists} "$EXEDIR\resources\*.lnk"
      StrCpy $DIST_DIR "$DESKTOP"
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.lnk" "InstallNormalFile"
;      StrCpy $DIST_DIR "$QUICKLAUNCH"
;      ${Locate} "$EXEDIR\resources" "/L=F /M=*.lnk" "InstallNormalFile"
;      StrCpy $DIST_DIR "$SMPROGRAMS"
;      ${Locate} "$EXEDIR\resources" "/L=F /M=*.lnk" "InstallNormalFile"
    ${EndIf}
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
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$INSTALLED_FILE_INDEXBackup" "$BACKUP_PATH"
    ${EndIf}
    CopyFiles /SILENT "$EXEDIR\resources\$PROCESSING_FILE" "$DIST_PATH"
    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$INSTALLED_FILE_INDEX" "$DIST_PATH"
    IntOp $INSTALLED_FILE_INDEX $INSTALLED_FILE_INDEX + 1

!ifdef NSIS_CONFIG_LOG
    LogText "*** InstallNormalFile: $PROCESSING_FILE is successfully installed"
!endif
    Push $R0
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
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$INSTALLED_FILE_INDEXBackup" "$BACKUP_PATH"
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

    WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$INSTALLED_FILE_INDEX" "$DIST_PATH"
    IntOp $INSTALLED_FILE_INDEX $INSTALLED_FILE_INDEX + 1

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
      ${Locate} "$APP_DIR\searchplugins" "/L=F /M=*.xml" "CheckDisableSearchPlugin"
    ${EndIf}
    ${If} "$FX_DISABLED_SEARCH_PLUGINS" == "*"
    ${OrIf} "$FX_DISABLED_SEARCH_PLUGINS" != ""
      ${Locate} "$APP_DIR\searchplugins" "/L=F /M=*.xml" "CheckDisableSearchPlugin"
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
      ${Locate} "$EXEDIR\resources" "/L=F /M=*.xml" "InstallNormalFile"
    ${EndIf}
SectionEnd

Function "CheckDisableSearchPlugin"
!ifdef NSIS_CONFIG_LOG
    LogSet on
!endif

    StrCpy $PROCESSING_FILE "$R7"

    ${If} "$FX_ENABLED_SEARCH_PLUGINS" != "*"
      ${WordFind} "$FX_ENABLED_SEARCH_PLUGINS" "$PROCESSING_FILE" "E+1{" $R0
      IfErrors NOTFOUND_IN_ENABLED FOUND_IN_ENABLED
      FOUND_IN_ENABLED:
        GoTo RETURN
      NOTFOUND_IN_ENABLED:
        GoTo DISABLE_SEARCH_PLUGIN
    ${EndIf}

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

    Push 0
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
      ${Locate} "$EXEDIR\resources" "/L=F /M=distribution.*" "InstallNormalFile"
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
    ${If} $APP_INSTALLED == "1"
      WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "InstalledAppVersion" "$APP_VERSION"
    ${EndIf}
SectionEnd

Section Uninstall
    StrCpy $UNINSTALL_FAILED 0

    StrCpy $INSTALLED_FILE_INDEX 0
    ${While} "0" == "0"
      ReadRegStr $INSTALLED_FILE HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$INSTALLED_FILE_INDEX"
      ReadRegStr $BACKUP_PATH HKLM "${PRODUCT_UNINST_KEY}" "InstalledFile$INSTALLED_FILE_INDEXBackup"
      ${IfThen} $INSTALLED_FILE == "" ${|} GoTo ConfigUninstallDone ${|}
      Delete "$INSTALLED_FILE"
      ${If} ${Errors}
      ${AndIf} ${FileExists} "$INSTALLED_FILE"
        StrCpy $UNINSTALL_FAILED 1
        GoTo ConfigUninstallDone
      ${EndIf}
      ${If} $BACKUP_PATH != ""
      ${AndIf} ${FileExists} "$BACKUP_PATH"
        Rename "$BACKUP_PATH" "$INSTALLED_FILE"
      ${EndIf}
      IntOp $INSTALLED_FILE_INDEX $INSTALLED_FILE_INDEX + 1
    ${EndWhile}
    ConfigUninstallDone:

    StrCpy $ADDON_INDEX 0
    ${While} "0" == "0"
      ReadRegStr $ADDON_DIR HKLM "${PRODUCT_UNINST_KEY}" "InstalledAddon$ADDON_INDEX"
      ${IfThen} $ADDON_DIR == "" ${|} GoTo AddonUninstallDone ${|}
      RMDir /r "$ADDON_DIR"
      ${If} ${Errors}
      ${AndIf} ${FileExists} "$PROCESSING_FILE"
        StrCpy $UNINSTALL_FAILED 1
        GoTo AddonUninstallDone
      ${EndIf}
      IntOp $ADDON_INDEX $ADDON_INDEX + 1
    ${EndWhile}
    AddonUninstallDone:

    ; search plugins
    ReadRegStr $BACKUP_PATH HKLM "${PRODUCT_UNINST_KEY}" "DisabledSearchPlugins"
    ReadRegStr $SEARCH_PLUGINS_PATH HKLM "${PRODUCT_UNINST_KEY}" "EnabledSearchPlugins"
    ${If} $BACKUP_PATH != ""
    ${AndIf} ${FileExists} "$BACKUP_PATH"
    ${AndIf} ${FileExists} "$BACKUP_PATH\*.xml"
      ${un.Locate} "$BACKUP_PATH" "/L=F /M=*.xml" "un.EnableSearchPlugin"
      ${Unless} ${FileExists} "$BACKUP_PATH\*.xml"
        RMDir /r "$BACKUP_PATH"
      ${EndUnless}
    ${EndIf}

    ; distributon customizer
    ReadRegStr $BACKUP_PATH HKLM "${PRODUCT_UNINST_KEY}" "DistributonCustomizerBackup"
    ReadRegStr $INSTALLED_FILE HKLM "${PRODUCT_UNINST_KEY}" "InstalledDistributonCustomizer"
    ${If} $INSTALLED_FILE != ""
      RMDir /r "$INSTALLED_FILE"
    ${EndIf}
    ${If} $BACKUP_PATH != ""
    ${AndIf} ${FileExists} "$BACKUP_PATH"
    ${AndIf} ${FileExists} "$BACKUP_PATH\*.*"
      Rename "$BACKUP_PATH" "$INSTALLED_FILE"
    ${EndIf}

    RMDir /r "$INSTDIR"
    DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"

    ${If} $UNINSTALL_FAILED == "1"
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
    Call CheckInstalled
    Call LoadINI
!ifdef PRODUCT_SILENT_INSTALL
    SetSilent silent
!endif
FunctionEnd

Function un.onInit
    Call un.CheckAppProc
!ifdef PRODUCT_SILENT_INSTALL
    SetSilent silent
!endif
!ifndef PRODUCT_SILENT_INSTALL
    MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(MSG_UNINST_CONFIRM)" IDYES +2
    Abort
!endif
    ReadRegStr $APP_VERSION HKLM "${PRODUCT_UNINST_KEY}" "InstalledAppVersion"
FunctionEnd

Function un.onUninstSuccess
    HideWindow
!ifndef PRODUCT_SILENT_INSTALL
    MessageBox MB_ICONINFORMATION|MB_OK "$(MSG_UNINST_SUCCESS)"
!endif

    ${un.GetParameters} $0
    ${un.GetOptions} "$0" "/AddonOnly" $1
    ${If} ${Errors}
    ${AndIf} $APP_VERSION != ""
      ReadRegStr $APP_VERSION HKLM "${APP_REG_KEY}" "CurrentVersion"
      StrCmp $APP_VERSION "" RETURN
      StrCpy $0 "${APP_REG_KEY}\$APP_VERSION\Main"
      ReadRegStr $APP_DIR HKLM $0 "Install Directory"
      StrCmp $APP_DIR "" RETURN

!if ${APP_NAME} == "Netscape"
      ${If} ${FileExists} "$APP_DIR\uninstall\install_wizard*.log"
!else
      ${If} ${FileExists} "$APP_DIR\uninstall\uninstall.log"
!endif
!ifndef APP_SILENT_INSTALL
        MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(MSG_UNINST_APP_CONFIRM)" IDYES +2
        GoTo SKIP_APP_UNINSTALLATION
!endif
!ifdef APP_SILENT_INSTALL
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
        SKIP_APP_UNINSTALLATION:
      ${EndIf}

      RETURN:
    ${EndIf}
FunctionEnd

;=== Utility functions
Function CheckInstalled
!ifdef NSIS_CONFIG_LOG
    LogSet on
!endif

    ReadRegStr $R0 HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
    ${If} $R0 != ""
!ifndef PRODUCT_SILENT_INSTALL
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
      ${IfThen} $APP_VERSION != "" ${|} StrCpy $APP_INSTALLED "1" ${|}
      ; アンインストーラを一時ファイルにコピーしないでそのまま実行
      ; こうしないと，すぐに終了して戻ってきてしまうみたい
      ExecWait '$R0 /AddonOnly _?=$INSTDIR'

    ${EndIf}
FunctionEnd

Function LoadINI
!ifdef NSIS_CONFIG_LOG
    LogSet on
!endif

    StrCpy $APP_DOWNLOAD_PATH "${APP_DOWNLOAD_PATH}"
    StrCpy $APP_EULA_PATH "${APP_EULA_PATH}"
    StrCpy $APP_DOWNLOAD_URL "${APP_DOWNLOAD_URL}"
    StrCpy $APP_EULA_URL "${APP_EULA_URL}"
    StrCpy $APP_HASH "${APP_HASH}"
    StrCpy $FX_ENABLED_SEARCH_PLUGINS "${FX_ENABLED_SEARCH_PLUGINS}"
    StrCpy $FX_DISABLED_SEARCH_PLUGINS "${FX_DISABLED_SEARCH_PLUGINS}"

    IfFileExists "${INIPATH}" "" NO_INI

!ifdef NSIS_CONFIG_LOG
    LogText "*** LoadINI: INI file exists"
!endif

    ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "AppDownloadPath"
!ifdef NSIS_CONFIG_LOG
    LogText "*** LoadINI: AppDownloadPath = $INI_TEMP"
!endif
    ${IfThen} $INI_TEMP != "" ${|} StrCpy $APP_DOWNLOAD_PATH "$INI_TEMP" ${|}
    ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "AppEulaPath"
!ifdef NSIS_CONFIG_LOG
    LogText "*** LoadINI: AppEulaPath = $INI_TEMP"
!endif
    ${IfThen} $INI_TEMP != "" ${|} StrCpy $APP_EULA_PATH "$INI_TEMP" ${|}
    ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "AppDownloadUrl"
!ifdef NSIS_CONFIG_LOG
    LogText "*** LoadINI: AppDownloadUrl = $INI_TEMP"
!endif
    ${IfThen} $INI_TEMP != "" ${|} StrCpy $APP_DOWNLOAD_URL "$INI_TEMP" ${|}
    ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "AppEulaUrl"
!ifdef NSIS_CONFIG_LOG
    LogText "*** LoadINI: AppEulaUrl = $INI_TEMP"
!endif
    ${IfThen} $INI_TEMP != "" ${|} StrCpy $APP_EULA_URL "$INI_TEMP" ${|}
    ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "AppHash"
!ifdef NSIS_CONFIG_LOG
    LogText "*** LoadINI: AppHash = $INI_TEMP"
!endif
    ${IfThen} $INI_TEMP != "" ${|} StrCpy $APP_HASH "$INI_TEMP" ${|}
    ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "AppInstallTalkback"
!ifdef NSIS_CONFIG_LOG
    LogText "*** LoadINI: AppInstallTalkback = $INI_TEMP"
!endif
    ${IfThen} $INI_TEMP != "" ${|} StrCpy $APP_INSTALL_TALKBACK "$INI_TEMP" ${|}
    ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "FxEnabledSearchPlugins"
!ifdef NSIS_CONFIG_LOG
    LogText "*** LoadINI: FxEnabledSearchPlugins = $INI_TEMP"
!endif
    ${IfThen} $INI_TEMP != "" ${|} StrCpy $FX_ENABLED_SEARCH_PLUGINS "$INI_TEMP" ${|}
    ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "FxDisabledSearchPlugins"
!ifdef NSIS_CONFIG_LOG
    LogText "*** LoadINI: FxDisabledSearchPlugins = $INI_TEMP"
!endif
    ${IfThen} $INI_TEMP != "" ${|} StrCpy $FX_DISABLED_SEARCH_PLUGINS "$INI_TEMP" ${|}

  NO_INI:
FunctionEnd

Function CheckAppProc
    FindProcDLL::FindProc "${APP_EXE}" $R0
    ${If} $R0 == "1"
      MessageBox MB_OK|MB_ICONINFORMATION `$(MSG_APP_IS_RUNNING)`
      Abort
    ${EndIf}
FunctionEnd

Function un.CheckAppProc
    FindProcDLL::FindProc "${APP_EXE}" $R0
    ${If} $R0 == "1"
      MessageBox MB_OK|MB_ICONINFORMATION `$(MSG_APP_IS_RUNNING)`
      Abort
    ${EndIf}
FunctionEnd

Function GetAppPath
!ifdef NSIS_CONFIG_LOG
    LogSet on
!endif

    ${IfThen} $APP_INSTALLED != "1" ${|} StrCpy $APP_INSTALLED "0" ${|}

!ifdef NSIS_CONFIG_LOG
    LogText "*** GetAppPath: Application installed"
!endif

    ReadRegStr $APP_VERSION HKLM "${APP_REG_KEY}" "CurrentVersion"
    StrCmp $APP_VERSION "" ERR
    StrCpy $0 "${APP_REG_KEY}\$APP_VERSION\Main"

    ; EXE path
    ReadRegStr $APP_EXE_PATH HKLM $0 "PathToExe"
    StrCmp $APP_EXE_PATH "" ERR

!ifdef NSIS_CONFIG_LOG
    LogText "*** GetAppPath: APP_EXE_PATH = $APP_EXE_PATH"
!endif

    ; Application directory
    ReadRegStr $APP_DIR HKLM $0 "Install Directory"
    StrCmp $APP_DIR "" ERR

!ifdef NSIS_CONFIG_LOG
    LogText "*** GetAppPath: APP_DIR = $APP_DIR"
!endif

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
!endif

    ${VersionConvert} "$NORMALIZED_APP_VERSION" "abcdefghijklmnopqrstuvwxyz" $APP_VERSION_NUM
    StrCpy $APP_WRONG_VERSION "0"

    ${IfThen} $APP_EXISTS != "1" ${|} GoTo RETURN ${|}

!ifdef NSIS_CONFIG_LOG
    LogText "*** CheckAppVersion: Application exists"
!endif

    ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "AppMaxVersion"
    ${IfThen} $INI_TEMP == "" ${|} StrCpy $INI_TEMP "${APP_MAX_VERSION}" ${|}
    ${VersionConvert} "$INI_TEMP" "abcdefghijklmnopqrstuvwxyz" $NORMALIZED_VERSION
    ${VersionCompare} "$APP_VERSION_NUM" "$NORMALIZED_VERSION" $0

    ${If} $0 == 1
      StrCpy $APP_WRONG_VERSION "2"
!ifdef NSIS_CONFIG_LOG
      LogText "*** CheckAppVersion: Installed version is too new"
!endif
      GoTo RETURN
    ${EndIf}

    ReadINIStr $INI_TEMP "${INIPATH}" "${INSTALLER_NAME}" "AppMinVersion"
    ${IfThen} $INI_TEMP == "" ${|} StrCpy $INI_TEMP "${APP_MIN_VERSION}" ${|}
    ${VersionConvert} "$INI_TEMP" "abcdefghijklmnopqrstuvwxyz" $NORMALIZED_VERSION
    ${VersionCompare} "$APP_VERSION_NUM" "$NORMALIZED_VERSION" $0
    ${If} $0 == 2
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

    ${IfThen} $APP_EXISTS != "1" ${|} GoTo RETURN ${|}

    Call CheckAppVersion

!ifdef NSIS_CONFIG_LOG
    LogText "*** CheckAppVersionWithMessage: APP_WRONG_VERSION = $APP_WRONG_VERSION"
!endif
    ${Switch} $APP_WRONG_VERSION

      ${Case} 1
        MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION "$(MSG_APP_VERSION_TOO_LOW_CONFIRM)" IDOK RETURN
        MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_VERSION_TOO_LOW_ERROR)" /SD IDOK
        Abort
        ${Break}

      ${Case} 2
        MessageBox MB_OK|MB_ICONEXCLAMATION "$(MSG_APP_VERSION_TOO_HIGH_ERROR)" /SD IDOK
        Abort
        ${Break}

    ${EndSwitch}

  RETURN:
FunctionEnd
