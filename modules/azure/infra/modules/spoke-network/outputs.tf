# Each subnet output resolves to either the BYO subnet ID (when caller
# supplied <subnet>_subnet_id) or the module-created subnet ID — consumers
# do not need to know which.

output "aks_subnet_id" {
  description = "Resource ID of the AKS subnet (module-created or BYO)."
  value       = var.aks_subnet_id != "" ? var.aks_subnet_id : azurerm_subnet.aks[0].id
}

output "aks_rt_association_id" {
  description = "Resource ID of the AKS subnet's route-table association, or null when no RT was provided. The k8s-cluster module's depends_on uses this to gate cluster creation when outbound_type = userDefinedRouting. Null entries are silently dropped from depends_on lists, so it's safe to pass through unconditionally."
  value       = length(azurerm_subnet_route_table_association.aks) > 0 ? azurerm_subnet_route_table_association.aks[0].id : null
}

output "postgres_subnet_id" {
  description = "Resource ID of the Postgres subnet (module-created, BYO, or null when not enabled)."
  value = (
    var.postgres_subnet_id != "" ? var.postgres_subnet_id :
    var.create_postgres_subnet ? azurerm_subnet.postgres[0].id :
    null
  )
}

output "redis_subnet_id" {
  description = "Resource ID of the Redis subnet (module-created, BYO, or null when not enabled)."
  value = (
    var.redis_subnet_id != "" ? var.redis_subnet_id :
    var.create_redis_subnet ? azurerm_subnet.redis[0].id :
    null
  )
}

output "agic_subnet_id" {
  description = "Resource ID of the AGIC subnet (module-created, BYO, or empty string when not enabled). String type (not null) to match the existing networking module's contract."
  value = (
    var.agic_subnet_id != "" ? var.agic_subnet_id :
    var.create_agic_subnet ? azurerm_subnet.agic[0].id :
    ""
  )
}

output "bastion_subnet_id" {
  description = "Resource ID of the Bastion subnet (module-created, BYO, or empty string when not enabled). String type (not null) to match the existing networking module's contract."
  value = (
    var.bastion_subnet_id != "" ? var.bastion_subnet_id :
    var.create_bastion_subnet ? azurerm_subnet.bastion[0].id :
    ""
  )
}
