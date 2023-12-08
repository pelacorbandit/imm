variable "name_of_ucs_domain_profile" {

}

variable "org_moid" {

}

variable "fc_port_id_start" {
  
}

variable "fc_port_id_end" {
  
}

variable "list_of_server_ports" {
  type = list(any)
}

variable "list_of_eth_pc_ports" {
  type = list(any)
}

variable "list_of_fc_pc_ports" {
  type = list(any)
}

variable "fabric_a_vsan_id" {
  
}

variable "fabric_b_vsan_id" {
  
}

variable "fabric_a_pc_id" {
  
}

variable "fabric_b_pc_id" {
  
}

variable "fabric_a_eth_pc_id" {
  
}

variable "fabric_b_eth_pc_id" {
  
}

variable "fabric_a_fcoe_vlan" {
  
}

variable "fabric_b_fcoe_vlan" {
  
}

variable "fi_serial_number_a" {
 default = [] 
}

variable "fi_serial_number_b" {
 default = []  
}

variable "assigned_switch_a" {
 default = false 
}

variable "assigned_switch_b" {
  default = false
}

