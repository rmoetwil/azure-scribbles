#!/bin/bash

az group create --name exam-prep-gen-rg \
                --location westeurope
                
az deployment group validate --parameters @azure-generics-params.json --resource-group exam-prep-gen-rg --template-file azure-generics.json

az deployment group create --parameters @azure-generics-params.json --resource-group exam-prep-gen-rg --template-file azure-generics.json --mode complete
