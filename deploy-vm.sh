#!/bin/bash
set -e

# --- Variables (Change these to deploy anywhere) ---
RESOURCE_GROUP="MyResourceGroup"
LOCATION="eastus"
VM_NAME="MyUbuntuVM"
ADMIN_USER="azureuser"
VNET_NAME="MyVNet"
SUBNET_NAME="MySubnet"
NSG_NAME="MyNSG"
# -------------------------------------------

echo "Starting Azure VM Deployment..."

# 1. Create the Resource Group
echo "Creating Resource Group: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# 2. Create the Virtual Network and Subnet
echo "Creating Virtual Network..."
az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VNET_NAME" \
  --address-prefix "10.0.0.0/16" \
  --location "$LOCATION"

az network vnet subnet create \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_NAME" \
  --address-prefix "10.0.1.0/24"

# 3. Create the Network Security Group
echo "Creating Network Security Group..."
az network nsg create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$NSG_NAME" \
  --location "$LOCATION"

az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "AllowSSH" \
  --protocol "Tcp" \
  --priority 1000 \
  --destination-port-range "22" \
  --access "Allow" \
  --direction "Inbound"

az network vnet subnet update \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_NAME" \
  --network-security-group "$NSG_NAME"

# 4. Create the VM
echo "Creating Virtual Machine (this takes a few minutes)..."
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image "Ubuntu2204" \
  --admin-username "$ADMIN_USER" \
  --ssh-key-values ~/.ssh/id_rsa.pub \
  --vnet-name "$VNET_NAME" \
  --subnet "$SUBNET_NAME" \
  --public-ip-sku "Standard" \
  --location "$LOCATION" \
  --size "Standard_D2s_v3"

# 5. Fetch the Public IP
echo "Deployment complete! Your public IP is:"
az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --show-details \
  --query "publicIps" \
  --output tsv

echo "Script finished."
