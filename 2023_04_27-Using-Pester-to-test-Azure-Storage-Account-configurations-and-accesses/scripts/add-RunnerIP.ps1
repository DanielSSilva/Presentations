param( 
    [parameter(Mandatory=$true)]
    [ValidateSet("dev","stg","prd")]
    [string]$environment,
    [parameter(Mandatory=$true)]
    [string]$customerName
)
Import-Module Az.Storage

$rgName = "rg-$customerName-$environment"
$currentIP = (Invoke-RestMethod -Method Get -Uri "https://api.ipify.org")
$storageAccounts = Get-AzStorageAccount -ResourceGroupName $rgName -ErrorAction SilentlyContinue | Where-Object { $_.NetworkRuleSet.DefaultAction -eq "Deny" }
$storageAccounts | Select-Object -ExpandProperty StorageAccountName | ForEach-object -Parallel {
    $currentStorageAccount = Get-AzStorageAccount -ResourceGroupName $using:rgName -Name $_ -ErrorAction SilentlyContinue
    #Because this runs before the terraform, we need to validate if this is an existing storage account or a new one
    #Storage accounts that don't exist throw an error, henc the silently continue
    #we an only add IP rules to existing storage accounts
    if($null -ne $currentStorageAccount){
        Add-AzStorageAccountNetworkRule -ResourceGroupName $using:rgName -Name $_ -IPAddressOrRange $using:currentIP
    }
}