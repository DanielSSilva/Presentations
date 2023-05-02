#Installation
Install-Module -Name VSTeam -Scope CurrentUser -Force

$account = "https://dev.azure.com/danielssilvadev"
$env:PAT = "xxxxxxxxx"
Set-VSTeamAccount -Account $account -Token $env:PAT