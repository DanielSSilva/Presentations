param( 
    [parameter(Mandatory=$true)]
    $storageAccountName,
    [parameter(Mandatory=$true)]
    $customerName,
    [parameter(Mandatory=$true)]
    $environment
)

BeforeAll {
    #variables
    $rgName = "rg-$customerName-$environment"
    $kvName = "kv-$customerName-$environment"

    #Set up network rules, if needed
    $isDefaultActionDeny = (Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $rgName -Name $storageAccountName).DefaultAction -eq 'Deny'
    # If default action is set to deny, we need to add current user's IP to so that it can successfully test the access
    if($isDefaultActionDeny){
        Write-Information "Default action is Deny, so I'm adding current IP so that it can test access."
        $currentIP = (Invoke-RestMethod -Method Get -Uri "https://api.ipify.org")
        Add-AzStorageAccountNetworkRule -ResourceGroupName $rgName -Name $storageAccountName -IPAddressOrRange $currentIP
        Write-Host "Waiting 30 seconds for change to propagate..."
        Start-Sleep -Seconds 30
    }

    #We don't want to mess with existing containers, so let's create a temp one
    $storageAccountContext = New-AzStorageContext -StorageAccountName $storageAccountName
    $containerName = "temp-test-$(New-Guid)"
    New-AzStorageContainer -Name $containerName -Context $storageAccountContext
    
    $sourcePath = "./helloWorld.txt"
    $destinationPath = "./helloWorldDownload.txt"
    $fileContent = "Hello World"
    Set-Content -Path $sourcePath -Value $fileContent
    
    $uploadBlobParameters = @{
        Container   = $containerName
        File        = $sourcePath
        Blob        = "helloWorld.txt"
        Force       = $true
    }

    $downloadBlobParameters = @{
        Container   = $containerName
        Destination = $destinationPath
        Blob        = "helloWorld.txt"
        Force       = $true
    }
}

Context 'Using SAS Token' {
    BeforeAll {
        $sasTokenSecretName = "sas-token-sa-$storageAccountName"
        $sasTokenSecretValue = Get-AzKeyVaultSecret -VaultName $kvName -Name $sasTokenSecretName -AsPlainText
        $sasContext = New-AzStorageContext -StorageAccountName $storageAccountName -SasToken $sasTokenSecretValue
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
        $spContext = New-AzStorageContext -StorageAccountName $storageAccountName
        
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
}


AfterAll {
    Remove-Item $sourcePath
    Remove-Item $destinationPath
    Remove-AzStorageContainer -Name $containerName -Context $storageAccountContext -Force
    if($isDefaultActionDeny){
        Remove-AzStorageAccountNetworkRule -ResourceGroupName $rgName -Name $storageAccountName -IPAddressOrRange $currentIP 
    }
    
    ## If we can ensure that this is the last test to run, we can save these 15 seconds here since we don't need to wait for propagation
    # Write-Host "Waiting 15 seconds for IP rule removal to propagate..."
    # Start-Sleep -Seconds 15
}
