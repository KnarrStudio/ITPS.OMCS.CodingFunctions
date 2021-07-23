#requires -Modules Microsoft.PowerShell.Utility
#!/usr/bin/env powershell
#requires -Version 4.0
function Get-Versions
{
  <#
      .SYNOPSIS
      A way to get the OS version you are running
  #>
  param
  ([Parameter(Mandatory = $false, Position = 0)][Object]$input
  )
  $WinOS = 'Windows'
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
      $OperatingSys = $WinOS
    }
  }
  Else
  {
    Write-Output -InputObject ($MagMinVer -F ($(($psversiontable.PSVersion).Major), $(($psversiontable.PSVersion).Minor)))
    if($env:os)
    {
      $OperatingSys = $WinOS
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

  function Set-WhatIfOn{<#.SYNOPSIS;Sets Whatif to True#>
    $Script:WhatIfPreference = $true}
  function Set-WhatIfOff{<#.SYNOPSIS;Sets Whatif to False#>
    $Script:WhatIfPreference = $false}

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
    [Parameter(Mandatory = $false)]
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

function Import-FileData
{
  <#
      .SYNOPSIS
      A function that will help import files

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER fileName
      Filename and path of the file you need to import data from

      .PARAMETER FileType
      File type to be imported, but really how you want it to be handled.  i.e.
      Basically how you want to manage the import.  In otherwords, a 'txt' file could be imported as a csv.

      .EXAMPLE
      Import-FileData -fileName Value -FileType Value
    
  #>


  param(
    [Parameter(Mandatory,HelpMessage = 'Name of file to be imported.')]
    [String]$fileName,
    [Parameter(Mandatory,HelpMessage = 'File type to be imported, but really how you want it to be handled.  ie txt could be a csv')]
    [ValidateSet('csv','txt','json')]
    [String]$FileType
  )
  
  switch ($FileType)
  {
    'csv'    {
      $importdata = Import-Csv -Path $fileName
    }
    'txt'    {
      $importdata = Get-Content -Path $fileName -Raw
    }  
    'json'   {
      $importdata = Get-Content -Path .\config.json
    }
    default    {
      $importdata = $null
    }
  }
  return $importdata
}

function Send-eMail
{
  <#
      .SYNOPSIS
      Send an email notification via script.  Uses local service account and mail server.

      .DESCRIPTION
      Send an email notification via script.  Uses local service account and mail server.
      Sends and email from a script run at the server.  This generates output to the console.

      .PARAMETER MailTo
      Receivers email address

      .PARAMETER MailFrom
      Senders email address

      .PARAMETER msgsubj
      Email subject.  This is always a good idea.

      .PARAMETER SmtpServers
      Name or IP addess of SMTP servers

      .PARAMETER MessageBody
      The message.  This could be an error from  a catch statement or just information about it being completed

      .PARAMETER AttachedFile
      Email attachemt

      .PARAMETER ErrorFile
      File to send the error message.

      .EXAMPLE
      Send-eMail -MailTo Value -MailFrom Value -msgsubj Value -SmtpServers Value -MessageBody Value -AttachedFile Value -ErrorFile Value

      .EXAMPLE
      # The "$SplatSendEmail" should be the only information you need to change to send an email.  
      $SplatSendEmail = @{
      MailTo       = @('erik@knarrstudio.com')
      MailFrom     = "$($env:computername)@mail.com"
      msgsubj      = "Service Restarted - $(Get-Date -Format G)"
      SmtpServers  = '192.168.0.5', '192.168.1.8'
      MessageBody  = $EmailMessage
      ErrorFile    = ''
      AttachedFile = $AttachedFile
      Verbose      = $true
      }  
      
      Send-eMail @SplatSendEmail 


      .NOTES
      The current version is somewhat interactive and needs to be run from a console.  
      Later versions should be written to be used without user intervention

  #>


  [CmdletBinding(DefaultParameterSetName = 'Default')]
  param
  (
    [Parameter(Mandatory,HelpMessage = 'To email address(es)', Position = 0)]
    [String[]]$MailTo,
    [Parameter(Mandatory,HelpMessage = 'From email address', Position = 1)]
    [String]$MailFrom,
    [Parameter(Mandatory,HelpMessage = 'Email subject', Position = 2)]
    [String]$msgsubj,
    [Parameter(Mandatory,HelpMessage = 'SMTP Server(s)', Position = 3)]
    [String[]]$SmtpServers,
    [Parameter(Position = 4)]
    [AllowNull()]
    [Object]$MessageBody,
    [Parameter(Position = 5)]
    [AllowNull()]
    [String]$AttachedFile,
    [Parameter(Position = 6)]
    [AllowEmptyString()]
    [string]$ErrorFile = ''
  )

  $DateTime = Get-Date -Format s

  if([string]::IsNullOrEmpty($MessageBody))
  {
    $MessageBody = ('{1} - Email generated from {0}' -f $env:computername, $DateTime)
    Write-Warning -Message 'Setting Message Body to default message'
  }
  elseif(($MessageBody -match '.txt') -or ($MessageBody -match '.htm'))
  {
    if(Test-Path -Path $MessageBody)
    {
      [String]$MessageBody = Get-Content -Path $MessageBody
    }
  }
  elseif(-not ($MessageBody -is [String]))
  {
    $MessageBody = ('{0} - Original message was not sent as a String.' -f $DateTime)
  }
  else
  {
    $MessageBody = ("{0}`n{1}" -f $MessageBody, $DateTime)
  }
    
  if([string]::IsNullOrEmpty($ErrorFile))
  {
    $ErrorFile = New-TemporaryFile
    Write-Warning  -Message ('Setting Error File to: {0}' -f $ErrorFile)
  }
 
  $SplatSendMessage = @{
    From        = $MailFrom
    To          = $MailTo
    Subject     = $msgsubj
    Body        = $MessageBody
    Priority    = 'High'
    ErrorAction = 'Stop'
  }
  
  if($AttachedFile)
  {
    Write-Verbose -Message 'Inserting file attachment'
    $SplatSendMessage.Attachments = $AttachedFile
  }
  if($MessageBody.Contains('html'))
  {
    Write-Verbose -Message 'Setting Message Body to HTML'
    $SplatSendMessage.BodyAsHtml  = $true
  }
  
  foreach($SMTPServer in $SmtpServers)
  {
    try
    {
      Write-Verbose -Message ('Try to send mail thru {0}' -f $SMTPServer)
      Send-MailMessage -SmtpServer $SMTPServer  @SplatSendMessage
      # Write-Output $SMTPServer  @SplatSendMessage
      Write-Verbose -Message ('successful from {0}' -f $SMTPServer)
      Break 
    } 
    catch 
    {
      $ErrorMessage  = $_.exception.message
      Write-Verbose -Message ("Error Message: `n{0}" -f $ErrorMessage)
      ('Unable to send message thru {0} server' -f $SMTPServer) | Out-File -FilePath $ErrorFile -Append
      ('- {0}' -f $ErrorMessage) | Out-File -FilePath $ErrorFile -Append
      Write-Verbose -Message ('Errors written to: {0}' -f $ErrorFile)
    }
  }
}


#Export-ModuleMember -Function Send-Email,  Get-Versions,  Get-CurrentLineNumber,  Set-SafetySwitch,  Compare-FileHash,  Import-FileData