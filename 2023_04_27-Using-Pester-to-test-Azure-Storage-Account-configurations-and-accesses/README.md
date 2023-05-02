# Script used in the session "Using Pester to test Azure Storage Account configurations and accesses"

The code is provided as-is and with the setup that was used for demos, except for some IDs.

# Content notes

## 0_internal_setup

Contains the terraform code that was used to create the Service Principal, storage account and other relevants to run terraform and pester tests.

## 1_infrastructure

The terraform code for creating the storage accounts add the remaining necessary components


## scripts

* data_generator.ps1 - This is the script you need to run in order to generate the required data each customer 
* add-RunnerIP.ps1 and remove-RunnerIP.ps1 - used in the CI/CD 