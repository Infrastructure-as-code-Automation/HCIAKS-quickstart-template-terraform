# Pass through variables
variable "domain_admin_user" {
  type        = string
  description = "The username for the domain administrator account."
}

variable "domain_admin_password" {
  # sensitive   = true
  type        = string
  description = "The password for the domain administrator account."
}

# Virtual host related variables
variable "virtual_host_ip" {
  type        = string
  description = "The virtual host IP address."
  default     = ""
}

variable "dc_port" {
  type        = number
  description = "Domain controller winrm port in virtual host"
  default     = 5985
}

variable "server_ports" {
  type        = map(number)
  description = "Server winrm ports in virtual host"
  default     = {}
}


# Reference variables
# variable "location"               "ref/main/location"
# variable "siteId"                 "ref/main/siteId"
# variable "siteName"               "ref/main/siteName"
# variable "subscriptionId"         "ref/main/subscriptionId"
# variable "servers"                "ref/hci/servers"
# variable "deploymentUser"         "ref/hci/deploymentUser"
# variable "deploymentUserPassword" "ref/hci/deploymentUserPassword"
# variable "localAdminUser"         "ref/hci/localAdminUser"
# variable "localAdminPassword"     "ref/hci/localAdminPassword"
# variable "domainFqdn"             "ref/hci/domainFqdn"
# variable "adouPath"               "ref/hci/adouPath"
# variable "tenant"                 "ref/hci/tenant"
# variable "servicePrincipalId"     "ref/hci/servicePrincipalId"
# variable "servicePrincipalSecret" "ref/hci/servicePrincipalSecret"
