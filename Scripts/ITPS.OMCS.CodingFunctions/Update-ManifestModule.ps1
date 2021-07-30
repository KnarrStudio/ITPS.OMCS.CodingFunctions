#!/usr/bin/env powershell
#requires -Version 2.0 -Modules Microsoft.PowerShell.Utility
$SplatSettings = @{
Path = 'D:\GitHub\KnarrStudio\ITPS.OMCS.Modules\Scripts\ITPS.OMCS.CodingFunctions\ITPS.OMCS.CodingFunctions.psd1'
RootModule = '.\ITPS.OMCS.CodingFunctions.psm1'
Guid = "$(New-Guid)"
Author = 'Erik' 
CompanyName = 'KnarrStudio'
ModuleVersion = '1.1.2.9'
Description = 'A few functions that I use often to code with' 
PowerShellVersion = '4.0'
FunctionsToExport = @( 'Send-eMail', 'Get-Versions', 'Get-CurrentLineNumber', 'Set-SafetySwitch', 'Compare-FileHash', 'Import-FileData  ', 'New-TimestampFile ', 'Get-TimeStamp'
)
CmdletsToExport = '*'
ModuleList = '.\ITPS.OMCS.CodingFunctions.psm1'
ReleaseNotes = 'Edited the New-Timestampfile which was not handling the case when the file did not exist.  Added Validatescript to ensure filename was formatted with a "."'
}

New-ModuleManifest @SplatSettings

