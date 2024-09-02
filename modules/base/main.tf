provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "rg" {
  depends_on = [
    data.external.lnet_ip_check
  ]
  name     = local.resource_group_name
  location = var.location
  tags = {
    siteId = var.site_id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

data "azurerm_client_config" "current" {}

module "edge_site" {
  source  = "Azure/avm-res-edge-site/azurerm"
  version = "~>0.0"

  location              = azurerm_resource_group.rg.location
  address_resource_name = local.address_resource_name
  country               = var.country
  resource_group_id     = azurerm_resource_group.rg.id
  site_display_name     = local.site_display_name
  site_resource_name    = local.site_resource_name
  enable_telemetry      = var.enable_telemetry
}

# Prepare AD
module "hci_ad_provisioner" {
  source  = "Azure/avm-ptn-hci-ad-provisioner/azurerm"
  version = "~>0.0"

  count               = var.enable_provisioners ? 1 : 0
  resource_group_name = azurerm_resource_group.rg.name

  enable_telemetry = var.enable_telemetry # see variables.tf
  # Beginning of specific varible for virtual environment
  dc_port                  = var.dc_port
  dc_ip                    = var.dc_ip
  authentication_method    = var.authentication_method
  domain_fqdn              = var.domain_fqdn
  deployment_user_password = var.deployment_user_password
  domain_admin_user        = var.domain_admin_user
  domain_admin_password    = var.domain_admin_password
  deployment_user          = local.deployment_user_name
  adou_path                = local.adou_path
}

# Prepare arc server
module "hci_server_provisioner" {
  source  = "Azure/avm-ptn-hci-server-provisioner/azurerm"
  version = "~>0.0"

  for_each = var.enable_provisioners ? {
    for index, server in var.servers :
    server.name => server.ipv4Address
  } : {}

  enable_telemetry         = var.enable_telemetry # see variables.tf
  name                     = each.key
  resource_group_name      = azurerm_resource_group.rg.name
  local_admin_user         = var.local_admin_user
  local_admin_password     = var.local_admin_password
  authentication_method    = var.authentication_method
  server_ip                = var.virtual_host_ip == "" ? each.value : var.virtual_host_ip
  winrm_port               = var.virtual_host_ip == "" ? 5985 : var.server_ports[each.key]
  subscription_id          = var.subscription_id
  location                 = azurerm_resource_group.rg.location
  tenant                   = data.azurerm_client_config.current.tenant_id
  service_principal_id     = var.service_principal_id
  service_principal_secret = var.service_principal_secret
  expand_c                 = var.virtual_host_ip == "" ? false : true
}

module "azurestackhci_cluster" {
  source  = "Azure/avm-res-azurestackhci-cluster/azurerm"
  version = "~>0.0"

  depends_on = [module.hci_server_provisioner, module.hci_ad_provisioner]

  location            = azurerm_resource_group.rg.location
  name                = local.cluster_name
  resource_group_name = azurerm_resource_group.rg.name

  enable_telemetry = var.enable_telemetry # see variables.tf

  site_id                         = var.site_id
  domain_fqdn                     = var.domain_fqdn
  starting_address                = var.starting_address
  ending_address                  = var.ending_address
  subnet_mask                     = var.subnet_mask
  default_gateway                 = var.default_gateway
  dns_servers                     = var.dns_servers
  adou_path                       = local.adou_path
  servers                         = var.servers
  management_adapters             = var.management_adapters
  storage_networks                = var.storage_networks
  rdma_enabled                    = var.rdma_enabled
  storage_connectivity_switchless = var.storage_connectivity_switchless
  custom_location_name            = local.custom_location_name
  witness_storage_account_name    = local.witness_storage_account_name
  keyvault_name                   = local.keyvault_name
  random_suffix                   = local.random_suffix
  deployment_user                 = local.deployment_user_name
  deployment_user_password        = var.deployment_user_password
  local_admin_user                = var.local_admin_user
  local_admin_password            = var.local_admin_password
  service_principal_id            = var.service_principal_id
  service_principal_secret        = var.service_principal_secret
  rp_service_principal_object_id  = var.rp_service_principal_object_id
}

module "azurestackhci_logicalnetwork" {
  source  = "Azure/avm-res-azurestackhci-logicalnetwork/azurerm"
  version = "~>0.0"

  depends_on = [module.azurestackhci_cluster]

  location            = azurerm_resource_group.rg.location
  name                = local.logical_network_name
  resource_group_name = azurerm_resource_group.rg.name

  enable_telemetry   = var.enable_telemetry # see variables.tf
  resource_group_id  = azurerm_resource_group.rg.id
  custom_location_id = module.azurestackhci_cluster.customlocation.id
  vm_switch_name     = module.azurestackhci_cluster.v_switch_name
  starting_address   = var.lnet_starting_address
  ending_address     = var.lnet_ending_address
  dns_servers        = length(var.lnet_dns_servers) == 0 ? var.dns_servers : var.lnet_dns_servers
  default_gateway    = var.lnet_default_gateway == "" ? var.default_gateway : var.lnet_default_gateway
  address_prefix     = var.lnet_address_prefix
  vlan_id            = var.lnet_vlan_id
}

module "hybridcontainerservice_provisionedclusterinstance" {
  source  = "Azure/avm-res-hybridcontainerservice-provisionedclusterinstance/azurerm"
  version = "~>0.0"

  depends_on = [module.azurestackhci_cluster, module.azurestackhci_logicalnetwork]

  location            = azurerm_resource_group.rg.location
  name                = local.aks_arc_name
  resource_group_name = azurerm_resource_group.rg.name

  enable_telemetry = var.enable_telemetry # see variables.tf

  custom_location_id          = module.azurestackhci_cluster.customlocation.id
  logical_network_id          = module.azurestackhci_logicalnetwork.resource_id
  agent_pool_profiles         = var.agent_pool_profiles
  ssh_key_vault_id            = module.azurestackhci_cluster.keyvault.id
  control_plane_ip            = var.aks_arc_control_plane_ip
  kubernetes_version          = var.kubernetes_version
  control_plane_count         = var.control_plane_count
  rbac_admin_group_object_ids = var.rbac_admin_group_object_ids
}

locals {
  server_names = [for server in var.servers : server.name]
}

module "azuremonitorwindowsagent" {
  source  = "Azure/avm-ptn-azuremonitorwindowsagent/azurerm"
  version = "~>0.0"

  depends_on       = [module.azurestackhci_cluster]
  enable_telemetry = var.enable_telemetry

  count                            = var.enable_insights ? 1 : 0
  resource_group_name              = azurerm_resource_group.rg.name
  server_names                     = local.server_names
  arc_setting_id                   = module.azurestackhci_cluster.arc_settings.id
  data_collection_rule_resource_id = var.data_collection_rule_resource_id
}

resource "azapi_resource" "alerts" {
  depends_on = [module.azurestackhci_cluster]
  count      = var.enable_alerts && var.enable_insights ? 1 : 0
  type       = "Microsoft.AzureStackHCI/clusters/ArcSettings/Extensions@2023-08-01"
  parent_id  = module.azurestackhci_cluster.arc_settings.id
  name       = "AzureEdgeAlerts"
  body = {
    properties = {
      extensionParameters = {
        enableAutomaticUpgrade  = true
        autoUpgradeMinorVersion = false
        publisher               = "Microsoft.AzureStack.HCI.Alerts"
        type                    = "AlertsForWindowsHCI"
        settings                = {}
      }
    }
  }
}
