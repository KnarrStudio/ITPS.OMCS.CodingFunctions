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
  [String]$MajMinVer = '{0}.{1}'
  [Float]$PsVersion = ($MajMinVer -f [int]($psversiontable.PSVersion).Major, [int]($psversiontable.PSVersion).Minor)
  if($PsVersion -ge 6)
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
    Write-Output -InputObject ($MajMinVer -F ($(($psversiontable.PSVersion).Major), $(($psversiontable.PSVersion).Minor)))
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
      Changes the setting from its current state. There is no output with this.  Use the "Bombastic" switch if you need a visual message.
      By default this is set

      .PARAMTER Bombastic
      Another word for verbose and is used to provide a colored (red/green) message of the current state to the console.  
      You can add it to a menu.

      .EXAMPLE
      Set-SafetySwitch 
      Sets the WhatIfPreference to the opposite of its current setting. No output message.

      .EXAMPLE
      Set-SafetySwitch -Bombastic
      Sets the WhatIfPreference to the opposite of its current setting
       
      Output is one of the two based on what is set:
      'Safety is OFF - Script is active and will make changes'
      'Safety is ON - Script is TESTING MODE'

      .NOTES
      Best to just copy this into your script and call it how ever you want. I use a menu.
      Latest update allows you to pull out the working function 'Set-WhatIf'

  #>
  
  [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'Low',DefaultParameterSetName = 'Default')]
  param
  (
    [Parameter(Position = 0, ParameterSetName = 'Default')] [Switch]$Toggle = $true,
    [Parameter(Position = 1)] [Switch]$Bombastic,
    [Parameter(Mandatory,HelpMessage = 'Hard set on/off',Position = 0,ParameterSetName = 'Switch')]
    [ValidateSet('No','Yes')] [String]$RunScript
  )

  function Set-WhatIf
  {
    <#.SYNOPSIS;Sets Whatif to True or False#>
    param (
      [Alias('NoRun')]
      [Parameter(Mandatory,HelpMessage = 'Hard set on. Test Script',Position = 0,ParameterSetName = 'On')][Switch]$On,
      [Alias('YesRun')]
      [Parameter(Mandatory,HelpMessage = 'Hard set off. Run Script',Position = 0,ParameterSetName = 'Off')][Switch]$Off,
      [Switch]$Script:Bombastic
    )

    $Message = @{
      BombasticOff = 'Safety is OFF - Script is active and will make changes'
      BombasticOn  = 'Safety is ON - Script is TESTING MODE'    }

    if($On) {
      $Script:WhatIfPreference = $true
      if ($Bombastic) { Write-Host -Object $($Message.BombasticOn) -ForegroundColor Green  }
    }
    if($Off) {
      $Script:WhatIfPreference = $false
      if ($Bombastic) { Write-Host -Object $($Message.BombasticOff) -ForegroundColor Red  }
    }
  }

  if($RunScript -eq 'Yes') { 
    Set-WhatIf -YesRun }
  elseif($RunScript -eq 'No') { 
    Set-WhatIf -NoRun }
  elseif($Toggle) { 
    if ($WhatIfPreference -eq $true) { 
      Set-WhatIf -Off }
    else { 
      Set-WhatIf -On }
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
    [ValidateSet('YYYYMMDD', 'DDHHmmss', 'YYYYMMDDHHmm','YYYY-MM-DD', 'JJJHHmmss', 'DayOfYear', 'MM-DD-YY_HHmmss-f', 'YYMMDD-24HHmm-f', 'tzOffset')] 
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
    YYYYMMDDHHmm
    {
      $SplatFormat = @{
        UFormat = '%Y%m%d%H%M'
      }
    } # 1703162145 YYMMDDHHmm
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
    YYMMDD-24HHmm-f
    {
      $SplatFormat = @{
        UFormat = '%y/%m/%d %R'
      }
    } # 17/03/16 21:52 YYMMDD-24HHmm (If for a filename use -Asfilename)
    MM-DD-YY_HHmmss-f
    {
      $SplatFormat = @{
        UFormat = '%D %R:%S'
      }
    } # 07/26/21 08:45:19 MMDDTT-HH:mm:ss  (If for a filename use -Asfilename)
    tzOffset
    {
      if(-not $AsFilename)
      {
        $SplatFormat = @{
          UFormat = '%y %b %d %R %Z'
        }
      }
      else
      {
        $SplatFormat = @{
          UFormat = '%y-%b-%d_%R(%Z)'
        }
      }
    } # YYYY MMM DD - timezone offest
    Default
    {
      $SplatFormat = @{}
    }
  }
    
  [string]$TimeStamp = Get-Date @SplatFormat
  
  if($AsFilename)
  {
    $TimeStamp = $TimeStamp.Replace('/','-').Replace(':','.').Replace(' ','_')
    return $TimeStamp
  }else{
    Return $(New-Object psobject -Property @{TimeStamp = $TimeStamp})
  }
}

function New-File
{
  <#
      .SYNOPSIS
      Creates a file and increments the name "(1)" if the file exists.

      .DESCRIPTION
      Creates a file and increments the name, or allows you to append the base filename with a tag.
      You provide the base name and extension the time/date stamp and if you want to append or overwrite the file.

      This started as a way to build a filename that was timestamped.  It then morphed into creating the file and then incrementing it.
      It has morphed again and no longer adds the date.  I found that the increment was valuable by itself, so the timestamp has been depricated as a default and changed to 'Tag'.

      .PARAMETER FileName
      Name of the file "Import-FileData.ps1"

      .PARAMETER Tag
      This is just what is added to the back of the file name.  You can use a string, or pass a variable. For a timestamp use the "Get-TimeStamp" (See Notes) function
      Try $((Get-Date).Tostring('yyyyMMdd'))

      You can use any format that is legal for a filename.  Using only "Get-Date" will fail.
      
      In truth, this is a string input so you can use "foo" or "bar" and it will work.  
      Try $($env:username) or $($env:computername)

      ***** Future plans will be to rename this to something like "tag" or "id"  ****
      
      .PARAMETER Amend
      Looks for the file and does nothing if it exists.  Good for testing to ensure your output goes somewhere.
      If the file does not exist, then it will create it. 
      If the file exists, it is not changed, but the name is passed back to you

      .PARAMETER Overwrite
      Just simply creates a new file with the "-force" parameter.  
      It doesn't bother to check.  

      .PARAMETER Increment
      This is default and is optional.
      This looks for the file and if it exists, it creates a new file such as "Import-FileData(1).ps1".  If you were to run it again, you would get "Import-FileData(2).ps1"
      If it doesn't exist, it creates the file as input.  "Import-FileData.ps1"

      .EXAMPLE
      New-File  -FileName Import-FileData.ps1

      If Not Exist (Creates): Import-FileData.ps1
      If Exists x2 (Creates): Import-FileData(3).ps1

      
      .EXAMPLE
      New-File  -FileName Import-FileData.ps1 -Tag 123456
      
      If Not Exist (Creates): Import-FileData-123456.ps1
      If Exists x2 (Creates): Import-FileData-123456(3).ps1
      
      .EXAMPLE
      $filename = 'Import-FileData.ps1' ; $timeStamp = Get-TimeStamp -Format YYYYMMDD -AsFilename ; New-File $filename $timeStamp
      
      If Not Exist (Creates): Import-FileData-20210727.ps1

      .EXAMPLE
      $filename = 'Import-FileData.ps1' ; Get-TimeStamp -Format YYYYMMDD -AsFilename | New-File $filename

      If Not Exist (Creates): Import-FileData-20210727.ps1

      .EXAMPLE
      New-File  -FileName Import-FileData.ps1 -Amend
      
      If Not Exist (Creates): Import-FileData.ps1
      If Exist (No Change): Import-FileData.ps1
      If the file exists, it is not changed, but the name is passed back to you

      .EXAMPLE
      New-File  -FileName Import-FileData.ps1 -Overwrite
      If Not Exist (Creates): Import-FileData.ps1
      If Exists (Overwrites): Import-FileData.ps1

      .EXAMPLE
      New-File  -FileName Import-FileData.ps1 -Increment
      If Not Exist (Creates): Import-FileData-20210727.ps1
      If Exists (Increments num in "($i)"): Import-FileData-20210727(1).ps1

      .NOTES
      REGEX Used: ^[A-Za-z0-9(?:()_ -]+\.[A-Za-z0-9]*$

      Match a single character present in the list below [A-Za-z0-9(?:()_ -]
      + matches the previous token between one and unlimited times, as many times as possible, giving back as needed (greedy)
      A-Z matches a single character in the range between A (index 65) and Z (index 90) (case sensitive)
      a-z matches a single character in the range between a (index 97) and z (index 122) (case sensitive)
      0-9 matches a single character in the range between 0 (index 48) and 9 (index 57) (case sensitive)
      (?:()_ - matches a single character in the list (?:)_ - (case sensitive)
        
      \. matches the character . with index 4610 (2E16 or 568) literally (case sensitive)
        
      Match a single character present in the list below [A-Za-z0-9]
      * matches the previous token between zero and unlimited times, as many times as possible, giving back as needed (greedy)
      A-Z matches a single character in the range between A (index 65) and Z (index 90) (case sensitive)
      a-z matches a single character in the range between a (index 97) and z (index 122) (case sensitive)
      0-9 matches a single character in the range between 0 (index 48) and 9 (index 57) (case sensitive)
        
      $ asserts position at the end of a line

      Regarding the Get-TimeStamp:
      The "Get-TimeStamp", which was originally built into the script, but pulled out to be more widely used.
      Get-TimeStamp -Format YYYY-MM-DD -AsFilename 
      Excepted Formats: formats - YYYYMMDD, DDHHmmss, YYMMDD-24HHmm, YYYYMMDDHHmm, MM-DD-YY_HHmmss, YYYY-MM-DD, JJJHHmmss, DayOfYear, tzOffset
      The formats with the "ss" on the end are for seconds, so every second you could create a new file.  
      The formats with the "-f" on the end are the ones which have special characters and will need the "-AsFilename" to be used in a filename


      .INPUTS
      String

      .OUTPUTS
      String as filename (default) or filepath

  #>

  #[cmdletbinding(DefaultParameterSetName = 'FileName Set')]
  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory,Position = 0,ValueFromPipeline, ValueFromPipelineByPropertyName,HelpMessage = 'File name "Fullname.extension" | example: test.txt')]
    [Alias('file')]
    [ValidateScript({
          $ptrn = [regex]'^[A-Za-z0-9(?:()_ -]+\.[A-Za-z0-9]*$'
          If($_ -match $ptrn)
          {
            $true
          }
          Else
          {
            Throw 'Filename requires "." example: test.txt'
          }
    })]
    [String]$Filename,
    [Parameter(Mandatory = $false,Position = 1,ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [String]$Tag, 
    [Parameter(Mandatory,Position = 2,HelpMessage = 'Amend or Append file',ParameterSetName = 'Amend')]
    [Switch]$Amend,
    [Parameter(Mandatory,Position = 2,HelpMessage = 'Overwrite or Delete and recreate file',ParameterSetName = 'Overwrite')]
    [Switch]$Overwrite,
    [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Creates new file with "(1)"',ParameterSetName = 'Increment')]
    [Switch]$Increment = $true,
    [Parameter(Mandatory = $false,HelpMessage = 'Returns the filename or filepath.')]
    [ValidateSet('Filename','Filepath')] 
    [String]$Return = 'Filename'
       
  )
  #Parameter Notes
  # The regex line sometimes is broken when editing: This is the correct syntex: $ptrn = [regex]'^[A-Za-z0-9(?:()_ -]+\.[A-Za-z0-9]*$'
  # Timestamp option - $(Get-Date -UFormat '%y%m%d') 
 
  $ItemType = 'File'
  $dot = '.'
  $SplatFile = @{}

  $FileBaseName = $Filename.Split($dot)[0]
  $fileExt = ('.{0}' -f $Filename.Split($dot)[1])
  
  if($Tag)
  {
    $DatedName = ('{0}-{1}' -f $FileBaseName, $Tag)
  }
  else
  {
    $DatedName = $FileBaseName
  }
  $NewFile = ('{0}{1}' -f $DatedName, $fileExt)

  Switch ($true){
    $Amend
    {
      Write-Verbose -Message 'Amend'
      if(-not (Test-Path -Path $NewFile))
      {
        $SplatFile = @{
          Path     = $NewFile
          ItemType = $ItemType
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
        ItemType = $ItemType
        Force    = $true
      }
      $null = New-Item @SplatFile
    }
    
    Default 
    {
      $i = 1
      if(Test-Path -Path $NewFile)
      {
        do 
        {
          $NewFile = [String]('{0}({1}){2}' -f $DatedName , $i, $fileExt)
          $i++
        }
        while (Test-Path -Path $NewFile)
      }
        
      Write-Verbose -Message 'Increment'

      $SplatFile = @{
        Path     = $NewFile
        ItemType = $ItemType
        Force    = $false
      }
      $null = New-Item @SplatFile
    }

  }

  if($Return -eq 'Filename')
  {
    Return $NewFile
  }
  elseif($Return -eq 'Filepath')
  {
    Return (Get-Item -Path $NewFile).FullName
  }
}


<#
Export-ModuleMember -Function Send-eMail
Export-ModuleMember -Function Get-Versions
Export-ModuleMember -Function Get-CurrentLineNumber
Export-ModuleMember -Function Set-SafetySwitch
Export-ModuleMember -Function Compare-FileHash
Export-ModuleMember -Function Import-FileData  
Export-ModuleMember -Function New-File 
Export-ModuleMember -Function Get-TimeStamp
#>



