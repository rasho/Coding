CreateObject( "WScript.Shell" ).Run "PowerShell -Command ""EnsureProcessIsRunning -Name 'Autohotkey' -Path 'C:\Program Files\AutoHotkey-v2\AutoHotkeyU64.exe' -Args ((${HOME})+('\Documents\GitHub\Coding\ahk\_WindowsHotkeys.ahkv2')) -AsAdmin -Quiet;"" ", 0, True

' ------------------------------------------------------------
'
' Create a Scheduled Task (which targets this script) by using the following values:
'
'   Trigger:
'     At log on
'
'   Action:
'     Program/script:   C:\Windows\System32\wscript.exe
'     Add arguments:    "%USERPROFILE%\Documents\GitHub\Coding\visual basic\_WindowsHotkeysAsAdmin.vbs"
'
'   Run only when user is logged on (CHECKED)
'   Run with highest privileges (CHECKED)
'
' ------------------------------------------------------------
'
' Citation(s)
'
'   www.autohotkey.com  |  "Autohotkey Version 2 Downloads"  |  https://www.autohotkey.com/download/2.0/
'
' ------------------------------------------------------------