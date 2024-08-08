variable "lnet_address_prefix" {
  type        = string
  description = "The CIDR prefix of the subnet that start from startting address and end with ending address, this can be omit if using existing logical network"
  default     = "192.168.1.0/24"
}

variable "lnet_starting_address" {
  type        = string
  description = "The starting IP address of the IP address range of the logical network, this can be omit if using existing logical network"
  default     = "192.168.1.171"
}

variable "lnet_ending_address" {
  type        = string
  description = "The ending IP address of the IP address range of the logical network, this can be omit if using existing logical network"
  default     = "192.168.1.190"
}

variable "lnet-vlanId" {
  type        = number
  description = "The vlan id of the logical network, default is not set vlan id, this can be omit if using existing logical network"
  default     = null
}
