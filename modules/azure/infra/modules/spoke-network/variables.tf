# ── Spoke VNet (BYO — customer pre-provisions, peered to hub, DNS configured) ─

variable "spoke_vnet_id" {
  type        = string
  description = "Resource ID of the customer's spoke VNet (peered to the hub, DNS configured)."

  validation {
    condition     = var.spoke_vnet_id != ""
    error_message = "spoke_vnet_id is required when this module is instantiated."
  }
}

variable "spoke_vnet_name" {
  type        = string
  description = "Name of the spoke VNet. Required because azurerm_subnet references the VNet by name (not ID)."

  validation {
    condition     = var.spoke_vnet_name != ""
    error_message = "spoke_vnet_name is required when this module is instantiated."
  }
}

variable "spoke_vnet_resource_group_name" {
  type        = string
  description = "Resource group of the spoke VNet. Subnets in Azure are scoped to the parent VNet's RG, not the module's RG."

  validation {
    condition     = var.spoke_vnet_resource_group_name != ""
    error_message = "spoke_vnet_resource_group_name is required when this module is instantiated."
  }
}

variable "tags" {
  type        = map(string)
  description = "Common Azure resource tags to apply to all resources in this module"
  default     = {}
}

# ── AKS subnet (always managed: create or BYO) ────────────────────────────────

variable "aks_subnet_id" {
  type        = string
  default     = ""
  description = "BYO: pre-existing AKS subnet resource ID. If empty, the module creates one using aks_subnet_address_prefix + aks_subnet_route_table_id."
}

variable "aks_subnet_name" {
  type        = string
  default     = "snet-aks"
  description = "Name of the AKS subnet (used only when the module creates it)."
}

variable "aks_subnet_address_prefix" {
  type        = list(string)
  default     = []
  description = "CIDR(s) for the AKS subnet. Required when aks_subnet_id is empty. With CNI Overlay a /24 is typically enough — only nodes consume IPs from this range."
}

variable "aks_subnet_route_table_id" {
  type        = string
  default     = ""
  description = "Route table resource ID to associate with the AKS subnet. Required when aks_subnet_id is empty (outbound_type=userDefinedRouting mandates an RT before cluster creation)."
}

variable "aks_subnet_service_endpoints" {
  type        = list(string)
  default     = ["Microsoft.Storage", "Microsoft.KeyVault"]
  description = "Service endpoints on the AKS subnet. Default matches existing module behavior so the Blob/KV deny-by-default firewalls keep allowlisting the subnet. Set to [] to force all egress through the hub firewall."
}

# ── Postgres subnet (when postgres_source = "external") ───────────────────────

variable "create_postgres_subnet" {
  type        = bool
  default     = false
  description = "Whether the module should manage a Postgres subnet. Set true by the root module when postgres_source = external AND postgres_subnet_id is empty."
}

variable "postgres_subnet_id" {
  type        = string
  default     = ""
  description = "BYO: pre-existing Postgres subnet resource ID (with Microsoft.DBforPostgreSQL/flexibleServers delegation already in place)."
}

variable "postgres_subnet_name" {
  type    = string
  default = "snet-postgres"
}

variable "postgres_subnet_address_prefix" {
  type    = list(string)
  default = []
}

variable "postgres_subnet_route_table_id" {
  type        = string
  default     = ""
  description = "Optional. Most production setups leave this null — Flex Server only talks intra-VNet."
}
