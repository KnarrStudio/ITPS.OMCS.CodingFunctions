[cmdletbinding()]
param(
  [Parameter(Position = 1)]
  [Object]$ThemeHash
  ,
  [Parameter(Position = 0)]
  [String]$ThemeFile = '.\Themes.json'
)


$RgbColor = @{
  'Black' = '0,0,0'
  'Blue' = '0,0,255'
  'Green' = '0,255,0'
  'Red'  = '255,0,0'
  'Yellow' = '255,255,0'
  'Gray' = '85,85,85'
  'White' = '255,255,255'
}

$TermWidth = 100
$Beep = 2
$BeepInd = 1
$ThemeHash = @{
  Saroja  = @{
    TxtColor       = '0,255,255'
    BkColor        = '255,0,255'
    CrsrColor      = '255,0,0'
    TermWidth      = 100
    Beep           = 2
    BeepInd        = 1
    ThemeSelection = 'Saroja'
  }
  Lonnie  = @{
    TxtColor       = '0,255,255'
    BkColor        = '255,0,255'
    CrsrColor      = '255,0,0'
    TermWidth      = 100
    Beep           = 2
    BeepInd        = 1
    ThemeSelection = 'Lonnie'
  }
  Default = @{
    TxtColor       = $RgbColor.Gray
    BkColor        = $RgbColor.Black
    CrsrColor      = $RgbColor.Gray
    TermWidth      = 80
    Beep           = 0
    BeepInd        = 0
    ThemeSelection = 'Default'
  }
  SIPR    = @{
    TxtColor       = $RgbColor.Gray
    BkColor        = $RgbColor.Black
    CrsrColor      = $RgbColor.Red
    TermWidth      = 100
    Beep           = 2
    BeepInd        = 1
    ThemeSelection = 'SIPR'
  }
  NIPR    = @{
    TxtColor       = $RgbColor.Gray
    BkColor        = $RgbColor.Black
    CrsrColor      = $RgbColor.Green
    TermWidth      = 100
    Beep           = 2
    BeepInd        = 1
    ThemeSelection = 'NIPR'
  }
}

$ThemeHash |
ConvertTo-Json -Depth 5 |
Out-File -FilePath '.\Themes.json'

