variable "resource_group_name" {
  description = "Name of the resource group."
  default     = "rg-aksdemo-eus-demo"
}

variable "location" {
  description = "Location of the cluster."
  default     = "eastus"
}

variable "virtual_network_name" {
  description = "Virtual network name"
  default     = "vnet-askdemo-eus-demo"
}

variable "aks_name" {
  description = "AKS cluster name"
  default     = "aksdemo"
}

variable "aks_agent_count" {
  description = "The number of agent nodes for the cluster."
  default     = 2
}

variable "aks_agent_vm_size" {
  description = "VM size"
  default     = "Standard_D2_v2"
}

variable "aks_service_cidr" {
  description = "CIDR notation IP range from which to assign service cluster IPs"
  default     = "10.0.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "DNS server IP address"
  default     = "10.0.0.10"
}

variable "aks_docker_bridge_cidr" {
  description = "CIDR notation IP for Docker bridge."
  default     = "172.17.0.1/16"
}

variable "aks_enable_rbac" {
  description = "Enable RBAC on the AKS cluster. Defaults to false."
  type        = bool
  default     = true
}

variable "vm_user_name" {
  description = "User name for the VM"
  default     = "azureazure"
}

variable "public_ssh_key_path" {
  description = "Public key path for SSH."
  default     = "~/.ssh/id_rsa.pub"
}

variable "tags" {
  type = map(string)

  default = {
    source = "terraform"
  }
}
