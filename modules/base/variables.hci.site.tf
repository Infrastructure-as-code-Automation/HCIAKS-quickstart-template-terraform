variable "servers" {
  type = list(object({
    name        = string
    ipv4Address = string
  }))
  description = "A list of servers with their names and IPv4 addresses."
  default = [
    {
      name        = "AzSHOST1",
      ipv4Address = "192.168.1.12"
    },
    {
      name        = "AzSHOST2",
      ipv4Address = "192.168.1.13"
    }
  ]
}

variable "starting_address" {
  description = "The starting IP address of the IP address range."
  type        = string
  default     = "192.168.1.55"
}

variable "ending_address" {
  description = "The ending IP address of the IP address range."
  type        = string
  default = "192.168.1.65"
}
