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


//once the circuit is up the peering can then proceed

//https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-routing-portal-resource-manager#to-create-azure-private-peering
resource "azurerm_express_route_circuit_peering" "example" { 
  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = azurerm_express_route_circuit.example.name
  resource_group_name           = azurerm_resource_group.example.name
  shared_key                    = "ItsASecret"
  peer_asn                      = 100
  primary_peer_address_prefix   = "192.168.1.0/30"
  secondary_peer_address_prefix = "192.168.2.0/30"
  vlan_id                       = 100
}

//The circuit is not dependent on this being provisioned
resource "azurerm_virtual_network" "example" {
  name                = "test"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

//The circuit is not dependent on this being provisioned
resource "azurerm_subnet" "example" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

//The circuit is not dependent on this being provisioned
resource "azurerm_public_ip" "example" {
  name                = "test"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  allocation_method = "Dynamic"
sku = "Standard" // CHANGE TO BASIC IF REGION WITHOUT AZs
}

//Once the circuit is provisioned the virtual network gateway can proceed
resource "azurerm_virtual_network_gateway" "example" {
  name                = "ER-gateway"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name

  type = "ExpressRoute"

  sku = "ErGw1AZ" //https://docs.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways#gwsku -- CHANGE IF REGION WITHOUT AZs

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.example.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.example.id
  }
}

//Once the Virtual network Gateway is created then the connection can proceed
resource "azurerm_virtual_network_gateway_connection" "local" {
  name                = "ER-Gateway-Connect"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name

  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.example.id
  authorization_key          = azurerm_express_route_circuit_authorization.example.authorization_key
  express_route_circuit_id   = azurerm_express_route_circuit.example.id
}
