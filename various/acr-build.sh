#!/bin/bash

# ACR build and push remotely.

#
# Equivalent to:
# docker login examprep.azurecr.io 
# docker build -t examprep.azurecr.io/neo4j:4.0.0 .
# docker push examprep.azurecr.io/neo4j:4.0.0
#

az acr build -t  neo4j:4.0.0 -r examprep .
