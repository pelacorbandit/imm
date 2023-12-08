#Create Fabric switch Cluster Profiles
resource "intersight_fabric_switch_cluster_profile" "fabric_switch_cluster_profile" {
  name = var.name_of_ucs_domain_profile
  type = "instance"
  organization {
    object_type = "organization.Organization"
    moid        = var.org_moid
  }
}

#Create Fabric Switch Profiles
resource "intersight_fabric_switch_profile" "fabric_switch_profile-A" {
  name = "${var.name_of_ucs_domain_profile}-A"
  type = "instance"
  switch_cluster_profile {
    moid        = intersight_fabric_switch_cluster_profile.fabric_switch_cluster_profile.moid
    object_type = "fabric.SwitchClusterProfile"
  }
  dynamic "assigned_switch" {
    for_each = var.assigned_switch_a ? [1] : []
    content {
      moid        = data.intersight_network_element_summary.fi-a.results[0].moid
      object_type = "network.Element"
    }
  }
}

resource "intersight_fabric_switch_profile" "fabric_switch_profile-B" {
  name = "${var.name_of_ucs_domain_profile}-B"
  type = "instance"
  switch_cluster_profile {
    moid        = intersight_fabric_switch_cluster_profile.fabric_switch_cluster_profile.moid
    object_type = "fabric.SwitchClusterProfile"
  }
  dynamic "assigned_switch" {
    for_each = var.assigned_switch_b ? [1] : []
    content{
      moid        = data.intersight_network_element_summary.fi-b.results[0].moid
      object_type = "network.Element"
    }
  }
}

#Create port policy
resource "intersight_fabric_port_policy" "fabric_port_policy-FIA" {
  name         = "${var.name_of_ucs_domain_profile}_FI_port_config-A"
  device_model = "UCS-FI-6454"
  organization {
    object_type = "organization.Organization"
    moid        = var.org_moid
  }
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile-A.moid
    object_type = "fabric.SwitchProfile"
  }
}

resource "intersight_fabric_port_policy" "fabric_port_policy-FIB" {
  name         = "${var.name_of_ucs_domain_profile}_FI_port_config-B"
  device_model = "UCS-FI-6454"
  organization {
    object_type = "organization.Organization"
    moid        = var.org_moid
  }
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile-B.moid
    object_type = "fabric.SwitchProfile"
  }
}

#Configure ports as FC:
resource "intersight_fabric_port_mode" "fabric_port_mode_FC-FIA" {
  custom_mode   = "FibreChannel"
  port_id_end   = var.fc_port_id_end
  port_id_start = var.fc_port_id_start
  slot_id       = 1
  port_policy {
    moid        = intersight_fabric_port_policy.fabric_port_policy-FIA.moid
    object_type = "fabric.PortPolicy"
  }
}
resource "intersight_fabric_port_mode" "fabric_port_mode_FC-FIB" {
  custom_mode   = "FibreChannel"
  port_id_end   = var.fc_port_id_end
  port_id_start = var.fc_port_id_start
  slot_id       = 1
  port_policy {
    moid        = intersight_fabric_port_policy.fabric_port_policy-FIB.moid
    object_type = "fabric.PortPolicy"
  }
}

#Configure server ports:
locals {
  server_list_set  = toset([for element in var.list_of_server_ports : tostring(element)])
  eth_pc_ports_set = toset([for element in var.list_of_eth_pc_ports : tostring(element)])
  fc_pc_ports_set  = toset([for element in var.list_of_fc_pc_ports : tostring(element)])
}

resource "intersight_fabric_server_role" "fabric_server_role-FIA" {
  for_each          = local.server_list_set
  aggregate_port_id = 0
  port_id           = each.value
  slot_id           = 1
  port_policy {
    moid        = intersight_fabric_port_policy.fabric_port_policy-FIA.moid
    object_type = "fabric.PortPolicy"
  }
}

resource "intersight_fabric_server_role" "fabric_server_role-FIB" {
  for_each          = local.server_list_set
  aggregate_port_id = 0
  port_id           = each.value
  slot_id           = 1
  port_policy {
    moid        = intersight_fabric_port_policy.fabric_port_policy-FIB.moid
    object_type = "fabric.PortPolicy"
  }
}

#Configure Eth Port Channels:
resource "intersight_fabric_uplink_pc_role" "fabric_uplink_pc_role-FIA" {
  pc_id = var.fabric_a_eth_pc_id
  dynamic "ports" {
    for_each = local.eth_pc_ports_set
    content {
      port_id           = ports.value
      aggregate_port_id = 0
      slot_id           = 1
      class_id          = "fabric.PortIdentifier"
      object_type       = "fabric.PortIdentifier"
    }
  }
  admin_speed = "Auto"
  port_policy {
    moid        = intersight_fabric_port_policy.fabric_port_policy-FIA.moid
    object_type = "fabric.PortPolicy"
  }
}

resource "intersight_fabric_uplink_pc_role" "fabric_uplink_pc_role-FIB" {
  pc_id = var.fabric_b_eth_pc_id
  dynamic "ports" {
    for_each = local.eth_pc_ports_set
    content {
      port_id           = ports.value
      aggregate_port_id = 0
      slot_id           = 1
      class_id          = "fabric.PortIdentifier"
      object_type       = "fabric.PortIdentifier"
    }
  }
  admin_speed = "Auto"
  port_policy {
    moid        = intersight_fabric_port_policy.fabric_port_policy-FIB.moid
    object_type = "fabric.PortPolicy"
  }
}

#Configure FC Port Channels:
resource "intersight_fabric_fc_uplink_pc_role" "fabric_fc_uplink_pc_role-FIA" {
  depends_on   = [intersight_fabric_port_mode.fabric_port_mode_FC-FIA]
  fill_pattern = "Idle"
  vsan_id      = var.fabric_a_vsan_id
  pc_id        = var.fabric_a_pc_id
  dynamic "ports" {
    for_each = local.fc_pc_ports_set
    content {
      port_id           = ports.value
      aggregate_port_id = 0
      slot_id           = 1
      class_id          = "fabric.PortIdentifier"
      object_type       = "fabric.PortIdentifier"
    }
  }
  port_policy {
    moid        = intersight_fabric_port_policy.fabric_port_policy-FIA.moid
    object_type = "fabric.PortPolicy"
  }
}

resource "intersight_fabric_fc_uplink_pc_role" "fabric_fc_uplink_pc_role-FIB" {
  depends_on   = [intersight_fabric_port_mode.fabric_port_mode_FC-FIB]
  fill_pattern = "Idle"
  vsan_id      = var.fabric_b_vsan_id
  pc_id        = var.fabric_b_pc_id
  dynamic "ports" {
    for_each = local.fc_pc_ports_set
    content {
      port_id           = ports.value
      aggregate_port_id = 0
      slot_id           = 1
      class_id          = "fabric.PortIdentifier"
      object_type       = "fabric.PortIdentifier"
    }
  }
  port_policy {
    moid        = intersight_fabric_port_policy.fabric_port_policy-FIB.moid
    object_type = "fabric.PortPolicy"
  }
}

resource "intersight_fabric_fc_network_policy" "fabric_fc_network_A" {
  name            = "${var.name_of_ucs_domain_profile}_fabric_fc_network_A"
  description     = "fabric fiber channel network policy"
  enable_trunking = true
  organization {
    object_type = "organization.Organization"
    moid        = var.org_moid
  }
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile-A.moid
    object_type = "fabric.SwitchProfile"
  }
}
resource "intersight_fabric_fc_network_policy" "fabric_fc_network_B" {
  name            = "${var.name_of_ucs_domain_profile}_fabric_fc_network_B"
  description     = "fabric fiber channel network policy"
  enable_trunking = true
  organization {
    object_type = "organization.Organization"
    moid        = var.org_moid
  }
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile-B.moid
    object_type = "fabric.SwitchProfile"
  }
}

resource "intersight_fabric_vsan" "cloud_ucs_FI_vsan_config-A" {
  default_zoning = "Disabled"
  fcoe_vlan      = var.fabric_a_fcoe_vlan
  name           = "VSAN_${var.fabric_a_vsan_id}"
  vsan_id        = var.fabric_a_vsan_id
  fc_network_policy {
    moid        = intersight_fabric_fc_network_policy.fabric_fc_network_A.moid
    object_type = "fabric.FcNetworkPolicy"
  }

}

resource "intersight_fabric_vsan" "cloud_ucs_FI_vsan_config-B" {
  default_zoning = "Disabled"
  fcoe_vlan      = var.fabric_b_fcoe_vlan
  name           = "VSAN_${var.fabric_b_vsan_id}"
  vsan_id        = var.fabric_b_vsan_id
    fc_network_policy {
    moid        = intersight_fabric_fc_network_policy.fabric_fc_network_B.moid
    object_type = "fabric.FcNetworkPolicy"
  }
}

