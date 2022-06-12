include {
  path = find_in_parent_folders()
}

terraform {
  source = "../..//modules/nat"
}

dependency "vpc" {

  config_path = "../networks"

  mock_outputs = {
    vpc_id = "vpc_id"
    subnets = {
      "nat-network" = "subnet_id"
    }
  }
}

inputs = {
  name = "nat-instance"
  network_id = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.subnets["nat-network"]
  ip_address = "172.16.17.10"
  vpn_address_name = "vpn-address-0612"
}
