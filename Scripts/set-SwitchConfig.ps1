$OldMac = Import-Csv -Path 'C:\Temp\SwitchConfig\OldMac.csv'
$NewMac = Import-Csv -Path 'C:\Temp\SwitchConfig\NewMac.csv'

function set-SwitchConfig
{
  [cmdletbinding()]
  param()
      

   # for($i = 0;$i -lt 5;$i++)
    #  {
   
    foreach($New in $NewMac)
    {
      Write-Verbose -Message "NEW: $New"
      switch -Wildcard ($New.MAC)
      {
        '12:*' 
        {
          $VLANConfig = 522
        }
        '15:*' 
        {
          $VLANConfig = 333
        }
        Default 
        {
          $VLANConfig = 'Unkown MAC'
        }
      }

      $PortConfig = (@'
This is a test: {1} -  {0}
'@ -f $VLANConfig, $New.Port)
    

    $PortConfig
  }
}
#}

set-SwitchConfig 





