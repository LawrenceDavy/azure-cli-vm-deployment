#!/bin/bash
set -euo pipefail

RESOURCE_GROUP="MyResourceGroup"

read -p "This will delete ALL resources in $RESOURCE_GROUP. Are you sure? (yes/no): " CONFIRM

if [[ "$CONFIRM" == "yes" ]]; then
    echo "Deleting resource group: $RESOURCE_GROUP"
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait
    echo "Resource group deletion initiated. This may take a few minutes."
else
    echo "Cleanup cancelled."
fi
