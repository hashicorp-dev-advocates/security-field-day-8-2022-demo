resource "hcp_hvn" "azure" {
  hvn_id         = "hvn"
  cloud_provider = "azure"
  region         = "uksouth"
  cidr_block     = "172.25.16.0/20"
}

resource "hcp_vault_cluster" "azure" {
  cluster_id      = "vault-cluster"
  hvn_id          = hcp_hvn.azure.hvn_id
  tier            = "dev"
  public_endpoint = true
}

resource "hcp_azure_peering_connection" "peer" {
  hvn_link                 = hcp_hvn.azure.self_link
  peering_id               = "hcp-azure"
  peer_vnet_name           = azurerm_virtual_network.security_field_day.name
  peer_subscription_id     = data.azurerm_client_config.current.subscription_id
  peer_tenant_id           = data.azurerm_client_config.current.tenant_id
  peer_resource_group_name = azurerm_resource_group.security-field-day.name
  peer_vnet_region         = azurerm_resource_group.security-field-day.location
}

#resource "hcp_hvn_route" "route" {
#  hvn_link         = hcp_hvn.azure.self_link
#  hvn_route_id     = "azure-route"
#  destination_cidr = "172.31.0.0/16"
#  target_link      = hcp_azure_peering_connection.peer.self_link
#}

locals {
  application_id = "95829541-4370-4ba8-bf50-944a9eb2cf48"
  role_def_name  = join("-", ["rob-hcp-hvn-peering-access", local.application_id])
  vnet_id        = "/subscriptions/28af6932-cb76-431f-ba61-5ec6d1e8b422/resourceGroups/security-field-day/providers/Microsoft.Network/virtualNetworks/security-field-day"
}

resource "azuread_service_principal" "principal" {
  application_id = local.application_id
}

resource "azurerm_role_definition" "definition" {
  name  = local.role_def_name
  scope = local.vnet_id

  assignable_scopes = [
    local.vnet_id
  ]

  permissions {
    actions = [
      "Microsoft.Network/virtualNetworks/peer/action",
      "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
      "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write"
    ]
  }
}

resource "azurerm_role_assignment" "role_assignment" {
  principal_id       = azuread_service_principal.principal.id
  role_definition_id = azurerm_role_definition.definition.role_definition_resource_id
  scope              = local.vnet_id
}
