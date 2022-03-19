<#
    .Synopsis
    Short description
    .DESCRIPTION
    Long description
    .EXAMPLE
    Example of how to use this cmdlet
    .EXAMPLE
    Another example of how to use this cmdlet
#>
function Get-MyCredential
{
  [CmdletBinding(SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
  [Alias('gmc')]
  [OutputType([int])]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
    Position = 0)]
    $Param1,

    # Param2 help description
    [int]
    $Param2
  )

  Begin
  {
    Get-LocalUser $env:USERNAME | Select-Object -Property passwordlastset 
    
    # save PSCredential in the file

    $WriteTime = (Get-ChildItem -Path ".\myCred_${env:USERNAME}_${env:COMPUTERNAME}.xml").LastWriteTime

    if($WriteTime -gt $(Get-Date))
    {
      $credential = Get-Credential
      $credential | Export-Clixml -Path ".\myCred_${env:USERNAME}_${env:COMPUTERNAME}.xml"
    }
    Import-Clixml -Path ".\myCred_${env:USERNAME}_${env:COMPUTERNAME}.xml"
  }
  Process
  {
  }
  End
  {
  }
}
