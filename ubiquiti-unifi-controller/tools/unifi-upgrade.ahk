; Do you want to upgrade your UniFi 5.3.8 to 5.4.9?
WinWait, UniFi Network application Setup,,90
IfNotEqual, ErrorLevel, 0, exit 0
ControlSend,, !y, UniFi Network application Setup
WinWaitClose
; It is recommended that you create a backup before installing a new version. Do you have a backup?
WinWait, UniFi Network application Setup,,90
IfNotEqual, ErrorLevel, 0, exit 0
ControlSend,, !y, UniFi Network application Setup
WinWaitClose