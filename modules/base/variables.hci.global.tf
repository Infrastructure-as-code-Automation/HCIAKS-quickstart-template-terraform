variable "domain_fqdn" {
  description = "The domain FQDN."
  type        = string
  default     = "jumpstart.local"
}

variable "adou_suffix" {
  type        = string
  description = "The suffix of Active Directory OU path."
  default     = "DC=jumpstart,DC=local"
}

variable "subnet_mask" {
  default     = "255.255.255.0"
  type        = string
  description = "The subnet mask for the network."
}

variable "default_gateway" {
  description = "The default gateway for the network."
  type        = string
  default     = "192.168.1.1"
}

variable "dns_servers" {
  type        = list(string)
  description = "A list of DNS server IP addresses."
  default     = ["192.168.1.254"]
}

variable "management_adapters" {
  type    = list(string)
  default = ["FABRIC", "FABRIC2"]
}

variable "storage_networks" {
  type = list(object({
    name               = string
    networkAdapterName = string
    vlanId             = string
  }))
  default = [
    {
      name               = "Storage1Network",
      networkAdapterName = "StorageA",
      vlanId             = "711"
    },
    {
      name               = "Storage2Network",
      networkAdapterName = "StorageB",
      vlanId             = "712"
    }
  ]
}

variable "rdma_enabled" {
  type        = bool
  description = "Indicates whether RDMA is enabled."
}

variable "storage_connectivity_switchless" {
  type        = bool
  description = "Indicates whether storage connectivity is switchless."
}
