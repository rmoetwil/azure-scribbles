#!/bin/bash

if [ -z "$1" ]
  then
    echo "No password supplied"
    exit 1
fi

RESOURCE_GROUP=network-watcher-rg
LOCATION=westeurope
PASSWORD=$1
STORAGE_ACCOUNT=networkwatcher2020sa
LOG_ANALYTICS_WORKSPACE=network-watcher-law

# Create the resource group to contain all resources
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create the vnet
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name MyVNet1 \
    --address-prefix 10.10.0.0/16 \
    --subnet-name FrontendSubnet \
    --subnet-prefix 10.10.1.0/24

az network vnet subnet create \
    --address-prefixes 10.10.2.0/24 \
    --name BackendSubnet \
    --resource-group $RESOURCE_GROUP \
    --vnet-name MyVNet1
  
# Create a Virtual Machine with IIS installed
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name FrontendVM \
    --vnet-name MyVNet1 \
    --subnet FrontendSubnet \
    --image Win2019Datacenter \
    --admin-username azureuser \
    --admin-password $PASSWORD

az vm extension set \
    --publisher Microsoft.Compute \
    --name CustomScriptExtension \
    --vm-name FrontendVM \
    --resource-group $RESOURCE_GROUP \
    --settings '{"commandToExecute":"powershell.exe Install-WindowsFeature -Name Web-Server"}' \
    --no-wait

# Create another Virtual Machine with IIS installed
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name BackendVM \
    --vnet-name MyVNet1 \
    --subnet BackendSubnet \
    --image Win2019Datacenter \
    --admin-username azureuser \
    --admin-password $PASSWORD

  az vm extension set \
    --publisher Microsoft.Compute \
    --name CustomScriptExtension \
    --vm-name BackendVM \
    --resource-group $RESOURCE_GROUP \
    --settings '{"commandToExecute":"powershell.exe Install-WindowsFeature -Name Web-Server"}' \
    --no-wait
  
# Create a Network Security Group and rule to deny inboud traffic on 80, 443 and 3389
az network nsg create \
    --name MyNsg \
    --resource-group $RESOURCE_GROUP

az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --name MyNSGRule \
    --nsg-name MyNsg \
    --priority 4096 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 80 443 3389 \
    --access Deny \
    --protocol TCP \
    --direction Inbound \
    --description "Deny from specific IP address ranges on 80, 443 and 3389."

# Apply Network Security Group and rule to Backend VM  
az network vnet subnet update \
    --resource-group $RESOURCE_GROUP \
    --name BackendSubnet \
    --vnet-name MyVNet1 \
    --network-security-group MyNsg

# Enable Network Watcher for this resource group
az network watcher configure \
--locations $LOCATION \
--enabled true \
--resource-group $RESOURCE_GROUP

# Create storage account to capture logs
az storage account create \
    --resource-group $RESOURCE_GROUP \
    --name $STORAGE_ACCOUNT \
    --location $LOCATION \
    --sku Standard_LRS

# Create Log Analytics Workspace to capture the logs also
az monitor log-analytics workspace create \
    --resource-group $RESOURCE_GROUP \
    --workspace-name $LOG_ANALYTICS_WORKSPACE \
    --location $LOCATION

# Create NSG Flow Log configuration
az network watcher flow-log create \
   --location $LOCATION \
   --name MyNsgFlowLog \
   --nsg MyNsg \
   --enabled true \
   --interval 10 \
   --resource-group $RESOURCE_GROUP \
   --storage-account $STORAGE_ACCOUNT \
   --traffic-analytics true \
   --workspace $LOG_ANALYTICS_WORKSPACE
