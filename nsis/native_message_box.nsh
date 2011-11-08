!macro NativeMessageBox flags title message out
   System::Call "user32::MessageBox(i $HWNDPARENT, t '${message}', t '${title}', i ${flags}) i.s"
   Pop ${out}
!macroend
; see http://msdn.microsoft.com/en-us/library/windows/desktop/ms645505%28v=vs.85%29.aspx
!define NATIVE_MB_OK              0x000000
!define NATIVE_MB_YESNO           0x000004
!define NATIVE_MB_ICONQUESTION    0x000020
!define NATIVE_MB_ICONEXCLAMATION 0x000030
!define NATIVE_MB_ICONINFORMATION 0x000040
!define NATIVE_MB_DEFBUTTON2      0x000100
!define NATIVE_MB_BUTTON_YES      6
!define NATIVE_MB_BUTTON_NO       7

