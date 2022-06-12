resource "yandex_vpc_subnet" "subnets" {
  for_each = { for k,v in var.subnets: v["name"] => v if lookup(v, "replace_gw", false) }
  name           = each.value["name"]
  v4_cidr_blocks = each.value["cidrs"]
  zone           = var.zone
  network_id     = var.network_id
  folder_id      = var.folder_id
  route_table_id = each.value["replace_gw"] ? var.route_table_id : null
}
