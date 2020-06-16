# crate a storage account and container to host our remote state file
# create a resource group
az group create --location eastus --name rg-terraformstate
# create a azure storage account 
az storage account create --name terrasta --resource-group rg-terraformstate --location eastus
# creste a container
az storage container create --name terraformstate --account-name terrasta