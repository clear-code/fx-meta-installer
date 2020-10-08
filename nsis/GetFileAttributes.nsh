; https://nsis.sourceforge.io/GetFileAttributes

Function GetFileAttributes
  !define GetFileAttributes `!insertmacro GetFileAttributesCall`
 
  !macro GetFileAttributesCall _PATH _ATTR _RESULT
    Push `${_PATH}`
    Push `${_ATTR}`
    Call GetFileAttributes
    Pop ${_RESULT}
  !macroend
 
  Exch $1
  Exch
  Exch $0
  Exch
  Push $2
  Push $3
  Push $4
  Push $5
 
  System::Call 'kernel32::GetFileAttributes(t r0)i .r2'
  StrCmp $2 -1 error
  StrCpy $3 ''
 
  IntOp $0 $2 & 0x4000
  IntCmp $0 0 +2
  StrCpy $3 'ENCRYPTED|'
 
  IntOp $0 $2 & 0x2000
  IntCmp $0 0 +2
  StrCpy $3 'NOT_CONTENT_INDEXED|$3'
 
  IntOp $0 $2 & 0x1000
  IntCmp $0 0 +2
  StrCpy $3 'OFFLINE|$3'
 
  IntOp $0 $2 & 0x0800
  IntCmp $0 0 +2
  StrCpy $3 'COMPRESSED|$3'
 
  IntOp $0 $2 & 0x0400
  IntCmp $0 0 +2
  StrCpy $3 'REPARSE_POINT|$3'
 
  IntOp $0 $2 & 0x0200
  IntCmp $0 0 +2
  StrCpy $3 'SPARSE_FILE|$3'
 
  IntOp $0 $2 & 0x0100
  IntCmp $0 0 +2
  StrCpy $3 'TEMPORARY|$3'
 
  IntOp $0 $2 & 0x0080
  IntCmp $0 0 +2
  StrCpy $3 'NORMAL|$3'
 
  IntOp $0 $2 & 0x0040
  IntCmp $0 0 +2
  StrCpy $3 'DEVICE|$3'
 
  IntOp $0 $2 & 0x0020
  IntCmp $0 0 +2
  StrCpy $3 'ARCHIVE|$3'
 
  IntOp $0 $2 & 0x0010
  IntCmp $0 0 +2
  StrCpy $3 'DIRECTORY|$3'
 
  IntOp $0 $2 & 0x0004
  IntCmp $0 0 +2
  StrCpy $3 'SYSTEM|$3'
 
  IntOp $0 $2 & 0x0002
  IntCmp $0 0 +2
  StrCpy $3 'HIDDEN|$3'
 
  IntOp $0 $2 & 0x0001
  IntCmp $0 0 +2
  StrCpy $3 'READONLY|$3'
 
  StrCpy $0 $3 -1
  StrCmp $1 '' end
  StrCmp $1 'ALL' end
 
  attrcmp:
  StrCpy $5 0
  IntOp $5 $5 + 1
  StrCpy $4 $1 1 $5
  StrCmp $4 '' +2
  StrCmp $4 '|'  0 -3
  StrCpy $2 $1 $5
  IntOp $5 $5 + 1
  StrCpy $1 $1 '' $5
  StrLen $3 $2
  StrCpy $5 -1
  IntOp $5 $5 + 1
  StrCpy $4 $0 $3 $5
  StrCmp $4 '' notfound
  StrCmp $4 $2 0 -3
  StrCmp $1 '' 0 attrcmp
  StrCpy $0 1
  goto end
 
  notfound:
  StrCpy $0 0
  goto end
 
  error:
  SetErrors
  StrCpy $0 ''
 
  end:
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Exch $0
FunctionEnd
