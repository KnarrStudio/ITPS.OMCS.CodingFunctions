$SoftwareName = @('Axway', 'Mozilla', 'Core Interpreter ', 'Github') 
<#bookmark Get Installed Software #>
Function Get-InstalledSoftware    
{
  [cmdletbinding(SupportsPaging)]
  Param(
    [Parameter(ValueFromPipeline, Position = 0)]
    [String[]]$SoftwareName    ,
        [Parameter(ValueFromPipeline, Position = 1)]
        
        [ValidateSet('DisplayName','DisplayVersion','InstallDate')] 
        [String]$ReturnParmeter
  )
  Begin { 
    $SoftwareOutput = @()
    $Installed64Software = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*)
    #$Installed32Software = (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* )
    $InstalledSoftware = $Installed64Software| Select-Object -Property Installdate, DisplayVersion, DisplayName
  }
  Process {
    Try 
    {
      foreach($Item in $SoftwareName)
      {
        $SoftwareOutput += $InstalledSoftware.Where({
            $_.DisplayName -match $Item
        })
      } 
    }
    Catch 
    {
      # get error record
      $ErrorMessage  = $_.exception.message
      Write-Verbose -Message ('Error Message: {0}' -f $ErrorMessage)
    }
  }
  End{ 
          Switch ($ReturnParmeter){
          'DisplayName' 
          {
            $SoftwareOutput.DisplayName
          }
          'DisplayVersion' 
          {
            $SoftwareOutput.DisplayVersion
          }
          default 
          {
            $SoftwareOutput
          }
        }
  }
} # End InstalledSoftware-Function
Get-InstalledSoftware -SoftwareName $SoftwareName -ReturnParmeter DisplayVersion