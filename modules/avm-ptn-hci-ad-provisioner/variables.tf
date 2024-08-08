variable "adou_path" {
  type        = string
  description = "The Active Directory OU path."
}

variable "dc_ip" {
  type        = string
  description = "The ip of the server."
}

variable "deployment_user" {
  type        = string
  description = "The username for deployment user."

  validation {
    condition     = length(var.deployment_user) < 21 && length(var.deployment_user) > 0 && can(regex("^[a-zA-Z_][a-zA-Z0-9_-]*$", var.deployment_user))
    error_message = "Username must be between 1 to 20 characters and only contain letters, numbers, hyphens, and underscores and may not start with a hyphen or number."
    # 20 character limit for sAMAccountName in ad preparation New-ADUser.
  }
}

variable "deployment_user_password" {
  type        = string
  description = "The password for deployment user."
}

variable "domain_admin_password" {
  type        = string
  description = "The password for the domain administrator account."
}

variable "domain_admin_user" {
  type        = string
  description = "The username for the domain administrator account."
}

variable "domain_fqdn" {
  type        = string
  description = "The domain FQDN."
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "authentication_method" {
  type        = string
  default     = "Default"
  description = "The authentication method for Enter-PSSession."

  validation {
    condition     = can(regex("^(Default|Basic|Negotiate|NegotiateWithImplicitCredential|Credssp|Digest|Kerberos)$", var.authentication_method))
    error_message = "Value of authentication_method should be {Default | Basic | Negotiate | NegotiateWithImplicitCredential | Credssp | Digest | Kerberos}"
  }
}

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "customer_managed_key" {
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.
DESCRIPTION  
}

variable "dc_port" {
  type        = number
  default     = 5985
  description = "Domain controller winrm port in virtual host"
}

variable "destory_adou" {
  type        = bool
  default     = false
  description = "whether destroy previous adou"
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
