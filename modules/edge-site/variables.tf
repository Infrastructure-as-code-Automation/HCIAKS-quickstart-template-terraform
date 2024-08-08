variable "address_resource_name" {
  type        = string
  description = "A resource name for the address."
}

variable "country" {
  type        = string
  description = "The order country of the site."
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "resource_group_id" {
  type        = string
  description = "The resource group id where the resources will be deployed."
}

variable "site_display_name" {
  type        = string
  description = "A display name for the site."
}

variable "site_resource_name" {
  type        = string
  description = "A resource name for the site."
}

variable "city" {
  type        = string
  default     = ""
  description = "The city of the site."
}

variable "company_name" {
  type        = string
  default     = ""
  description = "The company name of the site."
}

variable "contact_name" {
  type        = string
  default     = " "
  description = "The contact name of the site."
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

variable "email_list" {
  type        = list(string)
  default     = []
  description = "A list of email addresses for the site."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "mobile" {
  type        = string
  default     = ""
  description = "The mobile phone number of the site."
}

variable "phone" {
  type        = string
  default     = ""
  description = "The phone number of the site."
}

variable "phone_extension" {
  type        = string
  default     = ""
  description = "The phone extension of the site."
}

variable "postal_code" {
  type        = string
  default     = ""
  description = "The postal code of the site."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "state_or_province" {
  type        = string
  default     = ""
  description = "The state or province of the site."
}

variable "street_address_1" {
  type        = string
  default     = ""
  description = "The first line of the street address of the site."
}

variable "street_address_2" {
  type        = string
  default     = ""
  description = "The second line of the street address of the site."
}

variable "street_address_3" {
  type        = string
  default     = ""
  description = "The third line of the street address of the site."
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "zip_extended_code" {
  type        = string
  default     = ""
  description = "The extended ZIP code of the site."
}
