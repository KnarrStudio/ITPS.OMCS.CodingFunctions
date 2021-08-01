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