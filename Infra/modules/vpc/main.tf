resource "yandex_vpc_network" "vpc" {
  name      = var.name
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "subnets" {
  for_each = { for k,v in var.subnets: v["name"] => v }
  name           = each.value["name"]
  v4_cidr_blocks = each.value["cidrs"]
  zone           = var.zone
  network_id     = yandex_vpc_network.vpc.id
  folder_id      = var.folder_id
}
