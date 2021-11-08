$ErrorActionPreference = "Stop"

$webserver = "intranet.mdb-lab.com"
$url = "http://" + $webserver
$installer = "FSLogixAppsSetup.exe"
$listConfig = "/install /quiet /norestart"

# Verify connectivity
$connTestResult = Test-NetConnection -Computername $webserver -Port 80
if ($connTestResult.TcpTestSucceeded){
  # Get FSLogix installer
  Invoke-WebRequest -Uri ($url + "/" + $installer) -OutFile C:\$installer

  # Unblock installer
  Unblock-File C:\$installer -Confirm:$false

  # Install FSLogix
  Try 
  {
    Start-Process C:\$installer -ArgumentList $listConfig -PassThru -Wait
  }
  Catch
  {
    Write-Error "Failed to install FSLogix"
    Write-Error $_.Exception
    Exit -1 
  }

  # Cleanup on aisle 4...
  Remove-Item C:\$installer -Confirm:$false
}