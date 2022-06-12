resource "yandex_vpc_address" "vpn_address" {
  name = var.vpn_address_name
  external_ipv4_address {
    zone_id = var.zone
  }
}

resource "yandex_compute_instance" "nat" {
  name        = var.name
  description = "Виртуальная машина для статического egress IP"
  platform_id = var.platform_id
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8drj7lsj7btotd7et5"
    }
  }

  network_interface {
    ip_address = var.ip_address
    nat       = true
    subnet_id = var.subnet_id
    nat_ip_address = yandex_vpc_address.vpn_address.external_ipv4_address[0].address
  }

  metadata = {
    user-data : "#cloud-config\nusers:\n  - name: ${var.ssh_user_name}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n     - ${var.ssh_key_public}"
    serial-port-enable = 1
  }
}

resource "yandex_vpc_route_table" "nat_instance_route" {
  name = "net_to_inet"
  network_id = var.network_id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.ip_address
  }
}

# resource "local_file" "script" {
#   content  = "#!/bin/sh\n while ! echo exit | nc ${yandex_vpc_address.vpn_address.external_ipv4_address[0].address} 22; do sleep 1; done"
#   filename = "/tmp/wait-instance.sh"
# }

# resource "null_resource" "ansible" {
# 
#   depends_on = [yandex_compute_instance.nat, local_file.script]
# 
#   provisioner "local-exec" {
#     command = "/tmp/wait-instance.sh; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${yandex_vpc_address.vpn_address.external_ipv4_address[0].address}, -u ${var.ssh_user_name} --private-key ${var.ssh_key_private} ${path.module}/ansible/playbooks/environment.yml"
#   }
# }

