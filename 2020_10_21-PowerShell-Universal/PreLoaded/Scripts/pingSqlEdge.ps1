$obj = Get-Content '/usr/secrets/secrets.json' | ConvertFrom-Json
$secpasswd = ConvertTo-SecureString $obj.SQLEdge.password -AsPlainText -Force 
$credentials = New-Object System.Management.Automation.PSCredential ($obj.SQLEdge.username, $secpasswd) 

Invoke-DbaQuery  -SqlInstance $obj.SQLEdge.server -SqlCredential $credentials  -database "UG_DEMO" -Query "SELECT @@version"