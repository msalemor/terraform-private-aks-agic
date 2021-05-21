provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

resource "azurerm_resource_group" "k8s" {
  location = var.location
  name     = var.resource_group_name
}

resource "azurerm_virtual_network" "aksvnet" {
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
  name                = var.virtual_network_name
  address_space       = ["10.60.0.0/16"]
}

resource "azurerm_subnet" "defaultSubnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.k8s.name
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  address_prefixes     = ["10.60.0.0/24"]
}

resource "azurerm_subnet" "agwSubnet" {
  name                 = "agwSubnet"
  resource_group_name  = azurerm_resource_group.k8s.name
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  address_prefixes     = ["10.60.19.0/24"]
}

resource "azurerm_subnet" "askSubnet" {
  name                 = "aksSubnet"
  resource_group_name  = azurerm_resource_group.k8s.name
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  address_prefixes     = ["10.60.20.0/22"]
}

resource "azurerm_kubernetes_cluster" "privateaks" {
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location

  name       = var.aks_name
  dns_prefix = var.aks_name
  private_cluster_enabled = true


  default_node_pool {
    name                = "default"
    node_count          = var.aks_agent_count
    vm_size             = var.aks_agent_vm_size
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 4

    vnet_subnet_id = azurerm_subnet.askSubnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    ingress_application_gateway {
        enabled = true
        subnet_id = azurerm_subnet.agwSubnet.id
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico"
    #dns_service_ip = 
    #docker_bridge_cidr = 
    #service_cidr = 
  }

  tags = {
    Environment = "Development"
  }

  depends_on = [
    azurerm_subnet.askSubnet,
    azurerm_subnet.agwSubnet
  ]
}


