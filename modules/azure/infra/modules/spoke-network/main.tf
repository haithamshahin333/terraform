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
