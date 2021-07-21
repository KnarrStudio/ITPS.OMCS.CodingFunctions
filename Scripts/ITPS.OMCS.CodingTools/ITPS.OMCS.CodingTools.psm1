#!/usr/bin/env powershell
#requires -Version 4.0
function Get-Versions
{
  <#
      .SYNOPSIS
      A way to get the OS version you are running
  #>
  [CmdletBinding()]
  param
  ([Parameter(Mandatory = $false, Position = 0)]$input
  )
  [String]$MagMinVer = '{0}.{1}'
  [Float]$PsVersion = ($MagMinVer -f [int]($psversiontable.PSVersion).Major, [int]($psversiontable.PSVersion).Minor)
  if($PsVersion  -ge 6)
  {
    if ($IsLinux) 
    {
      $OperatingSys = 'Linux'
    }
    elseif ($IsMacOS) 
    {
      $OperatingSys = 'macOS'
      $OsMac
    }
    elseif ($IsWindows) 
    {
      $OperatingSys = 'Windows'
    }
  }
  Else
  {
    Write-Output -InputObject ($MagMinVer -F ($(($psversiontable.PSVersion).Major), $(($psversiontable.PSVersion).Minor)))
    if($env:os)
    {
      $OperatingSys = 'Windows'
    }
  }
  $x = @{
    PSversion = $PsVersion
    OSVersion = $OperatingSys
  }
  return $x
}

function Get-CurrentLineNumber
{
  <#
      .SYNOPSIS
      Add-In to aid troubleshooting. A quick way to mark sections in the code.  
      This is a relitive location, so running thirty lines from the middle of your 1000 line code is only going to give you 0-30 as a line number.  Not 490-520 

      .PARAMETER MsgNum
      Selects the message to be displayed.
      1 = 'Set Variable'
      2 = 'Set Switch Variable'
      3 = 'Set Path/FileName'
      4 = 'Start Function'
      5 = 'Start Loop'
      6 = 'End Loop'
      7 = 'Write Data'
      99 = 'Current line number'


      .EXAMPLE
      Write-Verbose  -Message ('{0} {1}' -f $(Get-CurrentLineNumber -MsgNum 7 ),'') 
    
      Output:
      Line 23:  Write Data

      .NOTES
      Get-CurrentLineNumber must be accessed using the full script or it will only give you Line #1.  
  #>


  param
  (
    [Parameter(Mandatory=$true,HelpMessage='See "get-help Get-CurrentLineNumber" for different options',Position = 0)]
    [int]$MsgNum
  )
  $VerboseMsg = @{
    1 = 'Set Variable'
    2 = 'Set Switch Variable'
    3 = 'Set Path/FileName'
    4 = 'Start Function'
    5 = 'Start Loop'
    6 = 'End Loop'
    7 = 'Write Data'
    99 = 'Current line number'
  }
  if($MsgNum -gt $VerboseMsg.Count)
  {
    $MsgNum = 99
  }#$VerboseMsg.Count}
  'Line {0}:  {1}' -f $MyInvocation.ScriptLineNumber, $($VerboseMsg.$MsgNum)
} 

Function Set-SafetySwitch
{
  <#
      .SYNOPSIS
      Turns on "WhatIf" for the entire script.
      Like a gun safety, "ON" will prevent the script from running and "OFF" will allow the script to make changes.

      .PARAMETER RunScript
      Manually sets the "Safety" On/Off.

      .PARAMETER Toggle
      changes the setting from its current state

      .PARAMTER Bombastic
      Another word for verbose
      It also is a toggle, so that you can add it to a menu.

      .EXAMPLE
      Set-SafetySwitch 
      Sets the WhatIfPreference to the opposite of its current setting

      .NOTES
      Best to just copy this into your script and call it how ever you want.I use a menu

  #>
  
  [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'Low',DefaultParameterSetName = 'Default')]
  param
  (
    [Parameter(Position = 1)]
    [Switch]$Bombastic,
    [Parameter(Mandatory,HelpMessage='Hard set on/off',Position = 0,ParameterSetName = 'Switch')]
    [ValidateSet('No','Yes')]
    [String]$RunScript,
    [Parameter(Position = 0, ParameterSetName = 'Default')]
    [Switch]$Toggle = $true
  )

  $Message = @{
    BombasticOff = 'Safety is OFF - Script is active and will make changes'
    BombasticOn= 'Safety is ON - Script is TESTING MODE'
  }

  function Set-WhatIfOn{$Script:WhatIfPreference = $true}
  function Set-WhatIfOff{$Script:WhatIfPreference = $false}

  if($Toggle){
    If ($WhatIfPreference -eq $true)
    {
      Set-WhatIfOff
      if ($Bombastic){Write-Host $($Message.BombasticOff) -ForegroundColor Red}
    }
    else
    {
      Set-WhatIfOn
      if ($Bombastic){Write-Host $($Message.BombasticOn) -ForegroundColor Green}
    }
  }

  if($RunScript -eq 'Yes'){Set-WhatIfOff}
  elseif($RunScript -eq 'No'){Set-WhatIfOn}
}

Function Compare-FileHash 
{
  <#
      .Synopsis
      Generates a file hash and compares against a known hash
      .Description
      Generates a file hash and compares against a known hash.
      .Parameter File
      Mandatory. File name to generate hash. Example file.txt
      .Parameter Hash
      Mandatory. Known hash. Example 186F55AC6F4D2B60F8TB6B5485080A345ABA6F82
      .Parameter Algorithm
      Mandatory. Algorithm to use when generating the hash. Example SHA1
      .Notes
      Version: 1.0
      History:
      .Example
      Compare-FileHash -fileName file.txt -Hash  186F5AC26F4E9B12F861485485080A30BABA6F82 -Algorithm SHA1
  #>

  Param(
    [Parameter(Mandatory,HelpMessage = 'The file that you are testing against.  Normally the file that you just downloaded.')]
    [string] $fileName
    ,
    [Parameter(Mandatory,HelpMessage = 'The original hash that you are expecting it to be the same.  Normally provided by website at download.')]
    [string] $originalhash
    ,
    [Parameter(Mandatory = $false ,HelpMessage = 'Enter "SHA256" as an example.  Or press "TAB".')]
    [ValidateSet('SHA1','SHA256','SHA384','SHA512','MD5')]
    [string] $algorithm = 'SHA256'
  )
 
  $fileHash = (Get-FileHash -Algorithm $algorithm -Path $fileName).Hash
  $fileHash = $fileHash.Trim()
  $originalhash = $originalhash.Trim()
  $output = ('File: {1}{0}Algorithm: {2}{0}Original hash: {3}{0}Current file:  {4}' -f [environment]::NewLine, $fileName, $algorithm, $originalhash, $fileHash)

  If ($fileHash -eq $originalhash) 
  {
    #Write-Host -Object '---- Matches ----' -ForegroundColor White -BackgroundColor Green
    return $true
  }
  else 
  {
    #Write-Host -Object '---- Does not match ----' -ForegroundColor White -BackgroundColor Red
    return $false
  }

  #Write-Output -InputObject $output
}
