param( 
    [parameter(Mandatory=$true)]
    $daysLimit
)

BeforeDiscovery { #setup all storage accounts 
    $storageAccountsInfo = Get-AzStorageAccount | Where-Object {$_.StorageAccountName.StartsWith("stcustomer")}
    Write-Host "found $($storageAccountsInfo.Count) storages"
}

Describe "Generic network rules <_.StorageAccountName>" -ForEach $storageAccountsInfo {
    
    It 'Blob public access should be disabled' {
        $_.AllowBlobPublicAccess | Should -Be $false 
    }

    It 'Only HTTPS traffic should be used - EnableHttpsTrafficOnly=true' {
        $_.EnableHttpsTrafficOnly | Should -Be $true
    }

    if($_.NetworkRuleSet.DefaultAction -eq "Deny"){
        It 'If DefaultAction is Deny, at least one IP is present' {
            $_.NetworkRuleSet.IpRules.Count | Should -BeGreaterThan 0
        }
    }

    

    Context "Keys are not older than $daysLimit days" {
        BeforeAll {
            $today = Get-Date
            #$daysLimit = 30
        }
        
        It "Key1 is not older than $daysLimit days" {
            $today - $_.KeyCreationTime.Key1 | Select-Object -ExpandProperty TotalDays | Should -Not -BeGreaterThan $daysLimit
        }

        It "Key2 is not older than $daysLimit days" {
            $today - $_.KeyCreationTime.Key2 | Select-Object -ExpandProperty TotalDays | Should -Not -BeGreaterThan $daysLimit
        }
        
    }
    
}