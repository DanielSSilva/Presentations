$currentIP = (Invoke-RestMethod -Method Get -Uri "https://api.ipify.org")
$environment = @("dev", "stg", "prd")
$customersPath = "../2_customers/"
$customers = Get-ChildItem $customersPath -Directory | Select-Object -ExpandProperty Name

$customers | ForEach-Object {
    $currentCustomer = $_
    $environment | ForEach-object {
        $storageAccounts=@()
        1..2 | ForEach-object {
            $randomName = (New-Guid).Guid.Replace("-", "").Substring(0,7)
        
            if ($_ % 2 -eq 0) {
                $storageAccounts += @{
                    suffix = "deny" # $randomName
                    network_rules_default_action = "Deny"
                    network_rules_ip_rules = @($currentIP)
                }
            }
            else {
                $storageAccounts += @{
                    suffix = "allow" #$randomName
                    network_rules_default_action = "Allow"
                    network_rules_ip_rules = @()
                }
            }
        }

        $terraformVar = @{
            storage_account_config = $storageAccounts
            container_name = "mycontainer"
            
        }

        ConvertTo-Json $terraformVar -Depth 10 | Set-Content -Path "$customersPath/$currentCustomer/$_.tfvars.json"
    }
}