$client = new-object System.Net.WebClient
$testpath = Test-Path "C:\aenc\msa\"
if (-Not $testpath) {mkdir "C:\aenc\msa\"}
$client.DownloadFile("https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe","C:\aenc\msa\putty.exe")

