
# Determine if Runtime-User is an Administrator
#		--> Note: The SID (Security Identifier) value "S-1-5-32-544" refers to the "Administrator" user, and is static across Windows installs
#		--> Note: This is what happens a user right-clicks & selects "Run as Administrator" on a given executable in Windows
Function RunningAsAdministrator {
	Param(
	)
	$ReturnedVal = $Null;
	$AdminSID = "S-1-5-32-544";
	$AdminRole = ([Security.Principal.WindowsBuiltInRole]"Administrator");
	$RuntimeUser = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent());
	$RuntimeSessionOwner = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).Owner);
	If (($RuntimeUser.IsInRole($AdminRole)) -Or ($RuntimeSessionOwner -eq $AdminSID)) {
		$ReturnedVal = $True;
	} Else {
		$ReturnedVal = $False;
	}
	Return $ReturnedVal;
}

# Determine if the Runtime-User is part of the "Administrators" Local UserGroup
Function UserCanEscalatePrivileges {
	Param(
	)
	$ReturnedVal = $Null;
	$RuntimeUserName = (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).Identities.Name);
	If (((Get-LocalGroupMember -Group "Administrators").Name).Contains($RuntimeUserName)) {
		$ReturnedVal = $True;
	} Else {
		$ReturnedVal = $False;
	}
	Return $ReturnedVal;
}

# If needed, Relaunch the script with escalated (administrator) privileges
Function PrivilegeEscalation {
	Param (

		[Parameter(Mandatory=$true)]
		$Command,

		[Switch]$SkipExit,

		[Switch]$Quiet

	)
	If ((RunningAsAdministrator) -eq ($False)) {
		If ((UserCanEscalatePrivileges) -eq ($True)) {
			If (!($PSBoundParameters.ContainsKey('Quiet'))) {
				Write-Host "`nPrivilegeEscalation  :::  Escalating privileges...`n" -BackgroundColor Black -ForegroundColor Green;
			}
			Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"$Command`"" -Verb RunAs;
			# Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$CommandPath`" $CommandArgs" -Verb RunAs;
			If (!($PSBoundParameters.ContainsKey('SkipExit'))) {
				Exit;
			}
		} Else {
			If (!($PSBoundParameters.ContainsKey('Quiet'))) {
				Write-Host "`nPrivilegeEscalation  :::  Error (User lacks sufficient privilege to perform escalation)`n" -BackgroundColor Black -ForegroundColor Red;
			}
		}
	} Else {
		If (!($PSBoundParameters.ContainsKey('Quiet'))) {
			Write-Host "`nPrivilegeEscalation  ::: Skipped (session is already running as Administrator)`n" -BackgroundColor Black -ForegroundColor Yellow;
		}
	}
}

Export-ModuleMember -Function "PrivilegeEscalation";
Export-ModuleMember -Function "RunningAsAdministrator";
Export-ModuleMember -Function "UserCanEscalatePrivileges";



# Install-Module -Name "CredentialManager"

#
#	Citation(s)
#
#		github.com, "Windows 10 Initial Setup Script"
#			https://github.com/Disassembler0/Win10-Initial-Setup-Script
#
