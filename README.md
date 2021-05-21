# Deploy an AKS cluster with Application Ingress Controller with Terraform

## Code steps

- Creates a resource group
- Creates a VNet
- Creates a subnet to host the AKS nodes for the Azure CNI network
- Creates a subnet for the Application Gateway Ingress controller
- Deploys the AKS in private mode with the Application Gateway Ingress controller using the addon functionalty
> **Note:** The ingress addon is supported in Terraform version >=2.57

## Ingress controller addon

- The addon is part of the AKS cluster resource, and tells Azure to deploy an Application Gateway Ingress controller as part of the deployment

```terraform
addon_profile {
    ingress_application_gateway {
        enabled = true
        subnet_id = azurerm_subnet.agwSubnet.id
    }
}
```

## AKS Terraform code

> **Note:** Please note how the addon is being used in the code below

```terraform
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
```

