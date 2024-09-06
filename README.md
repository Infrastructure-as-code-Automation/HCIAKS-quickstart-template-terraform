# HCIAKS-quickstart-template-terraform
### NOTE: This module follows the semantic versioning and versions prior to 1.0.0 should be consider pre-release versions.
This Terraform module serves as a quickstart template for deploying an HCI cluster and a hybrid AKS cluster. It includes parameters such as enable_telemetry and enable_alert to control the provisioning of the monitoring agent and alert rules. With this module, you can effortlessly create these resources once the HCI OS is installed on the machines. The module handles Active Directory preparation and ARC onboarding for you. 

Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to <https://semver.org/>

## Requirements
- HCI OS installed on HCI nodes

## Deployment Steps
### Using UX
coming soon
### Local run
1. fork this repo
2. 
[TODO]
### deploy options
Change the modules\base\main.tf file in your repo if you want different value from default value
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_alerts"></a> [enable\_alerts](#input\_enable\_alerts) | Whether to enable Azure Monitor Alerts. | `bool` | `false` | no |
| <a name="input_enable_insights"></a> [enable\_insights](#input\_enable\_insights) | Whether to enable Azure Monitor Insights. | `bool` | `false` | no |
| <a name="input_enable_provisioners"></a> [enable\_provisioners](#input\_enable\_provisioners) | Whether to enable provisioners. | `bool` | `true` | no |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | This variable controls whether or not telemetry is enabled for the module.<br>For more information see <https://aka.ms/avm/telemetryinfo>.<br>If it is set to false, then no telemetry will be collected. | `bool` | `true` | no |

# HCIAKS Quick Start Module Detail

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>3.0 |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuremonitorwindowsagent"></a> [azuremonitorwindowsagent](#module\_azuremonitorwindowsagent) | Azure/avm-ptn-azuremonitorwindowsagent/azurerm | ~>0.0 |
| <a name="module_azurestackhci_cluster"></a> [azurestackhci\_cluster](#module\_azurestackhci\_cluster) | Azure/avm-res-azurestackhci-cluster/azurerm | ~>0.0 |
| <a name="module_azurestackhci_logicalnetwork"></a> [azurestackhci\_logicalnetwork](#module\_azurestackhci\_logicalnetwork) | Azure/avm-res-azurestackhci-logicalnetwork/azurerm | ~>0.0 |
| <a name="module_edge_site"></a> [edge\_site](#module\_edge\_site) | Azure/avm-res-edge-site/azurerm | ~>0.0 |
| <a name="module_hci_ad_provisioner"></a> [hci\_ad\_provisioner](#module\_hci\_ad\_provisioner) | Azure/avm-ptn-hci-ad-provisioner/azurerm | ~>0.0 |
| <a name="module_hci_server_provisioner"></a> [hci\_server\_provisioner](#module\_hci\_server\_provisioner) | Azure/avm-ptn-hci-server-provisioner/azurerm | ~>0.0 |
| <a name="module_hybridcontainerservice_provisionedclusterinstance"></a> [hybridcontainerservice\_provisionedclusterinstance](#module\_hybridcontainerservice\_provisionedclusterinstance) | Azure/avm-res-hybridcontainerservice-provisionedclusterinstance/azurerm | ~>0.0 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.alerts](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [external_external.lnet_ip_check](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adou_suffix"></a> [adou\_suffix](#input\_adou\_suffix) | The suffix of Active Directory OU path. | `string` | `"DC=jumpstart,DC=local"` | no |
| <a name="input_agent_pool_profiles"></a> [agent\_pool\_profiles](#input\_agent\_pool\_profiles) | The agent pool profiles for the Kubernetes cluster. | <pre>list(object({<br>    count             = number<br>    enableAutoScaling = optional(bool, false)<br>    nodeTaints        = optional(list(string))<br>    nodeLabels        = optional(map(string))<br>    maxPods           = optional(number)<br>    name              = optional(string)<br>    osSKU             = optional(string, "CBLMariner")<br>    osType            = optional(string, "Linux")<br>    vmSize            = optional(string)<br>  }))</pre> | <pre>[<br>  {<br>    "count": 1,<br>    "enableAutoScaling": false<br>  }<br>]</pre> | no |
| <a name="input_aks_arc_control_plane_ip"></a> [aks\_arc\_control\_plane\_ip](#input\_aks\_arc\_control\_plane\_ip) | The IP address of the control plane. | `string` | `"192.168.1.190"` | no |
| <a name="input_authentication_method"></a> [authentication\_method](#input\_authentication\_method) | The authentication method for Enter-PSSession. | `string` | `"Credssp"` | no |
| <a name="input_city"></a> [city](#input\_city) | The city of the site. | `string` | `""` | no |
| <a name="input_company_name"></a> [company\_name](#input\_company\_name) | The company name of the site. | `string` | `""` | no |
| <a name="input_contact_name"></a> [contact\_name](#input\_contact\_name) | The contact name of the site. | `string` | `" "` | no |
| <a name="input_control_plane_count"></a> [control\_plane\_count](#input\_control\_plane\_count) | The number of control plane nodes for the Kubernetes cluster. | `number` | `1` | no |
| <a name="input_country"></a> [country](#input\_country) | The order country of the site. | `string` | `"US"` | no |
| <a name="input_data_collection_rule_resource_id"></a> [data\_collection\_rule\_resource\_id](#input\_data\_collection\_rule\_resource\_id) | The id of the Azure Log Analytics data collection rule. | `string` | n/a | yes |
| <a name="input_dc_ip"></a> [dc\_ip](#input\_dc\_ip) | The ip of the server. | `string` | n/a | yes |
| <a name="input_dc_port"></a> [dc\_port](#input\_dc\_port) | Domain controller winrm port in virtual host | `number` | `6985` | no |
| <a name="input_default_gateway"></a> [default\_gateway](#input\_default\_gateway) | The default gateway for the network. | `string` | `"192.168.1.1"` | no |
| <a name="input_deployment_user_password"></a> [deployment\_user\_password](#input\_deployment\_user\_password) | The password for deployment user. | `string` | n/a | yes |
| <a name="input_destory_adou"></a> [destory\_adou](#input\_destory\_adou) | whether destroy previous adou | `bool` | `false` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | A list of DNS server IP addresses. | `list(string)` | <pre>[<br>  "192.168.1.254"<br>]</pre> | no |
| <a name="input_domain_admin_password"></a> [domain\_admin\_password](#input\_domain\_admin\_password) | The password for the domain administrator account. | `string` | n/a | yes |
| <a name="input_domain_admin_user"></a> [domain\_admin\_user](#input\_domain\_admin\_user) | The username for the domain administrator account. | `string` | n/a | yes |
| <a name="input_domain_fqdn"></a> [domain\_fqdn](#input\_domain\_fqdn) | The domain FQDN. | `string` | `"jumpstart.local"` | no |
| <a name="input_email_list"></a> [email\_list](#input\_email\_list) | A list of email addresses for the site. | `list(string)` | `[]` | no |
| <a name="input_enable_alerts"></a> [enable\_alerts](#input\_enable\_alerts) | Whether to enable Azure Monitor Alerts. | `bool` | `false` | no |
| <a name="input_enable_insights"></a> [enable\_insights](#input\_enable\_insights) | Whether to enable Azure Monitor Insights. | `bool` | `false` | no |
| <a name="input_enable_provisioners"></a> [enable\_provisioners](#input\_enable\_provisioners) | Whether to enable provisioners. | `bool` | `true` | no |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | This variable controls whether or not telemetry is enabled for the module.<br>For more information see <https://aka.ms/avm/telemetryinfo>.<br>If it is set to false, then no telemetry will be collected. | `bool` | `true` | no |
| <a name="input_ending_address"></a> [ending\_address](#input\_ending\_address) | The ending IP address of the IP address range. | `string` | `"192.168.1.65"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The version of Kubernetes to use for the provisioned cluster. | `string` | `"1.28.5"` | no |
| <a name="input_lnet_address_prefix"></a> [lnet\_address\_prefix](#input\_lnet\_address\_prefix) | The CIDR prefix of the subnet that start from startting address and end with ending address, this can be omit if using existing logical network | `string` | `"192.168.1.0/24"` | no |
| <a name="input_lnet_default_gateway"></a> [lnet\_default\_gateway](#input\_lnet\_default\_gateway) | The default gateway for the network. | `string` | `""` | no |
| <a name="input_lnet_dns_servers"></a> [lnet\_dns\_servers](#input\_lnet\_dns\_servers) | A list of DNS server IP addresses. | `list(string)` | `[]` | no |
| <a name="input_lnet_ending_address"></a> [lnet\_ending\_address](#input\_lnet\_ending\_address) | The ending IP address of the IP address range of the logical network, this can be omit if using existing logical network | `string` | `"192.168.1.190"` | no |
| <a name="input_lnet_starting_address"></a> [lnet\_starting\_address](#input\_lnet\_starting\_address) | The starting IP address of the IP address range of the logical network, this can be omit if using existing logical network | `string` | `"192.168.1.171"` | no |
| <a name="input_lnet_vlan_id"></a> [lnet\_vlan\_id](#input\_lnet\_vlan\_id) | The vlan id of the logical network, default is not set vlan id, this can be omit if using existing logical network | `number` | `null` | no |
| <a name="input_local_admin_password"></a> [local\_admin\_password](#input\_local\_admin\_password) | The password for the local administrator account. | `string` | n/a | yes |
| <a name="input_local_admin_user"></a> [local\_admin\_user](#input\_local\_admin\_user) | The username for the local administrator account. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_management_adapters"></a> [management\_adapters](#input\_management\_adapters) | n/a | `list(string)` | <pre>[<br>  "FABRIC",<br>  "FABRIC2"<br>]</pre> | no |
| <a name="input_mobile"></a> [mobile](#input\_mobile) | The mobile phone number of the site. | `string` | `""` | no |
| <a name="input_phone"></a> [phone](#input\_phone) | The phone number of the site. | `string` | `""` | no |
| <a name="input_phone_extension"></a> [phone\_extension](#input\_phone\_extension) | The phone extension of the site. | `string` | `""` | no |
| <a name="input_postal_code"></a> [postal\_code](#input\_postal\_code) | The postal code of the site. | `string` | `""` | no |
| <a name="input_rbac_admin_group_object_ids"></a> [rbac\_admin\_group\_object\_ids](#input\_rbac\_admin\_group\_object\_ids) | The object id of the Azure AD group that will be assigned the 'cluster-admin' role in the Kubernetes cluster. | `list(string)` | <pre>[<br>  "ed888f99-66c1-48fe-992f-030f49ba50ed"<br>]</pre> | no |
| <a name="input_rdma_enabled"></a> [rdma\_enabled](#input\_rdma\_enabled) | Indicates whether RDMA is enabled. | `bool` | n/a | yes |
| <a name="input_rp_service_principal_object_id"></a> [rp\_service\_principal\_object\_id](#input\_rp\_service\_principal\_object\_id) | The object ID of the HCI resource provider service principal. | `string` | `""` | no |
| <a name="input_server_ports"></a> [server\_ports](#input\_server\_ports) | Server winrm ports in virtual host | `map(number)` | <pre>{<br>  "AzSHOST1": 15985,<br>  "AzSHOST2": 25985<br>}</pre> | no |
| <a name="input_servers"></a> [servers](#input\_servers) | A list of servers with their names and IPv4 addresses. | <pre>list(object({<br>    name        = string<br>    ipv4Address = string<br>  }))</pre> | <pre>[<br>  {<br>    "ipv4Address": "192.168.1.12",<br>    "name": "AzSHOST1"<br>  },<br>  {<br>    "ipv4Address": "192.168.1.13",<br>    "name": "AzSHOST2"<br>  }<br>]</pre> | no |
| <a name="input_service_principal_id"></a> [service\_principal\_id](#input\_service\_principal\_id) | The service principal ID for ARB. | `string` | n/a | yes |
| <a name="input_service_principal_secret"></a> [service\_principal\_secret](#input\_service\_principal\_secret) | The service principal secret. | `string` | n/a | yes |
| <a name="input_site_id"></a> [site\_id](#input\_site\_id) | A unique identifier for the site. | `string` | n/a | yes |
| <a name="input_starting_address"></a> [starting\_address](#input\_starting\_address) | The starting IP address of the IP address range. | `string` | `"192.168.1.55"` | no |
| <a name="input_state_or_province"></a> [state\_or\_province](#input\_state\_or\_province) | The state or province of the site. | `string` | `""` | no |
| <a name="input_storage_connectivity_switchless"></a> [storage\_connectivity\_switchless](#input\_storage\_connectivity\_switchless) | Indicates whether storage connectivity is switchless. | `bool` | n/a | yes |
| <a name="input_storage_networks"></a> [storage\_networks](#input\_storage\_networks) | n/a | <pre>list(object({<br>    name               = string<br>    networkAdapterName = string<br>    vlanId             = string<br>  }))</pre> | <pre>[<br>  {<br>    "name": "Storage1Network",<br>    "networkAdapterName": "StorageA",<br>    "vlanId": "711"<br>  },<br>  {<br>    "name": "Storage2Network",<br>    "networkAdapterName": "StorageB",<br>    "vlanId": "712"<br>  }<br>]</pre> | no |
| <a name="input_street_address_1"></a> [street\_address\_1](#input\_street\_address\_1) | The first line of the street address of the site. | `string` | `""` | no |
| <a name="input_street_address_2"></a> [street\_address\_2](#input\_street\_address\_2) | The second line of the street address of the site. | `string` | `""` | no |
| <a name="input_street_address_3"></a> [street\_address\_3](#input\_street\_address\_3) | The third line of the street address of the site. | `string` | `""` | no |
| <a name="input_subnet_mask"></a> [subnet\_mask](#input\_subnet\_mask) | The subnet mask for the network. | `string` | `"255.255.255.0"` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The subscription ID for resources. | `string` | n/a | yes |
| <a name="input_virtual_host_ip"></a> [virtual\_host\_ip](#input\_virtual\_host\_ip) | The virtual host IP address. | `string` | n/a | yes |
| <a name="input_zip_extended_code"></a> [zip\_extended\_code](#input\_zip\_extended\_code) | The extended ZIP code of the site. | `string` | `""` | no |

## Outputs

No outputs.
