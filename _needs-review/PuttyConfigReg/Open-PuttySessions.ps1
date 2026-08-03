$LoginName = 'pi'
$PuttyPath = 'C:\Users\New User\OneDrive\Downloads\putty.exe'

$PuTTYSessions = Get-ItemProperty -Path HKCU:\Software\Simontatham\PuTTY\Sessions\*

function Start-PuttySession
{
  param
  (
    [Object]
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Data to process")]
    $InputObject
  )
  process
  {
    
      & $PuttyPath -load $InputObject.pschildname  ('{0}@{1}' -f $LoginName, $InputObject.hostname)
    
  }
}


$MySession = $PuTTYSessions |
Select-Object -Property pschildname, hostname |
Out-GridView -PassThru

$MySession | Start-PuttySession




