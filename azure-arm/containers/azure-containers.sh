#!/bin/bash

az group create --name exam-prep-rg \
                --location westeurope
                
az deployment group validate --parameters @azure-containers-params.json --resource-group exam-prep-rg --template-file azure-containers.json

az deployment group create --parameters @azure-containers-params.json --resource-group exam-prep-rg --template-file azure-containers.json --mode complete
