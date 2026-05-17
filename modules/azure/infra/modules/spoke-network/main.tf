# ══════════════════════════════════════════════════════════════════════════════
# Module: spoke-network
# Purpose: Create subnets (and optional route-table associations) inside a
#          customer-owned spoke VNet that is already peered to a hub and has
#          DNS configured. Parallel to modules/networking, which creates its
#          own standalone VNet.
#
# Activated when network_mode = "byo-vnet" at the root.
# Each subnet is either created (CIDR provided) or BYO (existing subnet ID
# provided). Route-table association is optional per subnet — required only
# for the AKS subnet when outbound_type = userDefinedRouting.
# ══════════════════════════════════════════════════════════════════════════════

# ── AKS subnet ────────────────────────────────────────────────────────────────
# Always managed — created in the spoke VNet's RG unless aks_subnet_id is set
# (BYO). With Azure CNI Overlay, only nodes consume IPs from this subnet.

resource "azurerm_subnet" "aks" {
  count                = var.aks_subnet_id == "" ? 1 : 0
  name                 = var.aks_subnet_name
  resource_group_name  = var.spoke_vnet_resource_group_name
  virtual_network_name = var.spoke_vnet_name
  address_prefixes     = var.aks_subnet_address_prefix
  service_endpoints    = var.aks_subnet_service_endpoints
}

# Route-table association — created only when the module created the subnet AND
# a route table was supplied. AKS outbound_type=userDefinedRouting requires
# the association to exist before cluster creation; the root module exposes
# this resource's ID as a dependency hook for the cluster's depends_on.
resource "azurerm_subnet_route_table_association" "aks" {
  count          = var.aks_subnet_id == "" && var.aks_subnet_route_table_id != "" ? 1 : 0
  subnet_id      = azurerm_subnet.aks[0].id
  route_table_id = var.aks_subnet_route_table_id
}

# ── Postgres subnet ───────────────────────────────────────────────────────────
# Delegated to Microsoft.DBforPostgreSQL/flexibleServers — the delegation
# grants the service permission to inject NICs into the subnet. No other
# resources may share a delegated subnet.

resource "azurerm_subnet" "postgres" {
  count                = var.create_postgres_subnet && var.postgres_subnet_id == "" ? 1 : 0
  name                 = var.postgres_subnet_name
  resource_group_name  = var.spoke_vnet_resource_group_name
  virtual_network_name = var.spoke_vnet_name
  address_prefixes     = var.postgres_subnet_address_prefix

  delegation {
    name = "postgresql-delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet_route_table_association" "postgres" {
  count = (
    var.create_postgres_subnet
    && var.postgres_subnet_id == ""
    && var.postgres_subnet_route_table_id != ""
  ) ? 1 : 0
  subnet_id      = azurerm_subnet.postgres[0].id
  route_table_id = var.postgres_subnet_route_table_id
}
