#
#	PowerShell - Show
#		|--> Writes a input variable(s) to output
#
Function Show() {
	Param(
	
		[Switch]$Enumerate
		
	)

	$VarsToShow = @{};
	$VarsToShow["MyInvocation.MyCommand"] = ($MyInvocation.MyCommand);
	$VarsToShow["PSScriptRoot"] = ($PSScriptRoot);
	$VarsToShow["PsBoundParameters.Values"] = ($PsBoundParameters.Values);
	$VarsToShow["args"] = ($args);
	$VarsToShow["args[0]"] = ($args[0]);
	$VarsToShow["args[1]"] = ($args[1]);

	ForEach ($EachKey in ($VarsToShow.Keys | Sort-Object)) {
		$EachVarValue = $VarsToShow[$EachKey];
		Write-Output "============================================================";
		Write-Output "`n`n--> Variable:`n";
		Write-Output "`$$(${EachKey})";
		Write-Output "`n`n--> Value (in List form):`n";
		$EachVarValue | Format-List;
		Write-Output "`n`n--> Methods:`n";
		If ($PSBoundParameters.ContainsKey('Enumerate') -Eq $False) {
			Write-Output -NoEnumerate $EachVarValue | Get-Member;
		} Else {
			Write-Output $EachVarValue | Get-Member;
		}
		Write-Output "`n------------------------------------------------------------";
	}
	
	Return;
}
Export-ModuleMember -Function "Show";
# Install-Module -Name "Show"



#
#	Citation(s)
#
#		"Powershell: Everything you wanted to know about arrays"
#			|--> https://powershellexplained.com/2018-10-15-Powershell-arrays-Everything-you-wanted-to-know/#write-output--noenumerate
#			|--> by Kevin Marquette
#
#