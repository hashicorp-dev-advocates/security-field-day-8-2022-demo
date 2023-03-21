resource "azurerm_resource_group" "security-field-day" {
  location = var.rg_location
  name     = var.rg_name

  tags = {
    DoNotDelete = true
  }
}