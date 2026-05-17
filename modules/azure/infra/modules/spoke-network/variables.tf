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
    error_message = "spoke_vnet_name is required."
  }
}

variable "spoke_vnet_resource_group_name" {
  type        = string
  description = "Resource group of the spoke VNet. Subnets in Azure are scoped to the parent VNet's RG, not the module's RG."

  validation {
    condition     = var.spoke_vnet_resource_group_name != ""
    error_message = "spoke_vnet_resource_group_name is required."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
