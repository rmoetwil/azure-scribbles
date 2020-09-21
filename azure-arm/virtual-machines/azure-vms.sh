#!/bin/bash

az group create --name exam-prep-rg \
                --location westeurope
                
az deployment group validate --parameters @azure-vms-params.json --resource-group exam-prep-rg --template-file azure-vms.json

az deployment group create --parameters @azure-vms-params.json --resource-group exam-prep-rg --template-file azure-vms.json --mode complete

az vm list-ip-addresses --output table
