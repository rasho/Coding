@ECHO OFF

:: Reset Windows Spotlight
DEL /F /S /Q /A "%USERPROFILE%/AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
DEL /F /S /Q /A "%USERPROFILE%/AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\Settings"

:: Re-register Windows Spotlight
REM PowerShell -ExecutionPolicy Unrestricted -Command "& {$ManifestPath = (Get-AppxPackage *ContentDeliveryManager*).InstallLocation + '\AppxManifest.xml' ; Add-AppxPackage -DisableDevelopmentMode -Register $ManifestPath}"
PowerShell -ExecutionPolicy Unrestricted -Command "& {Get-AppxPackage -User ($(whoami)) -Name 'Microsoft.Windows.ContentDeliveryManager' | ForEach { Add-AppxPackage -Path (($_.InstallLocation)+('\AppxManifest.xml')) -DisableDevelopmentMode -Register; }}"


TIMEOUT /T 30



REM ------------------------------------------------------------
REM
REM REM CLEAR OUT SAVED GROUP-POLICY SETTINGS FOUND IN REGEDIT
REM
REM -- HKCU
REM HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CloudContent\
REM HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen\
REM HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\AppSync
REM
REM -- HKLM
REM HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent\
REM HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\SettingSync\
REM
REM ------------------------------------------------------------



REM ------------------------------------------------------------
REM
REM	DEFINE A FEW REGEDIT KEYS
REM
REM	HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\SettingSync   (KEY)
REM		|--> "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\SettingSync\DisableSettingSync" --> DELETE
REM		|--> "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\SettingSync\DisableSettingSyncUserOverride" --> CREATE AS A "DWORD" WITH VALUE "1"
REM
REM	HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\AppSync   (KEY)
REM		|--> "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\SettingSync\DisableSettingSync" --> DELETE
REM		|--> "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\SettingSync\DisableSettingSyncUserOverride" --> CREATE AS A "DWORD" WITH VALUE "1"
REM
REM
REM
REM ------------------------------------------------------------



REM	------------------------------------------------------------
REM
REM	Citation(s)
REM
REM		tenforums.com  |  "How to Reset and Re-register Windows Spotlight in Windows 10"  |  https://www.tenforums.com/tutorials/82156-reset-re-register-windows-spotlight-windows-10-a.html
REM
REM		techdows.com  |  "Fix Windows 10 Lock Screen Settings page shows ‘Some Settings are managed by your organization’ Message"  |  https://techdows.com/2015/09/fix-windows-10-lock-screen-some-settings-are-managed-by-your-organization.html
REM
REM		appuals.com  |  "How to Fix ‘some settings are managed by your organization’"  |  https://appuals.com/how-to-fix-some-settings-are-managed-by-your-organization/
REM
REM		docs.microsoft.com  |  "Windows Settings details"  |  https://docs.microsoft.com/en-us/azure/active-directory/devices/enterprise-state-roaming-windows-settings-reference#windows-settings-details
REM
REM	------------------------------------------------------------