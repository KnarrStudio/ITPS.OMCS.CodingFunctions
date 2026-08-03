function Set-PuttyTheme
{
  <#
      .SYNOPSIS
      Makes changes to all of the putty sessions based on a "Theme"
      .DESCRIPTION
      Makes changes to the colors, adds a timestamped log file locaiton, 

  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $false, Position = 0)]
    [System.String]
    $PuTTYLog = 'C:\Temp\putty.log',

    [Parameter(Mandatory = $false, Position = 1)]
    [System.String]$jsonFile = '.\Themes.json',
    
    [Parameter(Mandatory = $false, Position = 2)]
    [System.Int32]
    $TermWidth = 100
  )

  $ItemCount = 100
  $PuTTYSessions = (Get-ItemProperty -Path HKCU:\Software\Simontatham\PuTTY\Sessions\*)
  $ThemeSelection = $null
  $PuTTYLogLocation = $PuTTYLog.Replace('\','\\').Replace('.log','_&H-&Y&M&D-&T.log')
    
  $ShowBefore = 'Yellow' # Output colors
  $ShowAfter = 'Green' # Output colors
     
  
  function Get-ThemeSettingsFromJSON 
  {
    <#
        .SYNOPSIS
        Get-ThemeSettingsFromJSON  
    #>
    param
    (
      [Parameter(Mandatory = $false, Position = 0)]
      [AllowNull()]
      [String]$JSONFilePath
    )
    
    function Convert-JSONToHash
    {
      param(
        [AllowNull()]
        [Object]$root
      )
      $hash = @{}
      $keys = $root |
      Get-Member -MemberType NoteProperty |
      Select-Object -ExpandProperty Name
      $keys | ForEach-Object -Process {
        $key = $_
        $obj = $root.$($_)
        if($obj -match '@{')
        {
          $nesthash = Convert-JSONToHash -root $obj
          $hash.add($key,$nesthash)
        }
        else
        {
          $hash.add($key,$obj)
        }
      }
      return $hash
    }
    
    if(Test-Path -Path $JSONFilePath -ErrorAction SilentlyContinue)
    {
      Write-Verbose -Message 'Using JSON File'
      $ThemeSettings = Convert-JSONToHash -root $(Get-Content -Path $JSONFilePath -ErrorAction SilentlyContinue | ConvertFrom-Json)
    }
    $ThemeSettings
  }
  
  function Show-AsciiMenu 
  {
    <#
        .SYNOPSIS
        Quick Ascii Menu
      
    #>
    
    [CmdletBinding()]
    param
    (
      [string]$Title = 'Title',
      
      [String[]]$MenuItems = 'None',
      
      [string]$TitleColor = 'Red',
      
      [string]$LineColor = 'Yellow',
      
      [string]$MenuItemColor = $ShowBefore
    )
    Begin {
      # Set Variables
      $i = 1
      $Tab = "`t"
      $VertLine = '║'
      $Script:ItemCount = $MenuItems.Count
           
      function Write-HorizontalLine
      {
        param
        (
          [Parameter(Position = 0)]
          [string]
          $DrawLine = 'Top'
        )
        Switch ($DrawLine) {
          Top 
          {
            Write-Host -Object ('╔{0}╗' -f $HorizontalLine) -ForegroundColor $LineColor
          }
          Middle 
          {
            Write-Host -Object ('╠{0}╣' -f $HorizontalLine) -ForegroundColor $LineColor
          }
          Bottom 
          {
            Write-Host -Object ('╚{0}╝' -f $HorizontalLine) -ForegroundColor $LineColor
          }
        }
      }
      
      function Get-Padding
      {
        param
        (
          [Parameter(Mandatory, Position = 0)]
          [int]$Multiplier 
        )
        "`0"*$Multiplier
      }
      
      function Write-MenuTitle
      {
        Write-Host -Object ('{0}{1}' -f $VertLine, $TextPadding) -NoNewline -ForegroundColor $LineColor
        Write-Host -Object ($Title) -NoNewline -ForegroundColor $TitleColor
        if($TotalTitlePadding % 2 -eq 1)
        {
          $TextPadding = Get-Padding -Multiplier ($TitlePaddingCount + 1)
        }
        Write-Host -Object ('{0}{1}' -f $TextPadding, $VertLine) -ForegroundColor $LineColor
      }
      function Write-MenuItems
      {
        foreach($menuItem in $MenuItems)
        {
          $number = $i++
          $ItemPaddingCount = $TotalLineWidth - $menuItem.Length - 6 #This number is needed to offset the Tab, space and 'dot'
          $ItemPadding = Get-Padding -Multiplier $ItemPaddingCount
          Write-Host -Object $VertLine  -NoNewline -ForegroundColor $LineColor
          Write-Host -Object ('{0}{1}. {2}{3}' -f $Tab, $number, $menuItem, $ItemPadding) -NoNewline -ForegroundColor $LineColor
          Write-Host -Object $VertLine -ForegroundColor $LineColor
        }
      }
    }
    
    Process {
      $TitleCount = $Title.Length
      $LongestMenuItemCount = ($MenuItems | Measure-Object -Maximum -Property Length).Maximum
      Write-Debug -Message ('LongestMenuItemCount = {0}' -f $LongestMenuItemCount)
      
      if  ($TitleCount -gt $LongestMenuItemCount)
      {
        $ItemWidthCount = $TitleCount
      }
      else
      {
        $ItemWidthCount = $LongestMenuItemCount
      }
      
      if($ItemWidthCount % 2 -eq 1)
      {
        $ItemWidth = $ItemWidthCount + 1
      }
      else
      {
        $ItemWidth = $ItemWidthCount
      }
      Write-Debug -Message ('Item Width = {0}' -f $ItemWidth)
      
      $TotalLineWidth = $ItemWidth + 10
      Write-Debug -Message ('Total Line Width = {0}' -f $TotalLineWidth)
      
      $TotalTitlePadding = $TotalLineWidth - $TitleCount
      Write-Debug -Message ('Total Title Padding  = {0}' -f $TotalTitlePadding)
      
      $TitlePaddingCount = [math]::Floor($TotalTitlePadding / 2)
      Write-Debug -Message ('Title Padding Count = {0}' -f $TitlePaddingCount)
      
      $HorizontalLine = '═'*$TotalLineWidth
      $TextPadding = Get-Padding -Multiplier $TitlePaddingCount
      Write-Debug -Message ('Text Padding Count = {0}' -f $TextPadding.Length)
      
      
      Write-HorizontalLine -DrawLine Top
      Write-MenuTitle
      Write-HorizontalLine -DrawLine Middle
      Write-MenuItems
      Write-HorizontalLine -DrawLine Bottom
    }
    
    End {
      
    }
  }
  
  Function Show-PuTTYSessions 
  {
    Param
    ([Parameter(Mandatory,Position = 0)]$PuTTYSessions,[Parameter(Mandatory = $true)]$KeyName,[Parameter(Mandatory = $true)]$ForegroundColor)
    
    $PuTTYSessions | 
    ForEach-Object -Process {
      $SessionName = $_.PSChildName
      $logtype = Get-ItemProperty -Path "HKCU:\Software\Simontatham\PuTTY\Sessions\$SessionName" -Name $KeyName
      Write-Host -Object ('{0,-24}{2}{1}' -f $SessionName, $logtype.$KeyName, ' = ') -ForegroundColor $ForegroundColor
    }
  }
  Function Set-PuTTYSessions 
  {
    Param
    ([Parameter(Mandatory,Position = 0)]$PuTTYSessions,
      [Parameter(Mandatory = $true)][String]$KeyName,
      [Parameter(Mandatory = $true)][String]$KeyValue
    )
    
    $PuTTYSessions | 
    ForEach-Object -Process {
      $SessionName = $_.PSChildName       
      Set-ItemProperty -Path "HKCU:\Software\Simontatham\PuTTY\Sessions\$SessionName"  -Name $KeyName -Value $KeyValue
    }
  }
  
  $ThemeSettings = Get-ThemeSettingsFromJSON -JSONFilePath $jsonFile -Verbose
  $MenuItems = ($ThemeSettings | ForEach-Object -Process {
      $_.Keys
  })
  $MenuItems += 'Exit'
  
  
  Show-AsciiMenu -MenuItems $MenuItems -Title 'Putty Theme and Reg File Builder'
  Do 
  {
    Try
    {
      [int]$ThemeSelection = Read-Host -Prompt 'Select Number'
    }
    catch
    {
      $ThemeSelection = 100
    }
    $PuttyThemeSelection = $MenuItems[$ThemeSelection-1]
    if($PuttyThemeSelection -eq 'Exit')
    {
      Return
    }
  }
  Until($ThemeSelection -le $($MenuItems.Count))
  
  $Colour0 = $ThemeSettings[$PuttyThemeSelection].TxtColor    # Default Forground
  $Colour2 = $ThemeSettings[$PuttyThemeSelection].BkColor     # Default Background
  $Colour5 = $ThemeSettings[$PuttyThemeSelection].CrsrColor   # Cursor Colour
  $TermWidth = $ThemeSettings[$PuttyThemeSelection].TermWidth # Terminal Width (Window Columns)
  $Beep = $ThemeSettings[$PuttyThemeSelection].Beep           # Style of Bell (0=None;1=System;2=Visual;3=Speaker;4=Custom file)
  $BeepInd = $ThemeSettings[$PuttyThemeSelection].BeepInd     # Taskbar indication (0=Disabled;1=Flashing;2=Steady)
  
  
  # Show and set the Log Type
  Show-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'LogType' -ForegroundColor $ShowBefore
  Set-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'LogType' -KeyValue 2
  Show-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'LogType' -ForegroundColor $ShowAfter
  
  # Show and set the Log Name
  Show-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'LogFileName' -ForegroundColor $ShowBefore
  Set-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'LogFileName' -KeyValue $PuTTYLogLocation
  Show-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'LogFileName' -ForegroundColor $ShowAfter
  
  # Show and set the Colours
  Show-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'Colour0' -ForegroundColor $ShowBefore
  Set-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'Colour0' -KeyValue $Colour0
  Show-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'Colour2' -ForegroundColor $ShowBefore
  Set-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'Colour2' -KeyValue $Colour2
  Show-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'Colour5' -ForegroundColor $ShowBefore
  Set-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'Colour5' -KeyValue $Colour5
  Show-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'Colour0' -ForegroundColor $ShowAfter
  Show-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'Colour2' -ForegroundColor $ShowAfter
  Show-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'Colour5' -ForegroundColor $ShowAfter
  
  Set-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'TermWidth' -KeyValue $TermWidth
  Set-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'Beep' -KeyValue $Beep
  Set-PuTTYSessions -PuTTYSessions $PuTTYSessions -KeyName 'BeepInd' -KeyValue $BeepInd
}

