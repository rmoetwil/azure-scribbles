#!/bin/bash

az group create --name exam-prep-gen-rg \
                --location westeurope
                
az group deployment validate --parameters @azure-generics-params.json --resource-group exam-prep-gen-rg --template-file azure-generics.json

az group deployment create --parameters @azure-generics-params.json --resource-group exam-prep-gen-rg --template-file azure-generics.json --mode complete
