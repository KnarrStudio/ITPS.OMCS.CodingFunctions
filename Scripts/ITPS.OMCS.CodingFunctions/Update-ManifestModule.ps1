#!/usr/bin/env powershell
#requires -Version 2.0 -Modules Microsoft.PowerShell.Utility
$SplatSettings = @{
Path = 'D:\GitHub\KnarrStudio\ITPS.OMCS.Modules\Scripts\ITPS.OMCS.CodingFunctions\ITPS.OMCS.CodingFunctions.psd1'
Guid = "$(New-Guid)"
Author = 'Erik' 
CompanyName = 'KnarrStudio'
ModuleVersion = '1.1.0.8'
Description = 'A few functions that I use often to code with' 
PowerShellVersion = '4.0'
FunctionsToExport = @( 'Send-eMail', 'Get-Versions', 'Get-CurrentLineNumber', 'Set-SafetySwitch', 'Compare-FileHash', 'Import-FileData  ', 'New-TimestampFile ', 'Get-TimeStamp'
)
CmdletsToExport = '*'
ModuleList = '.\ITPS.OMCS.CodingFunctions.psm1'

}

New-ModuleManifest @SplatSettings -ReleaseNotes 'Some small edits' -RootModule '.\ITPS.OMCS.CodingFunctions.psm1'

#FunctionsToExport = 'Send-eMail,Import-FileData,Compare-FileHash,Set-SafetySwitch,Get-Versions'
