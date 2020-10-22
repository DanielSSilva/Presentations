$secrets = Get-Content '/usr/secrets/secrets.json' | ConvertFrom-Json
$secpasswd = ConvertTo-SecureString $secrets.Local.password -AsPlainText -Force 
$credentials = New-Object System.Management.Automation.PSCredential ($secrets.Local.username, $secpasswd)

$paramSplat = @{
	Path = '/sharedFolder/myLogFile.log'
	Delimiter = '|'
	SqlInstance = $secrets.Local.server
	SqlCredential = $credentials
	Database = 'UG_DEMO'
    Table = 'logExample'
    AutoCreateTable = $true
}

Import-DbaCsv @paramSplat