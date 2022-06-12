include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../..//modules/k8s"
}

dependencies {
  paths = ["../../nat"]
}

dependency "vpc" {

  config_path = "../../networks-rt"

  mock_outputs = {
    vpc_id = "vpc_id"
    subnets = {
      "k8s-infra" = "subnet_id"
    }
  }
}

inputs = {
  name = "infra-cluster"
  network_id = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.subnets["k8s-infra"]
  scale_policy = {
    min = 1
    max = 3
    initial = 1
  }
  cpu_count = 4
  memory = 8
}
