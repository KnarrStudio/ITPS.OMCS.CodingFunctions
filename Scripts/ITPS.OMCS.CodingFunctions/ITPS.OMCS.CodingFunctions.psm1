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
    [Parameter(Mandatory = $true,HelpMessage = 'See "get-help Get-CurrentLineNumber" for different options',Position = 0)]
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
    [Parameter(Mandatory,HelpMessage = 'Hard set on/off',Position = 0,ParameterSetName = 'Switch')]
    [ValidateSet('No','Yes')]
    [String]$RunScript,
    [Parameter(Position = 0, ParameterSetName = 'Default')]
    [Switch]$Toggle = $true
  )

  $Message = @{
    BombasticOff = 'Safety is OFF - Script is active and will make changes'
    BombasticOn  = 'Safety is ON - Script is TESTING MODE'
  }

  function Set-WhatIfOn
  {
    <#.SYNOPSIS;Sets Whatif to True#>
    $Script:WhatIfPreference = $true
  }
  function Set-WhatIfOff
  {
    <#.SYNOPSIS;Sets Whatif to False#>
    $Script:WhatIfPreference = $false
  }

  if($Toggle)
  {
    If ($WhatIfPreference -eq $true)
    {
      Set-WhatIfOff
      if ($Bombastic)
      {
        Write-Host -Object $($Message.BombasticOff) -ForegroundColor Red
      }
    }
    else
    {
      Set-WhatIfOn
      if ($Bombastic)
      {
        Write-Host -Object $($Message.BombasticOn) -ForegroundColor Green
      }
    }
  }

  if($RunScript -eq 'Yes')
  {
    Set-WhatIfOff
  }
  elseif($RunScript -eq 'No')
  {
    Set-WhatIfOn
  }
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
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,HelpMessage = 'The file that you are testing against.  Normally the file that you just downloaded.')]
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
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,HelpMessage = 'Name of file to be imported.')]
    [String]$fileName,
    [Parameter(Mandatory,HelpMessage = 'File type to be imported, but really how you want it to be handled.  ie txt could be a csv')]
    [ValidateSet('csv','txt','json')]
    [String]$FileType
  )
  
  switch ($FileType)
  {
    'csv'    
    {
      $importdata = Import-Csv -Path $fileName
    }
    'txt'    
    {
      $importdata = Get-Content -Path $fileName -Raw
    }  
    'json'   
    {
      $importdata = Get-Content -Path .\config.json
    }
    default    
    {
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
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,HelpMessage = 'SMTP Server(s)', Position = 3)]
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

function Get-TimeStamp
{
  <#
      .SYNOPSIS
      Simple date time stamp, for the person that is tired of looking up format syntax

      .DESCRIPTION
      Creates a function around the "Get-Date -Uformat" to make getting standard dates/times.
      Use the following formats:
      20170316 = YYYYMMDD
      16214855 = DDHHmmss
      17/03/16 21:52 = YYMMDD_HHmm
      1703162145 = YYMMDDHHmm
      07/26/21 08:45:19 = MMDDTT-HH:mm:ss
      03/16/2018 = Default

      .PARAMETER Format
      Used to select the built in formats
      1: YYMMDDhhmm  (Two digit year followed by two digit month day hours minutes.  This is good for the report that runs more than once a day)  -example 1703162145
      2: YYYYMMDD  (Four digit year two digit month day.  This is for the once a day report)  -example 20170316 
      3: jjjhhmmss (Julian day then hours minutes seconds.  Use this when you are testing, troubleshooting or creating.  You won't have to worry about overwrite or append errors)  -example 160214855 
      4: YY-MM-DD_hh.mm  (Two digit year-month-day _ Hours:Minutes)  -example 17-03-16_21.52
      5: yyyy-mm-ddThour.min.sec.milsec-tzOffset (Four digit year two digit month and day "T" starts the time section two digit hour minute seconds then milliseconds finish with the offset from UTC -example 2019-04-24T07:23:51.3195398-04:00
      

      .PARAMETER AsFilename
      In the event you want to use the date/time stamp as a filename, it replaces " "(space), ":", and "/" charectors with file friendly ones.
      " " becomes "_"
      ":" becomes "."
      "/" becomes "-"

      .EXAMPLE
      Get-TimeStamp -Format MMDDYY-HHmmss 
      Returns - 07/26/21 09:32:25


      .EXAMPLE
      Get-TimeStamp -Format MMDDYY-HHmmss -AsFilename
      Returns - 07-26-21_09.32.25

      .NOTES
      Place additional notes here.

  #>

  param
  (
    [Parameter(Mandatory,HelpMessage = 'Use the following formats: YYYYMMDD, DDHHmmss, YYMMDD-24HHmm, YYYYMMDDHHmm, MM-DD-YY_HHmmss, YYYY-MM-DD, JJJHHmmss, DayOfYear, tzOffset')]
    [ValidateSet('YYYYMMDD', 'DDHHmmss', 'YYMMDD-24HHmm-f', 'YYYYMMDDHHmm', 'MM-DD-YY_HHmmss-f','YYYY-MM-DD', 'JJJHHmmss', 'DayOfYear', 'tzOffset-f')] 
    [String]$Format,
    [Switch]$AsFilename
  )
  
  switch ($Format) {
    YYYYMMDD
    {
      $SplatFormat = @{
        UFormat = '%Y%m%d'
      }
    } # 20170316 YYYYMMDD
    DDHHmmss
    {
      $SplatFormat = @{
        UFormat = '%b%d%H%M%S'
      }
    } # Mar16214855 MMMDDHHmmss
    YYMMDD-24HHmm-f
    {
      $SplatFormat = @{
        UFormat = '%y/%m/%d %R'
      }
    } # 17/03/16 21:52 YYMMDD-24HHmm
    YYYYMMDDHHmm
    {
      $SplatFormat = @{
        UFormat = '%Y%m%d%H%M'
      }
    } # 1703162145 YYMMDDHHmm
    MM-DD-YY_HHmmss-f
    {
      $SplatFormat = @{
        UFormat = '%D %R:%S'
      }
    } # 07/26/21 08:45:19 MMDDTT-HH:mm:ss
    YYYY-MM-DD
    {
      $SplatFormat = @{
        UFormat = '%F'
      }
    } # 2018-05-12 (ISO 8601 format)
    JJJHHmmss
    {
      $SplatFormat = @{
        UFormat = '%j%H%M%S'
      }
    } # 207094226 JJJHHmmss Julion Day
    DayOfYear
    {
      $SplatFormat = @{
        UFormat = '%j'
      }
    } # Day of Year
    tzOffset
    {
      $SplatFormat = @{
        UFormat = '%y %b %d %R %Z'
      }
    } # YYYY MMM DD - timezone offest
    Default
    {
      $SplatFormat = @{}
    }
  }
    
  $TimeStamp = Get-Date @SplatFormat
  
  if($AsFilename)
  {
    $TimeStamp = $TimeStamp.Replace('/','-').Replace(':','.').Replace(' ','_')
  }
  
  return [String]$TimeStamp
}

function New-TimestampFile 
{
      <#
      .SYNOPSIS
      Creates a file with a timestamp

      .DESCRIPTION
      Allows you to create a file with a time stamp.  You provide the base name, extension, time/date stamp and if you want to append or overwrite the file.

      .PARAMETER FileName
      Name of the file "Import-FileData.ps1"

      .PARAMETER TimeStamp
      However you want to create the timestame.
      You can use a string, or "Get-Date -format"

      Or you can use the "Get-TimeStamp", which was originally built into the script, but pulled out to be more widely used.
      Get-TimeStamp -Format YYYY-MM-DD -AsFilename 
      Excepted Formats: formats - YYYYMMDD, DDHHmmss, YYMMDD-24HHmm, YYYYMMDDHHmm, MM-DD-YY_HHmmss, YYYY-MM-DD, JJJHHmmss, DayOfYear, tzOffset
      The formats with the "ss" on the end are for seconds, so eversecond you could create a new file.  
      The formats with the "-f" on the end are the ones which have special characters and will need the "-AsFilename" to be used in a filename

      .PARAMETER Update
      Looks for the file and does nothing if it exists.  You would use this with "Append".
      If the file does not exist, then it will create it.

      .PARAMETER Overwrite
      Just simply creates a new file with the "-force" parameter.  
      It doesn't bother to check.  

      .PARAMETER AddOn
      This is default and is optional.
      This looks for the file and if it exists, it creates a new file such as "Import-FileData-210727(1).ps1".  If you were to run it again, you would get "Import-FileData-210727(2).ps1"
      If it doesn't exist, it creates the file as input.  "Import-FileData-210727.ps1"

      .EXAMPLE
      New-TimestampFile  -FileName Import-FileData.ps1

      If Not Exist (Creates): Import-FileData-210727.ps1
      If Exists x2 (Creates): Import-FileData-210727(3).ps1

      
      .EXAMPLE
      New-TimestampFile  -FileName Import-FileData.ps1 -TimeStamp 123456
      
      If Not Exist (Creates): Import-FileData-123456.ps1
      If Exists x2 (Creates): Import-FileData-123456(3).ps1
      
      .EXAMPLE
      $filename = 'Import-FileData.ps1' ; $timeStamp = Get-TimeStamp -Format YYYYMMDD -AsFilename ; New-TimestampFile $filename $timeStamp
      
      If Not Exist (Creates): Import-FileData-20210727.ps1

      .EXAMPLE
      $filename = 'Import-FileData.ps1' ; Get-TimeStamp -Format YYYYMMDD -AsFilename | New-TimestampFile $filename

      If Not Exist (Creates): Import-FileData-20210727.ps1

      New-TimestampFile  -FileName Import-FileData.ps1 -Update
      
      If Not Exist (Creates): Import-FileData-20210727.ps1
      If Exist (No Change): Import-FileData-20210727.ps1


      .EXAMPLE
      New-TimestampFile  -FileName Import-FileData.ps1 -Overwrite
      If Not Exist (Creates): Import-FileData-20210727.ps1
      If Exists (Overwrites): Import-FileData-20210727.ps1

      .EXAMPLE
      New-TimestampFile  -FileName Import-FileData.ps1 -AddOn
      If Not Exist (Creates): Import-FileData-20210727.ps1
      If Exists (Increments num in "($i)"): Import-FileData-20210727(1).ps1

      .INPUTS
      Strings.

  #>

  #[cmdletbinding(DefaultParameterSetName = 'FileName')]
  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory,Position = 0,ValueFromPipeline, ValueFromPipelineByPropertyName,HelpMessage = 'Full file name')]
    [Alias('FullName')]
    [String]$FileName,
    [Parameter(Mandatory = $false,Position = 1,ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [String]$TimeStamp = $(Get-TimeStamp -Format YYYYMMDD -AsFilename ), #$(Get-Date -UFormat '%y%m%d_%H%M%S')
    [Parameter(Mandatory,Position = 2,HelpMessage = 'Update or Append file',ParameterSetName = 'Update')]
    [Switch]$Update,
    [Parameter(Mandatory,Position = 2,HelpMessage = 'Overwrite or Delete and recreate file',ParameterSetName = 'Overwrite')]
    [Switch]$Overwrite,
    [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Creates new file with "(1)"',ParameterSetName = 'Addon')]
    [Switch]$AddOn = $true
       
  )
 
  $SplatFile = @{}

  if(Test-Path $FileName){
    $FileBaseName = (Get-ChildItem -Path $FileName).BaseName
    $fileExt = (Get-ChildItem -Path $FileName).Extension
  }else{
    $FileBaseName = $FileName.Split('.')[0]
    $fileExt = ('.{0}' -f $FileName.Split('.')[1])
  }
  $DatedName = ('{0}-{1}' -f $FileBaseName, $TimeStamp)
  $NewFile = ('{0}{1}' -f $DatedName, $fileExt)

  Switch ($true){
    $Update
    {
      Write-Verbose -Message 'update'
      if(-not (Test-Path -Path $NewFile))
      {
        $SplatFile = @{
          Path     = $NewFile
          ItemType = 'File'
          Force    = $false
        }
        $null = New-Item @SplatFile
      }
    }
    
    $Overwrite
    {
      Write-Verbose -Message 'Overwrite'
      $SplatFile = @{
        Path     = $NewFile
        ItemType = 'File'
        Force    = $true
      }
      $null = New-Item @SplatFile
    }
    
    Default 
    {
      $i = 0
      if(Test-Path -Path $NewFile)
      {
        do 
        {
          $NewFile = [String]('{0}({1}){2}' -f $DatedName , $i, $fileExt)
          $i++
        }
        while (Test-Path -Path $NewFile)
      }
        
      Write-Verbose -Message 'Addon'

      $SplatFile = @{
        Path     = $NewFile
        ItemType = 'File'
        Force    = $false
      }
      $null = New-Item @SplatFile
    }

  }
}


<#
Export-ModuleMember -Function Send-eMail
Export-ModuleMember -Function Get-Versions
Export-ModuleMember -Function Get-CurrentLineNumber
Export-ModuleMember -Function Set-SafetySwitch
Export-ModuleMember -Function Compare-FileHash
Export-ModuleMember -Function Import-FileData  
Export-ModuleMember -Function New-TimestampFile 
Export-ModuleMember -Function Get-TimeStamp
#>



