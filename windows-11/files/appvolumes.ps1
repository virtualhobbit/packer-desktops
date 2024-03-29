$ErrorActionPreference = "Stop"

$webserver = "intranet.mdb-lab.com"
$url = "http://" + $webserver
$installer = "App Volumes Agent.msi"
$appVolumesServer = "appvolumes.nl.mdb-lab.com"
$listConfig = "/i ""C:\$installer"" /qn REBOOT=ReallySuppress MANAGER_ADDR=$appVolumesServer MANAGER_PORT=443 EnforceSSLCertificateValidation=1"

# Verify connectivity
$connTestResult = Test-NetConnection -Computername $webserver -Port 80
if ($connTestResult.TcpTestSucceeded){
  # Get AppVolumes Agent
  Invoke-WebRequest -Uri ($url + "/" + $installer) -OutFile C:\$installer

  # Unblock installer
  Unblock-File C:\$installer -Confirm:$false

  # Install AppVolumes Agent
  Try 
  {
    Start-Process msiexec.exe -ArgumentList $listConfig -PassThru -Wait
  }
  Catch
  {
    Write-Error "Failed to install the AppVolumes Agent"
    Write-Error $_.Exception
    Exit -1 
  }

  # Cleanup on aisle 4...
  Remove-Item C:\$installer -Confirm:$false
}