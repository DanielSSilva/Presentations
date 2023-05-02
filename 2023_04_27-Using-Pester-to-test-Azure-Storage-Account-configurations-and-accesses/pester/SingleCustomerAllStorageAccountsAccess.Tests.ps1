param( 
    [parameter(Mandatory=$true)]
    $customerName,
    [parameter(Mandatory=$true)]
    $environment
)

#BeforeDescovery is executed so that we can get the list of storage accounts to test and iterate over it using the "-ForEach $storageAccountNames" in the Describe block
BeforeDiscovery {
    $rgName = "rg-$customerName-$environment"
    $storageAccountNames = Get-AzStorageAccount -ResourceGroupName $rgName 
                            | Select-Object -ExpandProperty StorageAccountName 
}

BeforeAll {
    #variables
    $rgName = "rg-$customerName-$environment"
    $storageAccountsInfo = Get-AzStorageAccount -ResourceGroupName $rgName 
                            | Select-Object -Property StorageAccountName, @{ Name = "DefaultAction"; Expression = { $_.NetworkRuleSet.DefaultAction } }

    $privateStorageAccounts = $storageAccountsInfo | Where-Object { $_.DefaultAction -eq "Deny"}

    #because HTTP calls are expensive, validate if it's necessary
    if($privateStorageAccounts.Count -gt 0 ){
        $currentIP = (Invoke-RestMethod -Method Get -Uri "https://api.ipify.org")
    }

    # add the network rule for private storage accounts
    $privateStorageAccounts | Select-Object -ExpandProperty StorageAccountName | ForEach-Object {
        # If default action is set to deny, we need to add current user's IP to so that it can successfully test the access
        Write-Host "$_ Default action is Deny, so I'm adding current IP so that it can test access."
        Add-AzStorageAccountNetworkRule -ResourceGroupName $rgName -Name $_ -IPAddressOrRange $currentIP
    }
    
    $sourcePath = "./helloWorld.txt"
    $destinationPath = "./helloWorldDownload.txt"
    $fileContent = "Hello World"
    Set-Content -Path $sourcePath -Value $fileContent
    
    $uploadBlobParameters = @{
        File        = $sourcePath
        Blob        = "helloWorld.txt"
        Force       = $true
    }

    $downloadBlobParameters = @{
        Destination = $destinationPath
        Blob        = "helloWorld.txt"
        Force       = $true
    }
    if( ($storageAccountsInfo | Where-Object {$_.DefaultAction -eq "Deny" }).Count -gt 0 ){
        Write-Host "Waiting 30 seconds for change to propagate..."
        Start-Sleep -Seconds 30
    }
}

Describe "Testing storage account <_>" -ForEach $storageAccountNames {
    BeforeAll{
        $kvName = "kv-$customerName-$environment"
        #We don't want to mess with existing containers, so let's create a temp one
        $storageAccountContext = New-AzStorageContext -StorageAccountName $_
        $containerName = "temp-test-$(New-Guid)"
        New-AzStorageContainer -Name $containerName -Context $storageAccountContext
        $uploadBlobParameters.Container = $containerName
        $downloadBlobParameters.Container = $containerName
    }

    Context 'Using SAS Token' {
        BeforeAll {
            $sasTokenSecretName = "sas-token-sa-$_"
            $sasTokenSecretValue = Get-AzKeyVaultSecret -VaultName $kvName -Name $sasTokenSecretName -AsPlainText
            $sasContext = New-AzStorageContext -StorageAccountName $_ -SasToken $sasTokenSecretValue
        }

        It 'Should be able to upload a file' {
            $fileUploadResult = Set-AzStorageBlobContent @uploadBlobParameters -Context $sasContext
            #If it's null, means something went wrong while uploading
            $fileUploadResult | Should -Not -Be $null
        }

        It 'Should be able to download the previously uploaded file' {
            Get-AzStorageBlobContent @downloadBlobParameters -Context $sasContext
            Get-Content -Path $destinationPath | Should -Be $fileContent
        }

        AfterAll {
            Remove-Item $destinationPath -ErrorAction SilentlyContinue
        }
    }

    Context 'Service Principal' {
        BeforeAll {
            $spName = "app-$customerName-$environment"
            $spSecretName = "$spName-secret"
            #authentication
            $appId = Get-AzADServicePrincipal -DisplayName $spName | Select-Object -ExpandProperty AppId
            $password = (Get-AzKeyVaultSecret -VaultName $kvName -Name $spSecretName).SecretValue
            $cred = New-Object System.Management.Automation.PSCredential ($appId, $password)
            Connect-AzAccount -ServicePrincipal -Credential $cred 
            $spContext = New-AzStorageContext -StorageAccountName $_
            
        }

        It 'Should be able to upload a file' {
            $fileUploadResult = Set-AzStorageBlobContent @uploadBlobParameters -Context $spContext
            #If it's null, means something went wrong while uploading
            $fileUploadResult | Should -Not -Be $null
        }

        It 'Should be able to download the previously uploaded file' {
            Get-AzStorageBlobContent @downloadBlobParameters -Context $spContext
            Get-Content -Path $destinationPath | Should -Be $fileContent
        }
        AfterAll {
            Remove-Item $destinationPath -ErrorAction SilentlyContinue
        }
    }

    AfterAll {
        Remove-AzStorageContainer -Name $containerName -Context $storageAccountContext -Force
    }
}

AfterAll {
    Remove-Item $sourcePath -ErrorAction SilentlyContinue
    $privateStorageAccounts | Select-Object -ExpandProperty StorageAccountName | ForEach-Object {
        Remove-AzStorageAccountNetworkRule -ResourceGroupName $rgName -Name $_ -IPAddressOrRange $currentIP 
    }
}
