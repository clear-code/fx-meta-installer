;Copyright (C) 2008-2012 ClearCode Inc.

!define PRODUCT_FULL_NAME   "FxMetaInstaller build helper"
!define PRODUCT_NAME        "helper"
!define PRODUCT_VERSION     "0.1.0.2"
!define PRODUCT_YEAR        "2012"
!define PRODUCT_PUBLISHER   "ClearCode Inc."
!define PRODUCT_DOMAIN      "clear-code.com"
!define PRODUCT_WEB_SITE    "http://www.clear-code.com/"

!define INIPATH             "$EXEDIR\..\fainstall.ini"
!define PRODUCT_NAME_PATH   "$EXEDIR\..\product.txt"

;=== Program Details
Name    "${PRODUCT_FULL_NAME}"
OutFile "${PRODUCT_NAME}.exe"

RequestExecutionLevel user

VIProductVersion                 "${PRODUCT_VERSION}"
VIAddVersionKey FileDescription  "${PRODUCT_FULL_NAME}"
VIAddVersionKey LegalCopyright   "${PRODUCT_YEAR} ${PRODUCT_PUBLISHER}"
VIAddVersionKey Comments         ""
VIAddVersionKey CompanyName      "${PRODUCT_PUBLISHER}"
VIAddVersionKey OriginalFilename "${PRODUCT_NAME}.exe"
VIAddVersionKey FileVersion      "${PRODUCT_VERSION}"

;=== Runtime Switches
CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True

;=== Variables
Var ADDON_FILE
Var ADDON_NAME
Var FILE_HANDLER

Var PRODUCT_NAME
Var APP_MIN_VERSION
Var APP_MAX_VERSION
Var APP_DOWNLOAD_PATH
Var APP_DOWNLOAD_URL
Var APP_EULA_PATH
Var APP_EULA_URL
Var APP_HASH
Var APP_ENABLE_CRASH_REPORT
Var APP_ALLOW_DOWNGRADE
Var FX_ENABLED_SEARCH_PLUGINS
Var FX_DISABLED_SEARCH_PLUGINS

;=== Libraries
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!include "TextFunc.nsh"
!include "WordFunc.nsh"
!insertmacro Locate
!include "ZipDLL.nsh"
!include "XML.nsh"

Section "Make INI File" MakeINI
    ${If} ${FileExists} "${INIPATH}"
      Delete "${INIPATH}"
    ${EndIf}
    ${If} ${FileExists} "${PRODUCT_NAME_PATH}"
      Delete "${PRODUCT_NAME_PATH}"
    ${EndIf}

    ${LineFind} "..\config.nsh" "NUL" "1:-1" "ReadConfigurations"

    FileOpen $FILE_HANDLER "${INIPATH}" w

    FileWrite $FILE_HANDLER "[fainstall]$\r$\n"
    FileWrite $FILE_HANDLER "AppMinVersion=$APP_MIN_VERSION$\r$\n"
    FileWrite $FILE_HANDLER "AppMaxVersion=$APP_MAX_VERSION$\r$\n"
    FileWrite $FILE_HANDLER "AppDownloadPath=$APP_DOWNLOAD_PATH$\r$\n"
    FileWrite $FILE_HANDLER "AppDownloadUrl=$APP_DOWNLOAD_URL$\r$\n"
    FileWrite $FILE_HANDLER "AppEulaPath=$APP_EULA_PATH$\r$\n"
    FileWrite $FILE_HANDLER "AppEulaUrl=$APP_EULA_URL$\r$\n"
    FileWrite $FILE_HANDLER "AppHash=$APP_HASH$\r$\n"
    FileWrite $FILE_HANDLER "AppEnableCrashReport=$APP_ENABLE_CRASH_REPORT$\r$\n"
    FileWrite $FILE_HANDLER "AppAllowDowngrade=$APP_ALLOW_DOWNGRADE$\r$\n"
    FileWrite $FILE_HANDLER "CleanInstallPreferredTitle=$\r$\n"
    FileWrite $FILE_HANDLER "CleanInstallPreferredMessage=$\r$\n"
    FileWrite $FILE_HANDLER "CleanInstallRequiredTitle=$\r$\n"
    FileWrite $FILE_HANDLER "CleanInstallRequiredMessage=$\r$\n"
    FileWrite $FILE_HANDLER "FinishTitle=$\r$\n"
    FileWrite $FILE_HANDLER "FinishMessage=$\r$\n"
    FileWrite $FILE_HANDLER "FxEnabledSearchPlugins=$FX_ENABLED_SEARCH_PLUGINS$\r$\n"
    FileWrite $FILE_HANDLER "FxDisabledSearchPlugins=$FX_DISABLED_SEARCH_PLUGINS$\r$\n"
    FileWrite $FILE_HANDLER "$\r$\n"

    ${Locate} "$EXEDIR\..\resources" "/L=F /M=*.xpi" "AddFileEntry"
    FileClose $FILE_HANDLER

    FileOpen $FILE_HANDLER "${PRODUCT_NAME_PATH}" w
    FileWrite $FILE_HANDLER "$PRODUCT_NAME"
    FileClose $FILE_HANDLER
SectionEnd

Var LINE
Var TEMP_STRING
Var CONFIG_KEY
Var CONFIG_VALUE
Function "ReadConfigurations"
    StrCpy $LINE "$R9"

    ; Ignore blank lines
    ${If} $LINE == "$\r$\n"
    ${OrIf} $LINE == "$\n"
    ${OrIf} $LINE == "$\r"
      GoTo RETURN
    ${EndIf}

    ; Ignore comments
    ${WordFind} "$LINE" ";" "+1*}" $TEMP_STRING
    ${IfThen} $TEMP_STRING != $LINE ${|} GoTo RETURN ${|}

    ${WordFind} "$TEMP_STRING" "!define " "+1*}" $TEMP_STRING
    ${WordFind} "$TEMP_STRING" " " "+1{*" $CONFIG_KEY
    ${WordFind} "$TEMP_STRING" " " "+2*}" $CONFIG_VALUE
    ${WordFind} "$CONFIG_VALUE" '"' "+1" $CONFIG_VALUE

    ${If} $CONFIG_KEY == "PRODUCT_NAME"
      StrCpy $PRODUCT_NAME "$CONFIG_VALUE"
    ${ElseIf} $CONFIG_KEY == "APP_MIN_VERSION"
      StrCpy $APP_MIN_VERSION "$CONFIG_VALUE"
    ${ElseIf} $CONFIG_KEY == "APP_MAX_VERSION"
      StrCpy $APP_MAX_VERSION "$CONFIG_VALUE"
    ${ElseIf} $CONFIG_KEY == "APP_DOWNLOAD_PATH"
      StrCpy $APP_DOWNLOAD_PATH "$CONFIG_VALUE"
    ${ElseIf} $CONFIG_KEY == "APP_DOWNLOAD_URL"
      StrCpy $APP_DOWNLOAD_URL "$CONFIG_VALUE"
    ${ElseIf} $CONFIG_KEY == "APP_EULA_PATH"
      StrCpy $APP_EULA_PATH "$CONFIG_VALUE"
    ${ElseIf} $CONFIG_KEY == "APP_EULA_URL"
      StrCpy $APP_EULA_URL "$CONFIG_VALUE"
    ${ElseIf} $CONFIG_KEY == "APP_HASH"
      StrCpy $APP_HASH "$CONFIG_VALUE"
    ${ElseIf} $CONFIG_KEY == "APP_ENABLE_CRASH_REPORT"
      StrCpy $APP_ENABLE_CRASH_REPORT "true"
    ${ElseIf} $CONFIG_KEY == "APP_ALLOW_DOWNGRADE"
      StrCpy $APP_ALLOW_DOWNGRADE "true"
    ${ElseIf} $CONFIG_KEY == "FX_ENABLED_SEARCH_PLUGINS"
      StrCpy $FX_ENABLED_SEARCH_PLUGINS "$CONFIG_VALUE"
    ${ElseIf} $CONFIG_KEY == "FX_DISABLED_SEARCH_PLUGINS"
      StrCpy $FX_DISABLED_SEARCH_PLUGINS "$CONFIG_VALUE"
    ${EndIf}

  RETURN:
    Push "SkipWrite"
FunctionEnd

Function "AddFileEntry"
    StrCpy $ADDON_FILE "$R7"

    FileWrite $FILE_HANDLER "[$ADDON_FILE]$\r$\n"

    ZipDLL::extractfile "$R9" "$EXEDIR" "install.rdf"
    ${xml::LoadFile} "install.rdf" $0

    StrCpy $ADDON_NAME ""

    ${If} $ADDON_NAME == ""
      ; case1-1: element style without prefix
      ${xml::GotoPath} "/RDF/Description/em:id" $0
      ${xml::GetText} $0 $1
      StrCpy $ADDON_NAME $0
    ${EndIf}
    ${If} $ADDON_NAME == ""
      ; case1-2: element style with prefix
      ${xml::GotoPath} "/RDF:RDF/RDF:Description/em:id" $0
      ${xml::GetText} $0 $1
      StrCpy $ADDON_NAME $0
    ${EndIf}
    ${If} $ADDON_NAME == ""
      ; case1-3: element style with prefix (small)
      ${xml::GotoPath} "/rdf:RDF/rdf:Description/em:id" $0
      ${xml::GetText} $0 $1
      StrCpy $ADDON_NAME $0
    ${EndIf}
    ${If} $ADDON_NAME == ""
      ; case2-1: attribute style without prefix
      ${xml::GotoPath} "/RDF/Description" $0
      ${xml::GetAttribute} "em:id" $0 $1
      StrCpy $ADDON_NAME $0
    ${EndIf}
    ${If} $ADDON_NAME == ""
      ; case2-2: attribute style with prefix
      ${xml::GotoPath} "/RDF:RDF/RDF:Description" $0
      ${xml::GetAttribute} "em:id" $0 $1
      StrCpy $ADDON_NAME $0
    ${EndIf}
    ${If} $ADDON_NAME == ""
      ; case2-3: attribute style with prefix (small)
      ${xml::GotoPath} "/rdf:RDF/rdf:Description" $0
      ${xml::GetAttribute} "em:id" $0 $1
      StrCpy $ADDON_NAME $0
    ${EndIf}

    ${xml::Unload}
    Delete "$EXEDIR\install.rdf"

    FileWrite $FILE_HANDLER "AddonId=$ADDON_NAME$\r$\n"
    FileWrite $FILE_HANDLER "$\r$\n"

FunctionEnd
