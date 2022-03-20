#!/usr/bin/env powershell
#requires -Version 2.0 -Modules Microsoft.PowerShell.Utility

Write-Host -Object $((Get-Item (Get-Location).Path).Parent.Name)

$Major = 1     # Changes that cause the code to operate differently or large rewrites
$minor = 4    # When an individual module or function is added
$Patch = 1     # Small updates to a function or module.  Note: This goes to zero when minor is updated
$Manifest = 18  # For each manifest module update


$SplatSettings = @{
  Path              = '{0}\{1}.psd1' -f $((Get-Item -Path (Get-Location).Path).Parent.FullName), $((Get-Item -Path (Get-Location).Path).Parent.Name)
  RootModule        = '.\loader.psm1'
  Guid              = "$(New-Guid)"
  Author            = 'Erik'
  CompanyName       = 'Knarr Studio'
  ModuleVersion     = '{0}.{1}.{2}.{3}' -f $Major, $minor, $Patch, $Manifest
  Description       = 'A few functions that I use often to code with'
  PowerShellVersion = '4.0'
  NestedModules     = @('.\Modules\ITPS.OMCS.CodingFunctions.psm1', '.\Modules\ITPS.OMCS.MenuFunctions.psm1')
  FunctionsToExport = 'Get-Versions', 'Get-CurrentLineNumber', 'Set-SafetySwitch', 'Compare-FileHash', 'Import-FileData', 'Send-eMail', 'Get-TimeStamp', 'New-File','Get-MyCredential'
  CmdletsToExport   = '*'
  ReleaseNotes      = "Added the 'New-File','Get-MyCredential' functions.  Corrected a syntax error in 1.4.1.18"
}

New-ModuleManifest @SplatSettings


