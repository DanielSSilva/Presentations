throw "This script is not meant to be run directly"
#Module instalation
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
#You can optionally just install Az.Storage
Install-Module -Name Az.Storage -Scope CurrentUser -Repository PSGallery -Force

Import-Module Az.Storage
Get-Command -Module Az.Storage


# Throughout this session, we will use a Service Principal as our identity to interact with Azure.
# An example on how to connect as a Service Principal

$appId = Get-AzADServicePrincipal -DisplayName "app-provisioner" | Select-Object -ExpandProperty AppId
$password = (Get-AzKeyVaultSecret -VaultName "kv-powershellsummit-7hq1" -Name app-secret-provisioner).SecretValue
$cred = New-Object System.Management.Automation.PSCredential ($appId, $password)
Connect-AzAccount -ServicePrincipal -Credential $cred -TenantId $env:ARM_TENANT_ID | Out-Null
