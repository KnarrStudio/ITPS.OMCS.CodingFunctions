#requires -Version 3.0
<#
    .SYNOPSIS
    Exports files and keeps a running size log

    .DESCRIPTION
    Performs the following tasks:
    1. Moves files to new location
    2. Deletes old files at destination
    3. Builds a log file in CSV format to track backup sizes

    .NOTES
    File Name      : Export-DBBackups.ps1
    Authors        : Alex F. (https://github.com/afflom)
    : Erik A. (https://github.com/OgJAkFy8)
    Prerequisite   : Requires -Version 3.0
    Copyright 2018 - Alex F. & Erik A.

    .LINK
    Script posted over:
    https://github.com/afflom/quick-scripts
#>
function New-TimedStampFileName 
{
  <#
      .SYNOPSIS
      Creates a file where a time stamp in the name is needed

      .DESCRIPTION
      Allows you to create a file with a time stamp.  You provide the base name, extension, date format and it should do the rest. It should be setup to be a plug-n-play function that can be used in or out of another script.
    
      .PARAMETER baseNAME
      This is the primary name of the file.  It will be followed by the date/time stamp.

      .PARAMETER FileType
      The extension. ig. csv, txt, log

      .PARAMETER StampFormat
      Describe parameter -StampFormat.

      .EXAMPLE
      New-TimedStampFileName -baseNAME TestFile -FileType log -StampFormat 2
      This creates a file TestFile-20170316.log

      .NOTES
      StampFormats:
      1: YYMMDDHHmm  (Two digit year followed by two digit month day hours minutes.  This is good for the report that runs more than once a day)  -example 1703162145
      2: YYYYMMDD  (Four digit year two digit month day.  This is for the once a day report)  -example 20170316 
      3: jjjHHmmss (Julian day then hours minutes seconds.  Use this when you are testing, troubleshooting or creating.  You won't have to worry about overwrite or append errors)  -example 160214855 
      4: YYYY-MM-DDTHH.mm.ss.ms-UTC (Four digit year two digit month and day "T" starts the time section two digit hour minute seconds then milliseconds finish with an hours from UTC -example 2019-04-24T07:23:51.3195398-04:00
      Old #4: YY/MM/DD_HH.mm  (Two digit year/month/day _ Hours:Minutes.  This can only be used inside a log file)  -example 17/03/16_21:52

      .INPUTS
      Any authorized file name for the base and an extension that has some value to you.

      .OUTPUTS
      example output - Filename-20181005.bat
  #>

  param
  (
    [Parameter(Mandatory,HelpMessage = 'Prefix of file or log name')]
    [String]$baseNAME,
    [Parameter(Mandatory,HelpMessage = 'Extention of file.  txt, csv, log')]
    [alias('Extension')]
    [String]$FileType,
    [Parameter(Mandatory,HelpMessage = 'Formatting Choice 1 to 4')]
    [ValidateRange(1,4)]
    [int]$StampFormat
  )

  switch ($StampFormat){
    1
    {
      $DateStamp = Get-Date -UFormat '%y%m%d%H%M'
    } # 1703162145 YYMMDDHHmm
    2
    {
      $DateStamp = Get-Date -UFormat '%Y%m%d'
    } # 20170316 YYYYMMDD
    3
    {
      $DateStamp = Get-Date -UFormat '%j%H%M%S'
    } # 160214855 jjjHHmmss
    4
    {
      $DateStamp = Get-Date -Format o | ForEach-Object -Process {
        $_ -replace ':', '.'
      }
      #$DateStamp = Get-Date -UFormat '%y/%m/%d_%H.%M' # 17/03/16_21.52
    } 
    default
    {
      Write-Verbose -Message 'No time format selected'
    }
  }

  $baseNAME+'-'+$DateStamp+'.'+$FileType
} # End function New-TimedStampFileName
# (New-TimedStampFileName -baseNAME 'ExportLog' -Extension csv -StampFormat 2)

function Get-FileInformation
{
  [CmdletBinding()]
  param(
    [string]$SourceFolder = "$env:HOMEDRIVE\temp\BackupSource",
    [string]$FileType = $null,
    [string]$DestinationFolder = "$env:HOMEDRIVE\temp\BackupDestination",
    [string]$LogFileName = 'ExportLog',
    [int]$deleteAfterDays = 4,
    [string]$LogDestination = "$env:HOMEDRIVE\Temp\Logs"
  )

  #Get Backup Directories
  $folderList = (Get-ChildItem -Path $SourceFolder).fullname
  
  #Make backup log
  $BackupLog = $LogDestination +'\'+ (New-TimedStampFileName -baseNAME $LogFileName -Extension csv -StampFormat 2)
  
  #Loop through the directories
  foreach($folder in $folderList)
  {
    #Find Backup in folder
    $var = Get-ChildItem -Path $folder
    #Setup .CSV column names
    $outputList = [PSCustomObject]@{
      Name = $var.BaseName
      Size = $var.Length
      Date = $var.CreationTime
    }
    # Export Backup Information
    $outputList | Export-Csv -NoTypeInformation -Path $BackupLog -Append


  } # End Foreach(Folder in FolderList)
} # End function Export-FileInformation
function Export-FilesFolders
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$SourceFolder = "$env:HOMEDRIVE\temp\BackupSource",
    [string]$FileType = $null,
    [string]$DestinationFolder = "$env:HOMEDRIVE\temp\BackupDestination",
    [int]$DaysBack = 5000,
    [string]$LogDestination = "$env:HOMEDRIVE\Temp\Logs",
    [Parameter(Mandatory,HelpMessage='Get list of installed software by installed date or abc')]
    [ValidateSet('InstallDate', 'DisplayName','DisplayVersion')] 
    [String]
    [Switch]$Files,
    [Switch]$Folders,
    [Switch]$Copy,
    [Switch]$Move,
    [Switch]$Delete
  )
  #Declare obsolete backups
  $old = (Get-date).addDays(-$DaysBack)
  if($Files -and ($FileType -eq $null))
  {
    Write-Warning -Message "You want to copy files, but have't selected the file type. Rerun and add the 'FileType' parameter."
  }
  Else
  {
    Write-Debug -Message 'FileType is {0}' -f $FileType
    Get-ChildItem -Path $SourceFolder -File -Filter ('*.{0}' -f $FileType) | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$DaysBack)} |  Copy-Item -Destination $DestinationFolder
  }
   
  if($Folders)
  # if Folders, than copy folders
  {
    Copy-Item -Container -Path $SourceFolder -Recurse -Destination $DestinationFolder
  }
  if($Move)
  # If Move, than copy and delete files
  {
    Write-Warning -Message 'This currently does nothting'
  }
  if($Delete){
    if($DaysBack -eq 5000){
      $PSDefaultParameterValues.Add('Remove*:WhatIf',$True)
    }
    #Delete old backups
    #Get-ChildItem -Path "$DestinationFolder" | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $old } | Remove-Item -Force
    $PSDefaultParameterValues.Remove('remove*:WhatIf',$True)
  }
} # End function Export-FilesFolders

# The following line is for testing or to actually run this with hard coded information.
# Export-FileInformation -SourceFolder C:\Temp\BackupSource -DestinationFolder C:\temp\BackupDestination -FileType ps1 -LogFileName exportfile


