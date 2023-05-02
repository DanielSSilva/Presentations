param( 
    [parameter(Mandatory=$true)]
    [ValidateSet("dev","stg","prd")]
    [string]$environment ,
    [parameter(Mandatory=$true)]
    [string]$customerName
)
Import-Module Az.Storage

$rgName = "rg-$customerName-$environment"
$currentIP = (Invoke-RestMethod -Method Get -Uri "https://api.ipify.org")
$storageAccounts = Get-AzStorageAccount -ResourceGroupName $rgName -ErrorAction SilentlyContinue | Where-Object { $_.NetworkRuleSet.DefaultAction -eq "Deny" }
$storageAccounts | Select-Object -ExpandProperty StorageAccountName | ForEach-object -Parallel {
    $currentStorageAccountRuleSet = Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $using:rgName -Name $_ -ErrorAction SilentlyContinue
    if($null -ne $currentStorageAccountRuleSet){
        $currentStorageAccountRuleSet | Select-Object -ExpandProperty IpRules | Where-Object {$_.IPAddressOrRange -eq $using:currentIP} | Remove-AzStorageAccountNetworkRule -ResourceGroupName $using:rgName -Name $_ #-IPAddressOrRange $currentIP
    }
}