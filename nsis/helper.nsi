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

;=== Libraries
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!insertmacro Locate
!include "ZipDLL.nsh"
!include "XML.nsh"

Section "Make INI File" MakeINI
    ${If} ${FileExists} "${INIPATH}"
      Delete "${INIPATH}"
    ${EndIf}

    FileOpen $INI_FILE "${INIPATH}" w

    FileWrite $INI_FILE "[fainstall]$\r$\n"
    FileWrite $INI_FILE "AppDownloadPath=$\r$\n"
    FileWrite $INI_FILE "AppDownloadUrl=$\r$\n"
    FileWrite $INI_FILE "AppEulaPath=$\r$\n"
    FileWrite $INI_FILE "AppEulaUrl=$\r$\n"
    FileWrite $INI_FILE "AppHash=$\r$\n"
    FileWrite $INI_FILE "AppInstallTalkback=true$\r$\n"
    FileWrite $INI_FILE "$\r$\n"

    ${Locate} "$EXEDIR\..\resources" "/L=F /M=*.xpi" "AddEntry"
    FileClose $INI_FILE
SectionEnd

Function "AddEntry"
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
