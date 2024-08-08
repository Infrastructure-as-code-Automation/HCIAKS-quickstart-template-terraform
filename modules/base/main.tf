resource "azurerm_resource_group" "rg" {
  depends_on = [
    data.external.lnetIpCheck
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

module "edge-site" {
  source                = "../edge-site"
  location              = azurerm_resource_group.rg.location
  address_resource_name = local.addressResourceName
  country               = var.country
  resource_group_id     = azurerm_resource_group.rg.id
  site_display_name     = local.siteDisplayName
  site_resource_name    = local.site_resource_name
  enable_telemetry      = var.enable_telemetry
}

module "hci-ad-provisioner" {
  source              = "../hci-ad-provisioner"
  resource_group_name = azurerm_resource_group.rg.name

  enable_telemetry = var.enable_telemetry # see variables.tf
  # Beginning of specific varible for virtual environment
  dc_port                  = 6985
  dc_ip                    = var.dc_ip
  authentication_method    = "Credssp"
  domain_fqdn              = "jumpstart.local"
  deployment_user_password = var.deployment_user_password
  domain_admin_user        = var.domain_admin_user
  domain_admin_password    = var.domain_admin_password
  deployment_user          = local.deployment_user_name
  adou_path                = local.adou_path
}

module "hci-server-provisioner" {
  source = "../hci-server-provisioner"
  for_each = {
    for index, server in local.servers :
    server.name => server.ipv4Address
  }

  enable_telemetry         = var.enable_telemetry # see variables.tf
  name                     = each.key
  resource_group_name      = azurerm_resource_group.rg.name
  local_admin_user         = var.local_admin_user
  local_admin_password     = var.local_admin_password
  authentication_method    = "Credssp"
  server_ip                = var.virtual_host_ip == "" ? each.value : var.virtual_host_ip
  winrm_port               = var.virtual_host_ip == "" ? 5985 : local.server_ports[each.key]
  subscription_id          = var.subscription_id
  location                 = azurerm_resource_group.rg.location
  tenant                   = data.azurerm_client_config.current.tenant_id
  service_principal_id     = var.service_principal_id
  service_principal_secret = var.service_principal_secret
  expand_c                 = var.virtual_host_ip == "" ? false : true
}

module "azurestackhci-cluster" {
  source     = "../azurestackhci-cluster"
  depends_on = [module.hci-server-provisioner]

  location            = azurerm_resource_group.rg.location
  name                = local.cluster_name # TODO update with module.naming.<RESOURCE_TYPE>.name_unique
  resource_group_name = azurerm_resource_group.rg.name

  enable_telemetry = var.enable_telemetry # see variables.tf

  site_id                         = var.site_id
  domain_fqdn                     = "jumpstart.local"
  starting_address                = "192.168.1.55"
  ending_address                  = "192.168.1.65"
  subnet_mask                     = var.subnet_mask
  default_gateway                 = "192.168.1.1"
  dns_servers                     = ["192.168.1.254"]
  adou_path                       = local.adou_path
  servers                         = local.servers
  management_adapters             = local.management_adapters
  storage_networks                = local.storage_networks
  rdma_enabled                    = false
  storage_connectivity_switchless = false
  custom_location_name            = local.custom_location_name
  witness_storage_account_name    = local.witness_storage_account_name
  keyvault_name                   = local.keyvault_name
  random_suffix                   = true
  deployment_user                 = local.deployment_user_name
  deployment_user_password        = var.deployment_user_password
  local_admin_user                = var.local_admin_user
  local_admin_password            = var.local_admin_password
  service_principal_id            = var.service_principal_id
  service_principal_secret        = var.service_principal_secret
  rp_service_principal_object_id  = var.rp_service_principal_object_id
}

data "azapi_resource" "customlocation" {
  depends_on = [module.azurestackhci-cluster]
  type       = "Microsoft.ExtendedLocation/customLocations@2021-08-15"
  name       = local.custom_location_name
  parent_id  = azurerm_resource_group.rg.id
}

module "azurestackhci-logicalnetwork" {
  source     = "../azurestackhci-logicalnetwork"
  depends_on = [module.azurestackhci-cluster]

  location            = azurerm_resource_group.rg.location
  name                = local.logical_network_name
  resource_group_name = azurerm_resource_group.rg.name

  enable_telemetry   = var.enable_telemetry # see variables.tf
  resource_group_id  = azurerm_resource_group.rg.id
  custom_location_id = data.azapi_resource.customlocation.id
  vm_switch_name     = "ConvergedSwitch(managementcompute)"
  starting_address   = "192.168.1.171"
  ending_address     = "192.168.1.190"
  dns_servers        = ["192.168.1.254"]
  default_gateway    = "192.168.1.1"
  address_prefix     = "192.168.1.0/24"
  vlan_id            = null
}

data "azapi_resource" "logical_network" {
  depends_on = [module.azurestackhci-logicalnetwork]
  type       = "Microsoft.AzureStackHCI/logicalNetworks@2023-09-01-preview"
  name       = local.logical_network_name
  parent_id  = data.azurerm_resource_group.rg.id
}

data "azurerm_key_vault" "deployment_key_vault" {
  depends_on          = [module.azurestackhci-logicalnetwork]
  name                = local.keyvault_name
  resource_group_name = azurerm_resource_group.rg.name
}

module "hybridcontainerservice-provisionedclusterinstance" {
  source     = "../hybridcontainerservice-provisionedclusterinstance"
  depends_on = [module.azurestackhci-logicalnetwork]

  location            = azurerm_resource_group.rg.location
  name                = local.aks_arc_name
  resource_group_name = azurerm_resource_group.rg.name

  enable_telemetry = var.enable_telemetry # see variables.tf

  custom_location_id          = data.azapi_resource.customlocation.id
  logical_network_id          = data.azapi_resource.logical_network.id
  agent_pool_profiles         = var.agent_pool_profiles
  ssh_key_vault_id            = data.azurerm_key_vault.deployment_key_vault.id
  control_plane_ip            = "192.168.1.190"
  kubernetes_version          = "1.28.5"
  control_plane_count         = 1
  rbac_admin_group_object_ids = ["ed888f99-66c1-48fe-992f-030f49ba50ed"]
}

# //Prepare AD and arc server
# module "hci-provisioners" {
#   depends_on             = [azurerm_resource_group.rg]
#   count                  = var.enableProvisioners ? 1 : 0
#   source                 = "../hci-provisioners"
#   resourceGroup          = azurerm_resource_group.rg
#   siteId                 = var.siteId
#   domainFqdn             = var.domainFqdn
#   adouPath               = local.adouPath
#   domainServerIP         = var.domainServerIP
#   domainAdminUser        = var.domainAdminUser
#   domainAdminPassword    = var.domainAdminPassword
#   authenticationMethod   = var.authenticationMethod
#   servers                = var.servers
#   clusterName            = local.clusterName
#   subscriptionId         = var.subscriptionId
#   localAdminUser         = var.localAdminUser
#   localAdminPassword     = var.localAdminPassword
#   deploymentUser         = local.deploymentUserName
#   deploymentUserPassword = var.deploymentUserPassword
#   servicePrincipalId     = var.servicePrincipalId
#   servicePrincipalSecret = var.servicePrincipalSecret
#   destory_adou           = var.destory_adou
#   virtualHostIp          = var.virtualHostIp
#   dcPort                 = var.dcPort
#   serverPorts            = var.serverPorts
# }

# module "hci" {
#   depends_on                    = [module.hci-provisioners]
#   source                        = "../hci"
#   resourceGroup                 = azurerm_resource_group.rg
#   siteId                        = var.siteId
#   domainFqdn                    = var.domainFqdn
#   subnetMask                    = var.subnetMask
#   startingAddress               = var.startingAddress
#   endingAddress                 = var.endingAddress
#   defaultGateway                = var.defaultGateway
#   dnsServers                    = var.dnsServers
#   adouPath                      = local.adouPath
#   servers                       = var.servers
#   managementAdapters            = var.managementAdapters
#   storageNetworks               = var.storageNetworks
#   rdmaEnabled                   = var.rdmaEnabled
#   storageConnectivitySwitchless = var.storageConnectivitySwitchless
#   clusterName                   = local.clusterName
#   customLocationName            = local.customLocationName
#   witnessStorageAccountName     = local.witnessStorageAccountName
#   keyvaultName                  = local.keyvaultName
#   randomSuffix                  = local.randomSuffix
#   subscriptionId                = var.subscriptionId
#   deploymentUser                = local.deploymentUserName
#   deploymentUserPassword        = var.deploymentUserPassword
#   localAdminUser                = var.localAdminUser
#   localAdminPassword            = var.localAdminPassword
#   servicePrincipalId            = var.servicePrincipalId
#   servicePrincipalSecret        = var.servicePrincipalSecret
#   rpServicePrincipalObjectId    = var.rpServicePrincipalObjectId
# }

# locals {
#   serverNames = [for server in var.servers : server.name]
# }

# module "extension" {
#   source                     = "../hci-extensions"
#   depends_on                 = [module.hci]
#   resourceGroup              = azurerm_resource_group.rg
#   siteId                     = var.siteId
#   arcSettingsId              = module.hci.arcSettings.id
#   serverNames                = local.serverNames
#   workspaceName              = local.workspaceName
#   dataCollectionEndpointName = local.dataCollectionEndpointName
#   dataCollectionRuleName     = local.dataCollectionRuleName
#   enableInsights             = var.enableInsights
#   enableAlerts               = var.enableAlerts
# }

# module "logical-network" {
#   source             = "../hci-logical-network"
#   depends_on         = [module.hci]
#   resourceGroupId    = azurerm_resource_group.rg.id
#   location           = azurerm_resource_group.rg.location
#   customLocationId   = module.hci.customlocation.id
#   logicalNetworkName = local.logicalNetworkName
#   vmSwitchName       = module.hci.vSwitchName
#   startingAddress    = var.lnet-startingAddress
#   endingAddress      = var.lnet-endingAddress
#   dnsServers         = var.lnet-dnsServers == [] ? var.dnsServers : var.lnet-dnsServers
#   defaultGateway     = var.lnet-defaultGateway == "" ? var.defaultGateway : var.lnet-defaultGateway
#   addressPrefix      = var.lnet-addressPrefix
#   vlanId             = var.lnet-vlanId
# }

# module "aks-arc" {
#   source                  = "../aks-arc"
#   depends_on              = [module.hci]
#   customLocationId        = module.hci.customlocation.id
#   resourceGroup           = azurerm_resource_group.rg
#   logicalNetworkId        = module.logical-network.logicalNetworkId
#   agentPoolProfiles       = var.agentPoolProfiles
#   sshKeyVaultId           = module.hci.keyvault.id
#   aksArcName              = local.aksArcName
#   controlPlaneIp          = var.aksArc-controlPlaneIp
#   arbId                   = module.hci.arcbridge.id
#   kubernetesVersion       = var.kubernetesVersion
#   controlPlaneCount       = var.controlPlaneCount
#   rbacAdminGroupObjectIds = var.rbacAdminGroupObjectIds
# }

# module "vm-image" {
#   source                 = "../hci-vm-gallery-image"
#   depends_on             = [module.hci]
#   customLocationId       = module.hci.customlocation.id
#   resourceGroupId        = azurerm_resource_group.rg.id
#   location               = azurerm_resource_group.rg.location
#   downloadWinServerImage = var.downloadWinServerImage
# }

# module "vm" {
#   count               = var.downloadWinServerImage ? 1 : 0
#   source              = "../hci-vm"
#   depends_on          = [module.vm-image]
#   location            = azurerm_resource_group.rg.location
#   customLocationId    = module.hci.customlocation.id
#   resourceGroupId     = azurerm_resource_group.rg.id
#   vmName              = local.vmName
#   imageId             = module.vm-image.winServerImageId
#   logicalNetworkId    = module.logical-network.logicalNetworkId
#   adminUsername       = local.vmAdminUsername
#   adminPassword       = var.vmAdminPassword
#   vCPUCount           = var.vCPUCount
#   memoryMB            = var.memoryMB
#   dynamicMemory       = var.dynamicMemory
#   dynamicMemoryMax    = var.dynamicMemoryMax
#   dynamicMemoryMin    = var.dynamicMemoryMin
#   dynamicMemoryBuffer = var.dynamicMemoryBuffer
#   dataDiskParams      = var.dataDiskParams
#   privateIPAddress    = var.privateIPAddress
#   domainToJoin        = var.domainToJoin
#   domainTargetOu      = var.domainTargetOu
#   domainJoinUserName  = var.domainJoinUserName
#   domainJoinPassword  = var.domainJoinPassword
# }
