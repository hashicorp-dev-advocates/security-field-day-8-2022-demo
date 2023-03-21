data "azurerm_client_config" "current" {}

#data "hcp_azure_peering_connection" "peer" {
#  hvn_link                = hcp_hvn.azure.self_link
#  peering_id            = hcp_azure_peering_connection.peer.id
#  wait_for_active_state = true
#}