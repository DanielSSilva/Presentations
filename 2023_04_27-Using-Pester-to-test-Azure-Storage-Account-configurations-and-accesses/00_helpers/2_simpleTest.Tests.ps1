#
#Invoke-Pester -Path .\2_simpleTest.Tests.ps1 -Output Detailed
#Invoke-Pester -Output Detailed

Describe "Test Storage account" {
    Context 'Using SAS Token' {
        BeforeAll {
            $sasTokenSecretName = "sas-token-sa-stcustomer1allowdev"
            $kvName = "kv-customer1-dev"
            $storageAccountName = "stcustomer1allowdev"
            $sasTokenSecretValue = Get-AzKeyVaultSecret -VaultName $kvName -Name $sasTokenSecretName -AsPlainText
            $sasContext = New-AzStorageContext -StorageAccountName $storageAccountName -SasToken $sasTokenSecretValue
            $fileContent = "Hello World"
            Set-Content -Path "./helloWorld.txt" -Value $fileContent
        }

        It 'Should be able to upload a file' {
            $fileUploadResult = Set-AzStorageBlobContent -File "./helloWorld.txt" -Blob "helloWorld.txt" -Force -Container "mycontainer" -Context $sasContext
            #If it's null, means something went wrong while uploading
            $fileUploadResult | Should -Not -Be $null
        }

        It 'Should be able to download the previously uploaded file' {
            Get-AzStorageBlobContent -Destination "./helloWorldDownload.txt" -Blob "helloWorld.txt" -Force -Container "mycontainer" -Context $sasContext
            Get-Content -Path "./helloWorldDownload.txt" | Should -Be $fileContent
        }
    }
}

AfterAll {
    Remove-Item -Path "./helloWorld.txt"
    Remove-Item -Path "./helloWorldDownload.txt"
}

