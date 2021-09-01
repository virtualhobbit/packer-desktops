$ErrorActionPreference = "Stop"

$webserver = "intranet.mdb-lab.com"
$url = "http://" + $webserver
$exe = "VMwareHorizonOSOptimizationTool-x86_64-2107.exe"
$arg = '-o -t "VMware Templates\Windows 10 and Server 2016 or later" -storeapp remove-all -f 0 1 2 3 4 5 6 7 8 9 10'
$siUrl = "https://download.sysinternals.com/files"
$zip = "SDelete.zip"

# Get SDelete
Invoke-WebRequest -Uri ($siUrl + "/" + $zip) -OutFile $env:TEMP\$zip

# Unzip it
Expand-Archive -LiteralPath "$env:TEMP\$zip" -DestinationPath $env:Temp -Confirm:$false

# Verify connectivity
$connTestResult = Test-NetConnection -Computername $webserver -Port 80
if ($connTestResult.TcpTestSucceeded){
  # Get the OSOT file
  Invoke-WebRequest -Uri ($url + "/" + $exe) -OutFile $env:TEMP\$exe

  # Run OSOT
  Try
  {
    Start-Process $env:TEMP\$exe -ArgumentList $arg -Passthru -Wait -ErrorAction stop
  }
  Catch
  {
    Write-Error "Failed to run OSOT"
    Write-Error $_.Exception
    Exit -1
  }

  # Delete files
  Remove-Item -Path $env:TEMP\$exe -Confirm:$false
}

# Delete files
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
$source = [IO.Compression.ZipFile]::OpenRead("$env:TEMP\$zip")
$entries = $source.Entries
ForEach ($file in $entries){
  Remove-Item -Path $env:TEMP\$file -Confirm:$false
}
$source.Dispose()
Remove-Item $env:TEMP\$zip -Confirm:$false