resource "azurerm_resource_group" "example" {
  name     = "test"
  location = "East US2"
}

resource "azurerm_express_route_port" "example" {
  name                = "example-erp"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  peering_location    = "Equinix-Seattle-SE2"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
}

resource "azurerm_express_route_circuit" "example" {
  name                  = "example-erc"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  express_route_port_id = azurerm_express_route_port.example.id
  bandwidth_in_gbps     = 5

  sku {
    tier   = "Standard"
    family = "MeteredData"
  }
}

resource "azurerm_express_route_circuit_authorization" "example" {
  name                       = "exampleERCAuth"
  express_route_circuit_name = azurerm_express_route_circuit.example.name
  resource_group_name        = azurerm_resource_group.example.name
}
