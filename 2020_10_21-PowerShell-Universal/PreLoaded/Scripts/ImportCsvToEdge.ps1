$secrets = Get-Content '/usr/secrets/secrets.json' | ConvertFrom-Json
$secpasswd = ConvertTo-SecureString $secrets.SQLEdge.password -AsPlainText -Force 
$credentials = New-Object System.Management.Automation.PSCredential ($secrets.SQLEdge.username, $secpasswd)

$paramSplat = @{
	Path = '/sharedFolder/myLogFile.log'
	Delimiter = '|'
	SqlInstance = $secrets.SQLEdge.server
	SqlCredential = $credentials
	Database = 'UG_DEMO'
    Table = 'logExample'
    AutoCreateTable = $true
}
Import-DbaCsv @paramSplat