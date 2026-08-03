$ComputerLocation = (@'

ComputerName (Assest Tag)
- {0}

Department
- {1}

Building
- {2}

Room
- {3}

Desk
- {4}
          
'@ -f 'ComputerName variable', 'Department variable', 'Building variable', 'Room variable', 'Desk variable')

$MessageSplat = @{
Message   = $ComputerLocation
TitleBar     = 'Title Bar'
}

function Show-MessageBox
{
  [cmdletbinding(DefaultParameterSetName = 'Message')]
  param(
    [Parameter(Mandatory=$false,ParameterSetName = 'Message')]
    [Switch]$YesNoBox,
    [Parameter(Mandatory=$False,ParameterSetName = 'Input')]
    [Switch]$InputBox,
    [Parameter(Mandatory,Position = 0)]
    [string]$Message,
    [Parameter(Mandatory,Position = 1)]
    [string]$TitleBar
    
  )
  Add-Type -AssemblyName Microsoft.VisualBasic
  
  
  if($InputBox){
    $Response = [Microsoft.VisualBasic.Interaction]::InputBox($Message, $TitleBar)
  }
  if($YesNoBox){  
    $Response = [Microsoft.VisualBasic.Interaction]::MsgBox($Message, 'YesNo,SystemModal,MsgBoxSetForeground', $TitleBar)
  }
  Return $Response
}

Show-MessageBox -YesNoBox @MessageSplat


