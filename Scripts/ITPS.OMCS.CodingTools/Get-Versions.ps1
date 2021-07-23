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