#!/usr/bin/env powershell
#requires -Version 2.0 -Modules Microsoft.PowerShell.Utility

Write-Host $((get-item (Get-Location).Path).Parent.Name)

$Major = 1     # Changes that cause the code to operate differently or large rewrites
$minor = 2    # When an individual module or function is added
$Patch = 3     # Small updates to a function or module.  Note: This goes to zero when minor is updated
$Manifest = 15  # For each manifest module update


$SplatSettings = @{
Path = '{0}\{1}.psd1' -f $((get-item (Get-Location).Path).Parent.FullName), $((get-item (Get-Location).Path).Parent.Name)
RootModule = '.\loader.psm1'
Guid = "$(New-Guid)"
Author = 'Erik' 
CompanyName = 'Knarr Studio'
ModuleVersion = '{0}.{1}.{2}.{3}' -f $Major,$minor,$Patch,$Manifest
#ModuleVersion = '1.2.0.10'
Description = 'A few functions that I use often to code with' 
PowerShellVersion = '4.0'
NestedModules = @('.\Modules\ITPS.OMCS.CodingFunctions.psm1','.\Modules\ITPS.OMCS.MenuFunctions.psm1')
FunctionsToExport = 'Send-eMail', 'Get-Versions', 'Get-CurrentLineNumber', 
               'Set-SafetySwitch', 'Compare-FileHash', 'Import-FileData  ', 
               'New-TimestampFile ', 'Get-TimeStamp', 'Show-MenuFunctions'
               
CmdletsToExport = '*'
#ModuleList = '.\Modules\ITPS.OMCS.CodingFunctions.psm1'
ReleaseNotes = 'Added the Menu Examples. "Show-MenuFunctions"'
}

New-ModuleManifest @SplatSettings


