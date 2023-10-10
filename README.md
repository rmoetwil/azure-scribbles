# Azure scribbles

A project containing just some Azure related snippets of code I created for my exam preps.

Terraform is not part of the Azure certifications but I like to be able to provision resources with:

- Azure Portal
- Azure CLI
- Azure ARM
- Terraform

## Terraform examples

The Terraform exmaples are split into different catagories.
They all depend on one or more resources from the `generics` folder, so you need to run that first

```
az login
terraform init

terraform plan
terraform apply 

terraform destroy
```

### Containers

Before running this one make sure the resources in the generics folder have been created and you pushed the image used in the containers terraform file to the azure container registry


```
docker pull neo4j:5.12.0
docker tag neo4j:5.12.0 examprep.azurecr.io/neo4j:5.12.0

az login
az acr login --name examprep.azurecr.io
docker push examprep.azurecr.io/neo4j:5.12.0

```