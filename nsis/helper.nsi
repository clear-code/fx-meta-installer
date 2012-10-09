;Copyright (C) 2008-2012 ClearCode Inc.

!define PRODUCT_FULL_NAME   "FxMetaInstaller build helper"
!define PRODUCT_NAME        "helper"
!define PRODUCT_VERSION     "0.1.0.2"
!define PRODUCT_YEAR        "2012"
!define PRODUCT_PUBLISHER   "ClearCode Inc."
!define PRODUCT_DOMAIN      "clear-code.com"
!define PRODUCT_WEB_SITE    "http://www.clear-code.com/"

!define INIPATH             "$EXEDIR\..\fainstall.ini"

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
Var INI_FILE

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

    ${LineFind} "..\config.nsh" "NUL" "1:-1" "ReadConfigurations"

    FileOpen $INI_FILE "${INIPATH}" w

    FileWrite $INI_FILE "[fainstall]$\r$\n"
    FileWrite $INI_FILE "AppMinVersion=$APP_MIN_VERSION$\r$\n"
    FileWrite $INI_FILE "AppMaxVersion=$APP_MAX_VERSION$\r$\n"
    FileWrite $INI_FILE "AppDownloadPath=$APP_DOWNLOAD_PATH$\r$\n"
    FileWrite $INI_FILE "AppDownloadUrl=$APP_DOWNLOAD_URL$\r$\n"
    FileWrite $INI_FILE "AppEulaPath=$APP_EULA_PATH$\r$\n"
    FileWrite $INI_FILE "AppEulaUrl=$APP_EULA_URL$\r$\n"
    FileWrite $INI_FILE "AppHash=$APP_HASH$\r$\n"
    FileWrite $INI_FILE "AppEnableCrashReport=$APP_ENABLE_CRASH_REPORT$\r$\n"
    FileWrite $INI_FILE "AppAllowDowngrade=$APP_ALLOW_DOWNGRADE$\r$\n"
    FileWrite $INI_FILE "CleanInstallPreferredTitle=$\r$\n"
    FileWrite $INI_FILE "CleanInstallPreferredMessage=$\r$\n"
    FileWrite $INI_FILE "CleanInstallRequiredTitle=$\r$\n"
    FileWrite $INI_FILE "CleanInstallRequiredMessage=$\r$\n"
    FileWrite $INI_FILE "FxEnabledSearchPlugins=$FX_ENABLED_SEARCH_PLUGINS$\r$\n"
    FileWrite $INI_FILE "FxDisabledSearchPlugins=$FX_DISABLED_SEARCH_PLUGINS$\r$\n"
    FileWrite $INI_FILE "$\r$\n"

    ${Locate} "$EXEDIR\..\resources" "/L=F /M=*.xpi" "AddFileEntry"
    FileClose $INI_FILE
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

    ${If} $CONFIG_KEY == "APP_MIN_VERSION"
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

    FileWrite $INI_FILE "[$ADDON_FILE]$\r$\n"

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

    FileWrite $INI_FILE "AddonId=$ADDON_NAME$\r$\n"
    FileWrite $INI_FILE "$\r$\n"

FunctionEnd
