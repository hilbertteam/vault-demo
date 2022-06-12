resource "yandex_kubernetes_node_group" "node_group" {
  name        = "main-${var.name}"
  cluster_id  = yandex_kubernetes_cluster.kube_master.id
  description = "${var.name} k8s cluster node group"
  version     = var.kubernetes_version


  instance_template {
    platform_id = "standard-v3"

    network_interface {
      nat        = false
      subnet_ids = [var.subnet_id]
    }

    resources {
      memory = var.memory
      cores  = var.cpu_count
    }

    boot_disk {
      type = "network-hdd"
      size = var.disksize
    }

    scheduling_policy {
      preemptible = false
    }

    metadata = {
      ssh-keys = "somebody:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIsZvnscuWOGy+G29LSICFfvEwxC58q1dozc+mAe3xNk"
    }
  }

  scale_policy {
    auto_scale {
      min     = var.scale_policy.min
      max     = var.scale_policy.max
      initial = var.scale_policy.initial
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "23:00:00.000000000"
      duration   = "2h0m0s"
    }

    maintenance_window {
      day        = "saturday"
      start_time = "23:00:00.000000000"
      duration   = "3h30m0s"
    }
  }
}
