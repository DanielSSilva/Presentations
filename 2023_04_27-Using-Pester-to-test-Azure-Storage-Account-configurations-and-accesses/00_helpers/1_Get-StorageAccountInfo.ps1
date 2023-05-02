throw "This script is not meant to be run directly"
function Add-IP ($currentIP) {
    Add-AzStorageAccountNetworkRule -ResourceGroupName $rg -Name $storageAccountName -IPAddressOrRange $currentIP   
}
function Remove-Ip ($currentIP) {
    Remove-AzStorageAccountNetworkRule -ResourceGroupName $rg -Name $storageAccountName -IPAddressOrRange $currentIP
}

$currentIP = (Invoke-RestMethod -Method Get -Uri "https://api.ipify.org")
$rg = "rg-pssummit"
$storageAccountName = "stpssummitdemo7hq1"
$storageAccountToTest = Get-AzStorageAccount -ResourceGroupName $rg -Name $storageAccountName

$storageAccountToTest | Select-Object AllowBlobPublicAccess, AllowSharedKeyAccess, EnableHttpsTrafficOnly, ProvisioningState, NetworkRuleSet, StatusOfPrimary

$storageAccountToTest.NetworkRuleSet

$spContext = New-AzStorageContext -StorageAccountName $storageAccountName
Get-AzStorageContainer -Context $spContext

### 
Add-IP $currentIP
Get-AzStorageContainer -Context $spContext

###
Remove-IP $currentIP
Get-AzStorageContainer -Context $spContext