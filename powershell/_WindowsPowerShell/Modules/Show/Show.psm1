#
#	PowerShell - Show
#		|
#		|--> Description:  Shows extended variable information to user
#		|
#		|--> Example:     Show -Test1 -Test2 -Test3 "Value3";
#
Function Show() {
	Param(
		
		[String]$BoundParam_String="BoundParam_String",

		[Int32]$BoundParam_Integer=0,

		[Double]$BoundParam_Double=0.0,

		[Boolean]$BoundParam_Boolean=$False,

		[Object[]]$BoundParam_Array=@(),

		[Hashtable]$BoundParam_Hashtable=@{},

		[Switch]$Enumerate
		
	)

	# $VarsToShow = @{};
	# $VarsToShow["MyInvocation.MyCommand"] = ($MyInvocation.MyCommand);
	# $VarsToShow["PSScriptRoot"] = ($PSScriptRoot);
	# $VarsToShow["PsBoundParameters.Values"] = ($PsBoundParameters.Values);
	# $VarsToShow["args"] = ($args);
	# $VarsToShow["args[0]"] = ($args[0]);
	# $VarsToShow["args[1]"] = ($args[1]);

	Write-Host @args;
	Return;

	ForEach ($EachTopLevelVar in (@($args,$MyInvocation))) {
		ForEach ($EachKey in ($EachTopLevelVar)) {
			# $EachVarValue = $VarsToShow[$EachKey];
			$EachVarValue = $EachKey;
			Write-Output "============================================================";
			Write-Output "`n`n--> Variable Name:`n";
			Write-Output "`$$($EachVarValue.Name)";
			# Write-Output "`$$(${EachKey})";
			Write-Output "`n`n--> Value (List):`n";
			$EachVarValue | Format-List;
			Write-Output "`n`n--> Methods:`n";
			# If ($PSBoundParameters.ContainsKey('Enumerate') -Eq $False) {
				# Write-Output -NoEnumerate $EachVarValue | Get-Member -View ("All");
			# } Else {
				Get-Member -View ("All") -InputObject ($EachVarValue) ;
				# Write-Output $EachVarValue | Get-Member -View ("All");
			# }
			Write-Output "`n------------------------------------------------------------";
		}
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