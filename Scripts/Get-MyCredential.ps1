#requires -Version 3.0 -Modules Microsoft.PowerShell.LocalAccounts
<#
    .SYNOPSIS
    Stores and retrieves credentials from a file. 
    
    .DESCRIPTION
    Stores your credentials in a file and retreives them when you need them.
    Allows you to speed up your scripts.  
    It looks at when your password was last reset and forces an update to the file if the dates don't match.  
    Because this only works with the specific user logged into a specific computer the name of the file will alway have both bits of information in it.
    
    .PARAMETER Reset
    Allows you to force a password change.

    .PARAMETER Path
    Path to the credential file, if not in current directory.

    .EXAMPLE
    Get-MyCredential

    .EXAMPLE
    Get-MyCredential -Reset -Path Value
    Allows you to change (reset) the password in the password file located at the path.  Then returns the credentials

    .NOTES
    Place additional notes here.

    .LINK
    'https://github.com/KnarrStudio/ITPS.OMCS.CodingFunctions/blob/master/Scripts/Get-MyCredential.ps1'

    .INPUTS
    String

    .OUTPUTS
    Object
#>
[CmdletBinding(SupportsShouldProcess, PositionalBinding = $false, ConfirmImpact = 'Medium',
HelpUri = 'https://github.com/KnarrStudio/ITPS.OMCS.CodingFunctions/blob/master/Scripts/Get-MyCredential.ps1')]
[Alias('gmc')]
[OutputType([Object])]
Param
(
  [Parameter(Mandatory = $false,Position = 0)]
  [Switch]$Reset,
  [Parameter(Mandatory = $false,Position = 1)]
  [String]$FolderPath = "$env:USERPROFILE\.PsCredentials"
)
Begin
{
  $PasswordLastSet = (Get-LocalUser -Name ${env:USERNAME}).PasswordLastSet #| Select-Object -Property PasswordLastSet 
  $credentialPath = ('{0}\myCred_{1}_{2}.xml' -f $FolderPath, ${env:USERNAME}, ${env:COMPUTERNAME})
    
  if(-not (Test-Path -Path $credentialPath))
  {
    $null = New-Item -Path $credentialPath -ItemType File -Force
  }
  $LastWriteTime = (Get-ChildItem -Path $credentialPath).LastWriteTime

  function Script:Set-MyCredential
  {
    param
    (
      [Parameter(Mandatory = $true)]
      [string]$credentialPath
    )
    $credential = Get-Credential -Message 'Credentials to Save'
    $credential | Export-Clixml -Path $credentialPath -Force
  }    
}
Process
{
  if(($Reset -eq $true) -or ($LastWriteTime -lt $PasswordLastSet))
  {
    Set-MyCredential -credentialPath $credentialPath
  }
  $creds = Import-Clixml -Path $credentialPath
}
End
{
  Return $creds
}
