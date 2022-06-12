output "vpc_id" {
  value = yandex_vpc_network.vpc.id
}

output "subnets" {
  value = { for k,v in yandex_vpc_subnet.subnets: v.name => v.id }
}
