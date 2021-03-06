# ------------------------------------------------------------
#
# .Synopsis
#    Tries to decode a SecureString and returns its clear text value
#
# .DESCRIPTION
#    Tries to decode a SecureString from a PSCredential Object and returns its clear text value
#
# .EXAMPLE
#    SecureString_Decoder -SecureString (Read-Host -AsSecureString)
#
# .AUTHOR
#    paolofrigo@gmail.com , 2018 https://www.scriptinglibrary.com
#
# ------------------------------------------------------------
Function SecureString_Decoder
{
	[CmdletBinding()]
	[Alias('dssp')]
	[OutputType([string])]
	Param
	(
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)] $SecureString
	)
	Begin
	{
	}
	Process
	{
		Return [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($SecureString));
	}
	End
	{
	}
}

<# Only export the module if the caller is attempting to import it #>
If (($MyInvocation.GetType()) -Eq ("System.Management.Automation.InvocationInfo")) {
	Export-ModuleMember -Function "SecureString_Decoder";
}


# ------------------------------------------------------------
#
# Citation(s)
#
#   www.scriptinglibrary.com  |  "Passwords and SecureString, How To Decode It with Powershell | Scripting Library"  |  https://www.scriptinglibrary.com/languages/powershell/securestring-how-to-decode-it-with-powershell/
#
# ------------------------------------------------------------