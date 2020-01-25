#!/bin/bash

# Note assumption here is that the resource group exists.

az group deployment validate --parameters @azure-vms-params.json --resource-group exam-prep-rg --template-file azure-vms.json

az group deployment create --parameters @azure-vms-params.json --resource-group exam-prep-rg --template-file azure-vms.json --mode complete

az vm list-ip-addresses --output table
