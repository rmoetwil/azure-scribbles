#!/bin/bash

az group create --name exam-prep-rg --location westeurope

az group list --output table

az network nsg create --name exam-prep-nsg --resource-group exam-prep-rg --location westeurope

az network nsg rule create --name exam-prep-nsg-ssh --nsg-name exam-prep-nsg --priority 100 --resource-group exam-prep-rg --access Allow --destination-port-ranges 22 --direction Inbound --protocol Tcp

az network vnet create --name exam-prep-vnet --resource-group exam-prep-rg --location westeurope --address-prefixes "10.0.0.0/24"

az network vnet subnet create --name exam-prep-sbn --vnet-name exam-prep-vnet --resource-group exam-prep-rg --address-prefixes "10.0.0.0/24" --network-security-group exam-prep-nsg


# TODO 
# nic
# vm
# public ip
# scheduler
