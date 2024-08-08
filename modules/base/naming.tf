locals {
  resource_group_name          = "${var.site_id}-rg"
  site_resource_name           = length(var.site_id) < 4 ? "${var.site_id}-site" : "${var.site_id}"
  siteDisplayName              = var.site_id
  addressResourceName          = "${var.site_id}-address"
  deployment_user_name         = "${var.site_id}deploy"
  witness_storage_account_name = "${lower(var.site_id)}wit"
  keyvault_name                = "${var.site_id}-kv"
  adou_path                    = "OU=${var.site_id},${var.adouSuffix}"
  cluster_name                 = "${var.site_id}-cl"
  custom_location_name         = "${var.site_id}-customlocation"
  workspaceName                = "${var.site_id}-workspace"
  dataCollectionEndpointName   = "${var.site_id}-dce"
  dataCollectionRuleName       = "AzureStackHCI-${var.site_id}-dcr"
  logical_network_name         = "${var.site_id}-logicalnetwork"
  aks_arc_name                 = "${var.site_id}-aksArc"
  vmName                       = "${var.site_id}-vm"
  vmAdminUsername              = "${var.site_id}admin"
  domainJoinUserName           = "${var.site_id}vmuser"
  randomSuffix                 = true

  server_ports = {
    "AzSHOST1" = 15985,
    "AzSHOST2" = 25985
  }
  servers = [
    {
      name        = "AzSHOST1",
      ipv4Address = "192.168.1.12"
    },
    {
      name        = "AzSHOST2",
      ipv4Address = "192.168.1.13"
    }
  ]
  management_adapters = ["FABRIC", "FABRIC2"]
  storage_networks = [
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
