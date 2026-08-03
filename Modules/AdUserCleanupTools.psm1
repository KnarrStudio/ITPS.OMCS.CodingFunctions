#requires -Version 2.0 -Module ActiveDirectory 

  <#
      .SYNOPSIS
      Short Description
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Invoke-AdUserCleanup
      explains how to use the command
      can be multiple lines
      .EXAMPLE
      Invoke-AdUserCleanup
      another example
      can have as many examples as you like
  #>


  #import the Active Directory module if not already up and loaded
  if(!(Get-Module -name ActiveDirectory))
  {
    Write-Verbose -Message 'Loading Active Directory PowerShell Module'
    try{Import-Module -Name ActiveDirectory -ErrorAction SilentlyContinue}
    finally{Write-Output 'Unable to load AD module'}
  }
  
  function Disable-InactiveAdUser
  {
    <#
        .SYNOPSIS
        Disables AD User Accounts after the "DaysBack" period of time.
      
        .PARAMETER DaysBack
        Days back from current Date.  Used to define the oldest date of interest.  Items older will be acted on.
      
        .EXAMPLE
        Invoke-AdUserDisable -DaysBack VALUE
        This will disable the user's account which has been inactive over the past VALUE days.
      
        .NOTES
        Place additional notes here.
      
        .LINK
      
        The first link is opened by Get-Help -Online Invoke-AdUserDisable
    #>
    [CmdletBinding()]
    param(
      [int]$DaysBack = 30
    )
    $DateStamp = Get-Date -Format dd/MM/yyyy
    $inactiveUsers = Search-ADAccount -AccountInactive -UsersOnly -TimeSpan ('{0}.00:00:0' -f $DaysBack)
    $inactiveUsers | Disable-AdUser -Confirm:$False
    foreach($InactiveUser in $inactiveUsers)
    {
      $InactiveUser | Set-aduser -discription ('{0} - Account disable by script' -f $DateStamp)
    } # End - foreach($InactiveUser in $inactiveUsers)
  } # End - function Invoke-AdUserDisable
  
  
  function Remove-DisabledADUserFromGroups
  {
    <#
        .SYNOPSIS
        Removes disabled ueser from groups
      
        .PARAMETER employeeSAN
        SamAccountName.
      
        .PARAMETER adServer
        Domain Controller.
      
        .EXAMPLE
        Remove-ADUserGroups -employeeSAN Value -adServer Value
        Removes AD User from all group membership except for 'Domain Users'
      
        .INPUTS
        List of input types that are accepted by this function.
      
        .OUTPUTS
        List of output types produced by this function.
    #>
    [CmdletBinding()]
    param
    (
      [string]$employeeSAN = $null,
      [string]$adServer = 'adserver.yourcompany.com'
    )
    try
    {
      Get-ADUser -Identity $employeeSAN -Server $adServer
      #if that doesn't throw you to the catch this person exists. So you can continue
      
      $ADgroups = Get-ADPrincipalGroupMembership -Identity $employeeSAN | Where-Object -FilterScript {
        $_.Name -ne 'Domain Users'
      }
      if ($ADgroups -ne $null)
      {
        Remove-ADPrincipalGroupMembership -Identity $employeeSAN -MemberOf $ADgroups -Server $adServer -Confirm:$False
      }
    }#end try
    catch
    {
      Write-Verbose -Message ('{0} is not in AD' -f $employeeSAN)
    }
  }
  
  
  function Remove-DisabledADUserAccounts
  {
    <#
        .SYNOPSIS
        Deletes disabled AD User Accounts after the "DaysBack" period of time.
      
        .PARAMETER DaysBack
        Days back from current Date.  Used to define the oldest date of interest.  Items older will be acted on.
      
        .EXAMPLE
        Invoke-AdUserDelete -DaysBack VALUE
        This will delete the user's account which has been inactive for VALUE1 days and disabled VALUE2 days.
      
        .NOTES
        Place additional notes here.
      
        .LINK
      
        The first link is opened by Get-Help -Online Invoke-AdUserDisable
    #>
    [CmdletBinding()]
    param(
      [int]$DaysBack = 45,
      [String]$ServerName = 'localhost'
    )
    $DisabledUsers = Search-ADAccount -AccountDisabled -UsersOnly -TimeSpan ('{0}.00:00:0' -f $DaysBack)
    foreach($DisabledUser in $DisabledUsers)
    {
      if ($PSCmdlet.ShouldProcess($DisabledUser.Name,'Remove')) 
      {
        $DisabledUser | Remove-AdUser -Confirm:$False
      } # End - if($PSCmdlet.ShouldProcess
    }
  }
  
  
  <#  $DisabledUserEvent = Get-WinEvent -ComputerName $ServerName -FilterHashtable @{logname='system';id=6006;StartTime=$DaysBack}
      foreach($DisabledUser in $DisabledUserEvent){
      if(
    
      $DisabledUser.message
      if($DisabledUserEvent.TimeCreated -lt $DaysBack){
      for
    
      }
    
      $DisabledUsers = Search-ADAccount -AccountInactive -UsersOnly -TimeSpan "$DaysBack.00:00:0"
      $DisabledUsers | Delete-AdUser -Confirm:$True
  #>
  
  
 Export-ModuleMember -Function Remove-DisabledADUserAccounts, Remove-DisabledADUserFromGroups, Disable-InactiveAdUser 


