include {
  path = find_in_parent_folders()
}

terraform {
  source = "../..//modules/vpc"
}

inputs = {
  name = "demo-main-vpc"
  subnets = [
    {
      "name" : "nat-network", "cidrs" : ["172.16.17.0/24"]
    },
    {
      "name" : "lb-network", "cidrs" : ["172.16.21.0/24"]
    }
  ]
}
