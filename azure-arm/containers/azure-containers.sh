#!/bin/bash

az group create --name exam-prep-rg \
                --location westeurope
                
az group deployment validate --parameters @azure-containers-params.json --resource-group exam-prep-rg --template-file azure-containers.json

az group deployment create --parameters @azure-containers-params.json --resource-group exam-prep-rg --template-file azure-containers.json --mode complete
