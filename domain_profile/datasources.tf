data "intersight_network_element_summary" "fi-a" {
  count = var.assigned_switch_a ? 1 : 0
  serial = var.fi_serial_number_a
}

data "intersight_network_element_summary" "fi-b" {
  count = var.assigned_switch_b ? 1 : 0
  serial = var.fi_serial_number_b
}
