$head = @"
<style>
body   {
    color:Yellow;
    background-color:Navy;
    font-family:Tahoma;
    font-size:12pt;
    }

table, tr, td {
    border:1px solid Crimson;
    color:Pink;
    background-color:Green;
    }

th  {
    color:Cyan;
    background-color:black;
    }

table  {
    margin-left:50px;
    }

</style>
"@



$csv = (Import-Csv C:\temp\Reports\Ping.csv | Where-Object{$_.DateStamp -gt $((Get-Date).AddDays(-81))})

$csv | ConvertTo-Html -Head $head | out-file "C:\temp\fibertest1.html"

Start-Process -FilePath msedge.exe -ArgumentList  C:\temp\fibertest1.html
  