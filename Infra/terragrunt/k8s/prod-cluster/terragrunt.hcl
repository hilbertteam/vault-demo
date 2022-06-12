include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../..//modules/k8s"
}

dependencies {
  paths = ["../../nat", "../infra-cluster"]
}

dependency "vpc" {

  config_path = "../../networks-rt"

  mock_outputs = {
    vpc_id = "vpc_id"
    subnets = {
      "k8s-prod" = "subnet_id"
    }
  }
}

inputs = {
  name = "prod-cluster"
  network_id = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.subnets["k8s-prod"]
  scale_policy = {
    min = 1
    max = 2
    initial = 1
  }
  cpu_count = 2
  memory = 8
  cluster_ipv4_range = "10.212.0.0/16"
  service_ipv4_range = "10.196.0.0/16"
}
