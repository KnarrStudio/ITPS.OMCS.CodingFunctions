#requires -Version 3.0
function script:Get-ComputerLocation 
{
  $ComputerLocation  = [ordered]@{
    Department = ''
    Building   = ''
    Room       = ''
    Desk       = ''
  }
  $Location = @{
    Department = @{
      MCDO = @{
        Building = @{
          AV29  = @{
            Room = @(
              8, 
              9, 
              10, 
              11, 
              12, 
              13, 
              14, 
              15, 
              16, 
              17, 
              18, 
              19, 
              20
            )
          }
          AV34  = @{
            Room = @(
              1, 
              6, 
              7, 
              8, 
              201, 
              202, 
              203, 
              204, 
              205
            )
          }
          ELC3  = @{
            Room = @(
              100, 
              101, 
              102, 
              103, 
              104, 
              105, 
              106, 
              107
            )
          }
          ELC31 = @{
            Room = @(
              1
            )
          }
          ELC32 = @{
            Room = @(
              1
            )
          }
          ELC33 = @{
            Room = @(
              1
            )
          }
          ELC34 = @{
            Room = @(
              1
            )
          }
          ELC35 = @{
            Room = @(
              1
            )
          }
          ELC36 = @{
            Room = @(
              1
            )
          }
        }
      }
      CA   = @{
        Building = @{
          AV29 = @{
            Room = @(
              1, 
              2, 
              3, 
              4, 
              5, 
              6, 
              7, 
              23, 
              24, 
              25, 
              26, 
              27, 
              28, 
              29, 
              30
            )
          }
          AV34 = @{
            Room = @(
              1, 
              2, 
              3, 
              200, 
              214
            )
          }
        }
      }
      PRO  = @{
        Building = @{
          AV34 = @{
            Room = @(
              210, 
              211, 
              212, 
              213
            )
          }
          ELC4 = @{
            Room = @(
              1, 
              100, 
              101, 
              102, 
              103, 
              104, 
              105, 
              106, 
              107
            )
          }
        }
      }
      TJ   = @{
        Building = @{
          AV34 = @{
            Room = @(
              2, 
              3, 
              13, 
              11
            )
          }
          ELC2 = @{
            Room = @(
              1
            )
          }
        }
      }
    }
  }
  $Desk       = @('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I')

  [string]$Script:LclDept = $Location.Department.Keys | Out-GridView -Title 'Department' -PassThru
  [string]$Script:LclBuild = $Location.Department[$LclDept].Building.Keys | Out-GridView -Title 'Building' -PassThru
  [string]$Script:LclRm = $Location.Department[$LclDept].Building[$LclBuild].Room | Out-GridView -Title 'Room' -PassThru
  [string]$Script:LclDesk = $Desk | Out-GridView -Title 'Desk' -PassThru
  $ComputerLocation['Department'] = $LclDept     
  $ComputerLocation['Building'] = $LclBuild
  $ComputerLocation['Room'] = $LclRm
  $ComputerLocation['Desk'] = $LclDesk
} 

Get-ComputerLocation  
Write-Host -Object ('OSD-OMC-{0}-{1}-{2}{3}' -f $LclDept, $LclBuild, $LclRm, $LclDesk) -ForegroundColor Magenta
