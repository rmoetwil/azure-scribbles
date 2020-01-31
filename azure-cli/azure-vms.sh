#!/bin/bash

az group create --name exam-prep-rg \
                --location westeurope

az network nsg create --name exam-prep-nsg \
                      --resource-group exam-prep-rg \
                      --location westeurope

az network nsg rule create --name exam-prep-nsg-ssh \
                           --nsg-name exam-prep-nsg \
                           --priority 100 \
                           --resource-group exam-prep-rg \
                           --access Allow \
                           --destination-port-ranges 22 \
                           --direction Inbound \
                           --protocol Tcp

az network vnet create --name exam-prep-vnet \
                       --resource-group exam-prep-rg \
                       --location westeurope \
                       --address-prefixes "10.0.0.0/24"

az network vnet subnet create --name exam-prep-sbn \
                              --vnet-name exam-prep-vnet \
                              --resource-group exam-prep-rg \
                              --address-prefixes "10.0.0.0/24" \
                              --network-security-group exam-prep-nsg

az network public-ip create --name exam-prep-pub-ip \
                            --resource-group exam-prep-rg

az network nic create --name exam-prep-nic \
                      --resource-group exam-prep-rg \
                      --subnet exam-prep-sbn \
                      --vnet-name exam-prep-vnet \
                      --public-ip-address exam-prep-pub-ip

az vm create --name exam-prep-vm \
             --resource-group exam-prep-rg \
             --nics exam-prep-nic \
             --size Standard_B2ms \
             --image UbuntuLTS \
             --admin-username ronald \
             --ssh-key-values "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDn+JUp3bgPSP0/67Eu5iYouCRbD9D8DHXNCFdzf2ExcILLrCrgzsXE7M2OSdPaF5z6uu/hPL9DfNkE3oxHfKLVh+AFuHJA8ugqav3PiIXThwgYyNiGtAFvpeTp1IRGC+7rag69ID2XinBAHDMSBLJYZUnokwGuwIRvnuC/XVUy/IASxC8Z6KVBMEPkskdyMVzD/T0sELGrXq9wnqQTL26rH2nh/fk0dbOmQRsZRxo/GRMWu5EX5gD2TgBs9Ix3kUu7xlA22sjkYbZVOgvuZ/t8SPB9KcWKqYkuZJifkJFJakfrB73T0tzFLWqB7ZvMOrvXB2HWJG9vTAU62ruoAGBFTIXi67yIV2XxQKXeQtVcB6Y3fvj+VMqNhL1mfSBYfbPnJjElXxoWOMlqYH9gWT51JieaovegDfxnBKoFeClpJOUc00v2R6gVqr6+gXBOHb9at4rg0bq0UsGxfIFcocpxoIGtCCWSij2eE53TusPPW+HFtmCoxdt2tJqgrF1rEm/sBwiHp3CZnb55CmbYEKXM+SrvpDNzJys9YmwTn9FE27VLkefWhH0Hq6brVc94/igFU80LQBrzNfCUvlXMQX61nAEyxcYRvjWp36W+oMX6SM0e9VKhJ6k1Jp8U8RuJBNhJWi7xcoV9BFdkMwAu/HFppXDsK5Suc50ibSljyRzDwQ== ronald.moetwil@gmail.com"



az resource list --output table --resource-group exam-prep-rg   

az vm list-ip-addresses --output table

# TODO 
# scheduler

