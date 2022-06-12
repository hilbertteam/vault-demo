output "vpc_id" {
  value = var.network_id
}

output "subnets" {
  value = { for k,v in yandex_vpc_subnet.subnets: v.name => v.id }
}
