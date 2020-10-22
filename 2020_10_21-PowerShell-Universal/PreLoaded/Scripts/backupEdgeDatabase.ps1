# BackupDatabase
$obj = Get-Content '/usr/secrets/secrets.json' | ConvertFrom-Json
$secpasswd = ConvertTo-SecureString $obj.SQLEdge.password -AsPlainText -Force 
$credentials = New-Object System.Management.Automation.PSCredential ($obj.SQLEdge.username, $secpasswd)
$backupName = "$(Get-Date -Format yyyy_MM_dd_HH_mm)"
#the backup directory is the directory where the SQL server instance is running (rpi in this case)
Backup-DbaDatabase -IgnoreFileChecks -SqlInstance "192.168.1.123" -SqlCredential $credentials  -database "UG_DEMO" -BackupDirectory "/tmp" -BackupFile "$backupName.bak"
Invoke-DbaQuery  -SqlInstance "192.168.1.123" -SqlCredential $credentials  -database "UG_DEMO" -Query "SELECT @@version"