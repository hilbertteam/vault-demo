output "external_ipv4" {
  value = yandex_compute_instance.nat.network_interface.0.nat_ip_address
}

output "internal_ipv4" {
  value = yandex_compute_instance.nat.network_interface.0.ip_address
}

output "route_table_id" {
  value = yandex_vpc_route_table.nat_instance_route.id
}
