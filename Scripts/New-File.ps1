function New-File
{
  <#
      .SYNOPSIS
      Creates a file and increments the name "(1),(2),(3)..." if the file exists.

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
      
      This is a string input so you can use "foo" or "bar" and it will work.  
      Try $($env:username) or $($env:computername)

      
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
      

      Regarding the Get-TimeStamp:
      The "Get-TimeStamp", which was originally built into the script, but pulled out to be more widely used.
      Get-TimeStamp -Format YYYY-MM-DD -AsFilename 
      Excepted Formats: formats - YYYYMMDD, DDHHmmss, YYMMDD-24HHmm, YYYYMMDDHHmm, MM-DD-YY_HHmmss, YYYY-MM-DD, JJJHHmmss, DayOfYear, tzOffset
      The formats with the "ss" on the end are for seconds, so every second you could create a new file.  
      The formats with the "-f" on the end are the ones which have special characters and will need the "-AsFilename" to be used in a filename


      .INPUTS
      String

      .OUTPUTS
      File with name basesd in input

  #>

  [cmdletbinding(DefaultParameterSetName = 'FileName Set')]
  #[cmdletbinding()]
  param
  (
    [Parameter(Mandatory,Position = 0,ValueFromPipeline, ValueFromPipelineByPropertyName,HelpMessage = 'File name "Fullname.extension" | example: test.txt',ParameterSetName = 'FileName Set')]
    [Parameter(Mandatory,Position = 0,ValueFromPipeline, ValueFromPipelineByPropertyName,HelpMessage = 'File name "Fullname.extension" | example: test.txt',ParameterSetName = 'Increment')]
    [Parameter(Mandatory,Position = 0,ValueFromPipeline, ValueFromPipelineByPropertyName,HelpMessage = 'File name "Fullname.extension" | example: test.txt',ParameterSetName = 'Overwrite')]
    [Parameter(Mandatory,Position = 0,ValueFromPipeline, ValueFromPipelineByPropertyName,HelpMessage = 'File name "Fullname.extension" | example: test.txt',ParameterSetName = 'Amend')]
    [Alias('file')]
    [String]$Filename,
    
    [Parameter(Mandatory = $false,Position = 1,ValueFromPipeline, ValueFromPipelineByPropertyName,ParameterSetName = 'FileName Set')]
    [Parameter(Mandatory = $false,Position = 1,ValueFromPipeline, ValueFromPipelineByPropertyName,ParameterSetName = 'Increment')]
    [Parameter(Mandatory = $false,Position = 1,ValueFromPipeline, ValueFromPipelineByPropertyName,ParameterSetName = 'Overwrite')]
    [Parameter(Mandatory = $false,Position = 1,ValueFromPipeline, ValueFromPipelineByPropertyName,ParameterSetName = 'Amend')]
    [String]$Tag, 
    
    [Parameter(Mandatory = $true,Position = 2,HelpMessage = 'Amend or Append file',ParameterSetName = 'Amend')]
    [Switch]$Amend,
    
    [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Creates new file with "(1)"',ParameterSetName = 'Increment')]
    [Switch]$Increment = $true,
    
    [Parameter(Mandatory = $true,Position = 2,HelpMessage = 'Overwrite or Delete and recreate file',ParameterSetName = 'Overwrite')]
    [Switch]$Overwrite,
    
    [Parameter(Mandatory = $false,HelpMessage = 'Returns the filename or filepath.')]
    [ValidateSet('Filename','Filepath')] 
    [Parameter(ParameterSetName = 'FileName Set')]
    [Parameter(ParameterSetName = 'Increment')]
    [Parameter(ParameterSetName = 'Overwrite')]
    [Parameter(ParameterSetName = 'Amend')]
    [String]$Return = 'Filename'
  )
  #Parameter Notes
  # The regex line sometimes is broken when editing: This is the correct syntex: $ptrn = [regex]'^[A-Za-z0-9(?:()_ -]+\.[A-Za-z0-9]*$'
  # Timestamp option - $(Get-Date -UFormat '%y%m%d') 
 
  $ItemType = 'File'
  $dot = '.'
  $SplatFile = @{}

  if($Filename.Contains($dot))
  {
    $fileExt = ('{0}{1}' -f $dot, $Filename.Split($dot)[-1])
    $fileBaseName = $Filename.Replace($fileExt,'')
  }else{
  $fileBaseName = $Filename
  $fileExt =''
  }

  if($Tag)
  {
    $DatedName = ('{0}-{1}' -f $fileBaseName, $Tag)
  }
  else
  {
    $DatedName = $fileBaseName
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
