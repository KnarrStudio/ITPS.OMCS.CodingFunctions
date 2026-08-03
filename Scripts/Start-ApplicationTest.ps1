$ConfigFile = '.\convertto.json'
$HashConfig = Get-Content $ConfigFile | ConvertFrom-Json -AsHashtable

$PDFApplicationTestSplat = $HashConfig.PDFApplicationTestSplat
$PowerPointApplicationTestSplat = $HashConfig.PowerPointApplicationTestSplat
$WordpadApplicationTestSplat = $HashConfig.WordpadApplicationTestSplat

<#
Original version
﻿$PDFApplicationTestSplat = @{
  TestFile    = '\\FastCruise\FastCruiseTestFile.pdf'
  TestProgram = "${env:ProgramFiles(x86)}\Adobe\Acrobat 2015\Acrobat\Acrobat.exe"
  ProcessName = 'Acrobat'
}
$PowerPointApplicationTestSplat = @{
  TestFile    = '\\FastCruise\FastCruiseTestFile.pptx'
  TestProgram = "${env:ProgramFiles(x86)}\Microsoft Office\Office16\POWERPNT.EXE"
  ProcessName = 'POWERPNT'
}
$WordpadApplicationTestSplat = @{
  TestFile    = "$env:windir\DtcInstall.log"
  TestProgram = "$env:ProgramFiles\Windows NT\Accessories\wordpad.exe"
  ProcessName = 'wordpad'
}

#>


function Start-ApplicationTest
{
  param
  (
    [Parameter(Mandatory, Position = 0)]
    [string]$FunctionTest,
    [Parameter(Mandatory, Position = 1)]
    [string]$TestFile,
    [Parameter(Mandatory, Position = 2)]
    [string]$TestProgram,
    [Parameter(Mandatory, Position = 3)]
    [string]$ProcessName
  )
  $DescriptionLists = [Ordered]@{
    FunctionResult = 'Good', 'Failed'
  }

  if($FunctionTest -eq 'Y')
  {
    try
    {
      Write-Verbose -Message ('Attempting to open {0} with {1}' -f $TestFile, $ProcessName)
      Start-Process -FilePath $TestProgram -ArgumentList $TestFile

      Write-Host -Object ('The Fast Cruise Script will continue after {0} has been closed.' -f $ProcessName) -BackgroundColor Red -ForegroundColor Yellow
      Write-Verbose -Message ('Wait-Process: {0}' -f $ProcessName)
      Wait-Process -Name $ProcessName
        
      $TestResult = $DescriptionLists.FunctionResult | Out-GridView -Title $ProcessName -OutputMode Single
    }
    Catch
    {
      Write-Verbose -Message 'TestResult: Failed'
      $TestResult = $DescriptionLists.FunctionResult[1]
    }
  }
  else
  {
    Write-Verbose -Message 'TestResult: Bypassed'
    $TestResult = 'Bypassed'
  }
  Return $TestResult
}

Do
{
  $FunctionTest = Read-Host -Prompt 'Perform Function Tests (MS Office and Adobe) Y/N'
}
While(($FunctionTest -ne 'N') -and ($FunctionTest -ne 'Y')) 
#Start-ApplicationTest -FunctionTest $FunctionTest @PDFApplicationTestSplat
Start-ApplicationTest -FunctionTest $FunctionTest @WordpadApplicationTestSplat -Verbose
