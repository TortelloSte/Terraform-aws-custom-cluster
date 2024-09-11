# Azure Provider
provider "azurerm" {
  features {}
}

# Create the Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resources"
  location = "West Europe" # Use 'Central Europe' if preferred
}

# Create the Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

# Create the Private Subnets
resource "azurerm_subnet" "private_subnet" {
  count                = 3
  name                 = "private-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.${count.index + 1}.0/24"]
}

# Create the Public Subnets
resource "azurerm_subnet" "public_subnet" {
  count                = 3
  name                 = "public-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.${count.index + 4}.0/24"]
}

# Create the AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "akscluster"

  default_node_pool {
    name       = "nodepool"
    node_count = 2
    vm_size    = "Standard_DS2_v2" # You can change the instance type
    vnet_subnet_id = azurerm_subnet.private_subnet[0].id
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "Standard"
    outbound_type     = "loadBalancer"
  }
}

# Install Azure File CSI Driver via Helm
resource "helm_release" "azure_file_csi_driver" {
  name       = "azure-file-csi-driver"
  repository = "https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/charts"
  chart      = "azurefile-csi-driver"
  namespace  = "kube-system"
  create_namespace = true
}

# Install Metrics Server via Helm
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  create_namespace = true
}
