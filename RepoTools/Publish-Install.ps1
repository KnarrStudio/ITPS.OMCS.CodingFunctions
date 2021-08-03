#!/usr/bin/env powershell
#requires -Version 2.0 -Modules PowerShellGet

$PSGallery = 'NasPSGallery'
$ModuleName = $((get-item (Get-Location).Path).Parent.Name)
$ModuleLocation = $((get-item (Get-Location).Path).Parent.FullName)
#Set-Location -Path $('{0}' -f $ModuleLocation)

$PublishSplat = @{
  Name       = ('{0}' -f $ModuleLocation)
  Repository = $PSGallery
}

$InstallSplat = @{
  Name         = $ModuleName
  Repository   = $PSGallery
  Scope        = 'CurrentUser'
  AllowClobber = $true
  Force        = $true
}


Publish-Module @PublishSplat 
Install-Module @InstallSplat

