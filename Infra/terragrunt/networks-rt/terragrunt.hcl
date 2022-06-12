include {
  path = find_in_parent_folders()
}

terraform {
  source = "../..//modules/vpc-rt"
}

dependency "nat_instance" {

  config_path = "../nat"

  mock_outputs = {
    internal_ipv4 = "192.168.1.1"
    route_table_id = "route_table_id"
  }
}

dependency "vpc" {

  config_path = "../networks"

  mock_outputs = {
    vpc_id = "vpc_id"
  }
}

inputs = {
  route_table_id = dependency.nat_instance.outputs.route_table_id
  network_id = dependency.vpc.outputs.vpc_id
  subnets = [
    {
      "name" : "k8s-infra", "cidrs" : ["10.10.0.0/16"], "replace_gw": true
    },
    {
      "name" : "k8s-prod", "cidrs" : ["10.20.0.0/16"], "replace_gw": true
    }
  ]
}
