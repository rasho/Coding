function SyncRegistry {
	Param(
	)

	If ((RunningAsAdministrator) -Ne ($True)) {

		PrivilegeEscalation -Command ("SyncRegistry");
	
	} Else {

		# ------------------------------------------------------------
		# Define any Network Maps which will be required during the runtime
		#  (Registry Root-Keys are actually Network Maps to the "Registry" PSProvider)

		$PSDrives = @();

		$PSDrives += @{
			Name="HKLM";
			PSProvider="Registry";
			Root="HKEY_LOCAL_MACHINE";
		};

		$PSDrives += @{
			Name="HKCC";
			PSProvider="Registry";
			Root="HKEY_CURRENT_CONFIG";
		};

		$PSDrives += @{
			Name="HKCR";
			PSProvider="Registry";
			Root="HKEY_CLASSES_ROOT";
		};

		$PSDrives += @{
			Name="HKU";
			PSProvider="Registry";
			Root="HKEY_USERS";
		};

		$PSDrives += @{
			Name="HKCU";
			PSProvider="Registry";
			Root="HKEY_CURRENT_USER";
		};

		$PSDrives += @{
			Name=$Null;
			PSProvider="Registry";
			Root="HKEY_PERFORMANCE_DATA";
		};

		$PSDrives += @{
			Name=$Null;
			PSProvider="Registry";
			Root="HKEY_DYN_DATA";
		};


		# ------------------------------------------------------------

		$RegEdits = @();

		# Explorer Settings
		$RegEdits += @{
			Path = "HKCU:\Software\Policies\Microsoft\Windows\Explorer";
			Props=@(
				@{
					Description="Set to [ 1 ] to Disable or [ 0 ] to Enable `"Aero Shake`" in Windows 10";
					Name="NoWindowMinimizingShortcuts"; 
					Type="DWord";
					Value=1;
					Delete=$False;
				}
			)
		};

		# Stop Windows from making sure all apps close when Shutting-Down/Restarting/etc. (Disables the 'This App is Preventing Shutdown or Restart' screen before Shutdown/Restart)
		$RegEdits += @{
			Path = "HKCU:\Control Panel\Desktop";
			Props=@(
				@{
					Description="Set to [ 1 ] to Disable or [ 0 ] to Enable the 'This App is Preventing Shutdown or Restart' screen, which appears while attempting Shutdown/Restart the machine while certain inspecific applications are running - Remove this key/val to show this screen, instead";
					Name="AutoEndTasks"; 
					Type="String";
					Value=1;
					Delete=$False;
				}
			)
		};

		$DefaultPictureEditor="C:\Program Files\paint.net\PaintDotNet.exe";
		If ((Test-Path -Path "${DefaultPictureEditor}") -Eq $True) {
			# Set default application to use when user clicks "Edit" after right-clicking an image-file in Explorer
			#   |--> Explorer -> Image-File (.png, .jpg, ...) -> Right-Click -> Edit -> Opens app held in [v THIS v] RegEdit Key/Val
			$RegEdits += @{
				Path = "HKCR:\SystemFileAssociations\image\shell\edit\command";
				Props=@(
					@{
						Description="Defines the application opened when a user right-clicks an Image file (in Windows Explorer) and selects the `"Edit`" command.";
						Name="(Default)"; 
						Type="REG_EXPAND_SZ";
						Val_Default="`"%systemroot%\system32\mspaint.exe`" `"%1`"";
						Value=(("`"")+(${DefaultPictureEditor})+("`" `"%1`""));
						Delete=$False;
					}
				)
			};
		}

		# Search / Cortana Settings
		$RegEdits += @{
			Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Search";
			Props=@(
				@{
					Description="Set to [ 1 ] to Enable or [ 0 ] to Disable Cortana's ability to send search-resutls to Bing.com.";
					Hotfix="Enabling fixes a bug where Cortana eats 30-40% CPU resources (KB4512941).";
					Name="BingSearchEnabled";
					Type="DWord";
					Value=1;
					Delete=$False;
				},
				@{
					Description=$Null;
					Name="AllowSearchToUseLocation";
					Type="DWord";
					Value=0;
					Delete=$False;
				}
			)
		};

		# Search / Cortana Settings (continued)
		$RegEdits += @{
			Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search";
			Props=@(
				@{
					Description=$Null;
					Name="AllowCortana";
					Type="DWord";
					Value=0;
					Delete=$False;
				},
				@{
					Description=$Null;
					Name="ConnectedSearchUseWeb";
					Type="DWord";
					Value=0;
					Delete=$False;
				},
				@{
					Description=$Null;
					Name="ConnectedSearchUseWebOverMeteredConnections";
					Type="DWord";
					Value=0;
					Delete=$False;
				},
				@{
					Description=$Null;
					Name="DisableWebSearch";
					Type="DWord";
					Value=1;
					Delete=$False;
				}
			)
		};

		# Windows Update - Force-pull from Windows instaed of local server
		$RegEdits += @{
			Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU";
			Props=@(
				@{
					Description="Set this value to [ 1 ] to configure Automatic Updates to use a server that is running Software Update Services instead of Windows Update ( from https://docs.microsoft.com/en-us/windows/deployment/update/waas-wu-settings )";
					Name="UseWUServer";
					Type="DWord";
					Value=0;
					Delete=$False;
				}
			)
		};

		$RegEdits += @{
			Path="HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing";
			Props=@(
				@{
					Description="Sets the value (string) for the option named [ Alternate source file path ] under Group-Policy [ 'Computer Configuration' -> 'Administrative Templates' -> 'System' -> 'Specify settings for optional component installation and component repair setting.'";
					Name="LocalSourcePath";
					Type="ExpandString";
					Value="";
					Delete=$False;
				},
				@{
					Description="Sets the value (checkbox, check=2, unchecked=delete-the-key) for the option named [ Download repair content and optional features directly from Windows Update isntead of Windows Server Update Services (WSUS) ] under Group-Policy [ 'Computer Configuration' -> 'Administrative Templates' -> 'System' -> 'Specify settings for optional component installation and component repair setting.'";
					Name="RepairContentServerSource";
					Type="DWord";
					Value=2;
					Delete=$False;
				},
				@{
					Description="Sets the value (checkbox, check=2, unchecked=delete-the-key) for the option named [ Never attempt to download payload from Windows Update ] under Group-Policy [ 'Computer Configuration' -> 'Administrative Templates' -> 'System' -> 'Specify settings for optional component installation and component repair setting.'";
					Name="UseWindowsUpdate";
					Type="DWord";
					Value=2;
					Delete=$True;
				}
			)
		};

		# Windows - Command which is called when "WinKey + L" is pressed
		$RegEdits += @{
			Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System";
			Props=@(
				@{
					Description="Set this value to [ 1 ] to disable `"Lock Workstation`" in Windows";
					Name="DisableLockWorkstation";
					Type="DWord";
					Value=0;
					Delete=$False;
				}
			)
		};

		# ------------------------------------------------------------
		# Environment-specific registry settings
		#
		If ( $False ) {

			# VMware vSphere Client Cached-Connections
			$RegEdits += @{
				Path = "HKCU:\Software\VMware\VMware Infrastructure Client\Preferences";
				Props=@(
					@{
						Description="Defines the vSphere Client's [ IP address/ Name ] cached connection-urls";
						Name="RecentConnections"; 
						Type="String";
						Value="";
						Delete=$False;
					}
				)
			};

			# VMware vSphere Client Cached-Connections
			$RegEdits += @{
				Path = "HKCU:\Software\Policies\Microsoft\CloudFiles\BlockedApps\*";
				Props=@(
					@{
						Description="Blocks (1) or Unblocks (0) Apps from being able to trigger the OneDrive's `"Files On-Demand`" feature";
						Name="Enabled"; 
						Type="DWord";
						Value=1;
						Delete=$False;
					}
				)
			};

		}

		# ------------------------------------------------------------
		
		If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
			#
			# Current session does not have Admin-Rights (required)
			#   |--> Re-run this script as admin (if current user is not an admin, request admin credentials)
			#
			Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs;
			Exit;

		} Else {
			#
			# 		New-Item --> Can be used to create new registry keys (assuming the current powershell session is running with elevated privileges)
			#
			#			Set-ItemProperty --> Can be used to create new registry values (DWord 32-bit, etc.)
			#

			Foreach ($EachRegEdit In $RegEdits) {
				#
				# Root-Keys
				#   |--> Ensure that this registry key's Root-Key has been mapped as a network drive
				#   |--> Mapping this as a network drive grants this script read & write access to said Root-Key's registry values (which would otherwise be inaccessible)
				#
				$Each_RegEdit_DriveName=(($EachRegEdit.Path).Split(':\')[0]);
				If ((Test-Path -Path (("")+(${Each_RegEdit_DriveName})+(":\"))) -Eq $False) {
					$Each_PSDrive_PSProvider=$Null;
					$Each_PSDrive_Root=$Null;
					Write-Host "`n`n  Info: Root-Key `"${Each_RegEdit_DriveName}`" not found" -ForegroundColor Yellow;
					Foreach ($Each_PSDrive In $PSDrives) {
						If ((($Each_PSDrive.Name) -Ne $Null) -And (($Each_PSDrive.Name) -eq $Each_RegEdit_DriveName)) {
							$Each_PSDrive_PSProvider=($Each_PSDrive.PSProvider);
							$Each_PSDrive_Root=($Each_PSDrive.Root);
							Break;
						}
					}
					If ($Each_PSDrive_Root -Ne $Null) {
						Write-Host "   |`n   |--> Adding Session-Based ${Each_PSDrive_PSProvider} Network-Map from drive name `"${Each_RegEdit_DriveName}`" to data store location `"${Each_PSDrive_Root}`"" -ForegroundColor "Yellow";
						New-PSDrive -Name "${Each_RegEdit_DriveName}" -PSProvider "${Each_PSDrive_PSProvider}" -Root "${Each_PSDrive_Root}" | Out-Null;
					}
				}
				
				If ((Test-Path -Path ($EachRegEdit.Path)) -eq $True) {
					# Skip creating registry key if it already exists
					Write-Host (("`n`n  Found Key `"")+($EachRegEdit.Path)+("`"")) -ForegroundColor DarkGray; # (Already up to date)
				} Else {
					# Create missing key in the registry
					Write-Host (("`n`n  Creating Key `"")+($EachRegEdit.Path)+("`" ")) -ForegroundColor Green;
					New-Item -Path ($EachRegEdit.Path);
				}

				Foreach ($EachProp In $EachRegEdit.Props) {

					# Check for each key-property
					# Write-Host (("`n`n  Checking for `"")+($EachRegEdit.Path)+("`" --> `"$($EachProp.Name)`"...`n`n"));
					$Revertable_ErrorActionPreference = $ErrorActionPreference; $ErrorActionPreference = 'SilentlyContinue';
					$GetEachItemProp = Get-ItemProperty -Path ($EachRegEdit.Path) -Name ($EachProp.Name);
					$last_exit_code = If($?){0}Else{1};
					$ErrorActionPreference = $Revertable_ErrorActionPreference;
					$EchoDetails = "";
					If ((${EachProp}.Description) -Ne $Null) { $EchoDetails += "`n         v`n        Description: $(${EachProp}.Description)"; }
					If ((${EachProp}.Hotfix) -Ne $Null) { $EchoDetails += "`n         v`n        Hotfix: $(${EachProp}.Hotfix)"; }

					If ($last_exit_code -eq 0) { # Registry-Key-Property exists

						If (($EachProp.Delete) -eq $False) { # Property should NOT be deleted

							$EachProp.LastValue = $GetEachItemProp.($EachProp.Name);
								
							If (($EachProp.LastValue) -eq ($EachProp.Value)) { # Property set as-intended (Already up to date)
								Write-Host "   |`n   |--> Found Property [ $($EachProp.Name) ($($EachProp.Type)) ] with correct Value of [ $($EachProp.Value) ] ${EchoDetails}" -ForegroundColor "DarkGray";

							} Else {
								# Modify the value of an existing property on an existing registry key
								Write-Host "   |`n   |--> Updating Property [ $($EachProp.Name) ($($EachProp.Type)) ] from Value [ $($EachProp.LastValue) ] to Value [ $($EachProp.Value) ] ${EchoDetails}" -ForegroundColor "Yellow";
								Set-ItemProperty -Path ($EachRegEdit.Path) -Name ($EachProp.Name) -Value ($EachProp.Value);

							}

						} Else { # Property SHOULD be deleted
							
							# Existing key-property found which should be deleted
							Write-Host "   |`n   |--> Deleting Property [ $($EachProp.Name) ($($EachProp.Type)) ] with Value of [ $($EachProp.Value) ] ${EchoDetails}" -ForegroundColor "Magenta";
							Remove-ItemProperty -Path ($EachRegEdit.Path) -Name ($EachProp.Name) -Value ($EachProp.Value);

						}


					} Else { # Registry-Key-Property does NOT exist

						If (($EachProp.Delete) -eq $False) { # Property should NOT be deleted

							# Add the missing property to the Registry Key
							Write-Host "   |`n   |--> Adding Property [ $($EachProp.Name) ($($EachProp.Type)) ] with Value [ $($EachProp.Value) ] ${EchoDetails}" -ForegroundColor "Yellow";
							New-ItemProperty -Path ($EachRegEdit.Path) -Name ($EachProp.Name) -PropertyType ($EachProp.Type) -Value ($EachProp.Value);
							Write-Host " `n`n";

						} Else { # Property SHOULD be deleted (Already up to date)
							Write-Host "   |`n   |--> Skipping Deletion of Property [ $($EachProp.Name) ($($EachProp.Type)) ] (already deleted/doesn't-exist) ${EchoDetails}" -ForegroundColor "DarkGray";


						}

					}

				}

			}

		}
	}

	Write-Host -NoNewLine "`n`n  Press any key to exit..." -BackgroundColor Black -ForegroundColor Magenta;
	$KeyPress = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

}
Export-ModuleMember -Function "SyncRegistry";
# Install-Module -Name "SyncRegistry"


# ------------------------------------------------------------
# Citation(s)
#
#   docs.microsoft.com  |  "Set-ItemProperty - Creates or changes the value of a property of an item"  |  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-itemproperty
#
#   docs.microsoft.com  |  "Get-PSProvider - Gets information about the specified PowerShell provider"  |  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-psprovider
#
#   docs.microsoft.com  |  "New-PSDrive - Creates temporary and persistent mapped network drives"  |  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-psdrive
#
#   answers.microsoft.com  |  "Automatic files - Automatic file downloads"  |  https://answers.microsoft.com/en-us/windows/forum/all/automatic-files/91b91138-0096-4fbc-a3e2-5de5176a6ca5
#
#   social.msdn.microsoft.com  |  ".NET Framework 3.5 doesn't install. Windows 10.. Error code: 0x800F081F"  |  https://social.msdn.microsoft.com/Forums/en-US/4ea808e7-c503-4f99-9480-aa8e6938be3d
#
#   stackoverflow.com  |  "Retrieve (Default) Value in Registry key"  |  https://stackoverflow.com/a/31711000
#
#   winhelponline.com  |  "Change the Default Image Editor Linked to Edit command in Right-click Menu for Image Files"  |  https://www.winhelponline.com/blog/change-default-image-editor-edit-command-right-click-image/
#
#   autohotkey.com  |  "Windows key (#) + letter keeps locking the pc (even if it is not #L)"  |  https://www.autohotkey.com/boards/viewtopic.php?p=46949&sid=490d0a443a7f78557b54c2bfb079350f#p46949
#
#   getadmx.com  |  "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System"  |  https://getadmx.com/HKCU/Software/Microsoft/Windows/CurrentVersion/Policies/System
#
# ------------------------------------------------------------