module "name_domain_profile" {
  source                     = "./modules/domain_profile"
  name_of_ucs_domain_profile = "name_of_domain"
  org_moid                   = module.z2_cloud_org_details.org_moid
  #FibreChannel Port's
  fc_port_id_start     = num
  fc_port_id_end       = num
  list_of_server_ports = [1,2,3,4,etc]
  list_of_eth_pc_ports = [10,12]
  list_of_fc_pc_ports  = [1,2]
  fabric_a_vsan_id     = number
  fabric_b_vsan_id     = number
  fabric_a_pc_id       = number
  fabric_b_pc_id       = number
  fabric_a_eth_pc_id   = number
  fabric_b_eth_pc_id   = number
  fabric_a_fcoe_vlan   = number
  fabric_b_fcoe_vlan   = number
  #set assigned switch to true with serial numbers in fi_serial_number_a/b
  assigned_switch_a = true
  assigned_switch_b = true
  #serial number in quotes in bracket
  fi_serial_number_a = "FDO****"
  fi_serial_number_b = "FDO****"
}
