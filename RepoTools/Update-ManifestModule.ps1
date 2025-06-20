#!/usr/bin/env powershell
#requires -Version 2.0 -Modules Microsoft.PowerShell.Utility

Write-Host -Object $((Get-Item (Get-Location).Path).Parent.Name)

$Major = 2     # Changes that cause the code to operate differently or large rewrites
$minor = 0    # When an individual module or function is added or removed
$Patch = 0     # Small updates to a function or module.  Note: This goes to zero when minor is updated
$Manifest = 21  # For each manifest module update


$SplatSettings = @{
  Path              = '{0}\{1}.psd1' -f $((Get-Item -Path (Get-Location).Path).Parent.FullName), $((Get-Item -Path (Get-Location).Path).Parent.Name)
  RootModule        = '.\loader.psm1'
  Guid              = "$(New-Guid)"
  Author            = 'Erik'
  CompanyName       = 'Knarr Studio'
  ModuleVersion     = '{0}.{1}.{2}.{3}' -f $Major, $minor, $Patch, $Manifest
  Description       = 'A sort of Function Library'
  PowerShellVersion = '4.0'
  NestedModules     = @('.\Modules\ITPS.OMCS.CodingFunctions.psm1', '.\Modules\ITPS.OMCS.MenuFunctions.psm1')
  FunctionsToExport = 'Get-Versions', 'Get-CurrentLineNumber', 'Set-SafetySwitch', 'Compare-FileHash', 'New-File','Get-MyCredential'
  CmdletsToExport   = '*'
  ReleaseNotes      = "Removed 'Import-FileData'.  Corrected syntax"
}

New-ModuleManifest @SplatSettings


