#!/usr/bin/env powershell
#requires -Version 2.0 -Modules Microsoft.PowerShell.Utility
$SplatSettings = @{
Path = '.\ITPS.OMCS.CodingFunctions\ITPS.OMCS.CodingFunctions.psd1'
Guid = "$(New-Guid)"
Author = 'Erik' 
CompanyName = 'KnarrStudio'
ModuleVersion = '1.1.0.5'
Description = 'A couple of functions that I use often to code with' 
PowerShellVersion = '4.0'
RequiredModules = 'Microsoft.PowerShell.Utility' 
FunctionsToExport = '*'
CmdletsToExport = '*'
ModuleList = '.\ITPS.OMCS.CodingFunctions\ITPS.OMCS.CodingFunctions.psm1'


}

New-ModuleManifest @SplatSettings -ReleaseNotes

#FunctionsToExport = 'Send-eMail,Import-FileData,Compare-FileHash,Set-SafetySwitch,Get-Versions'
