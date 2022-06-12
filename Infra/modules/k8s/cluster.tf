resource "yandex_kubernetes_cluster" "kube_master" {

  name        = var.name
  description = "${var.name} k8s cluster"
  network_id  = var.network_id

  master {
    version = var.kubernetes_version
    zonal {
      zone      = var.zone
      subnet_id = var.subnet_id
    }

    public_ip = true

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "23:00"
        duration   = "2h"
      }
    }
  }

  cluster_ipv4_range = var.cluster_ipv4_range
  service_ipv4_range = var.service_ipv4_range

  service_account_id      = yandex_iam_service_account.service_account.id
  node_service_account_id = yandex_iam_service_account.node_account.id

  depends_on = [
    yandex_iam_service_account.node_account,
    yandex_iam_service_account.service_account,
    yandex_resourcemanager_folder_iam_member.node_account,
    yandex_resourcemanager_folder_iam_member.service_account
  ]


  release_channel         = "RAPID"
  network_policy_provider = "CALICO"

  kms_provider {
    key_id = yandex_kms_symmetric_key.kms_key.id
  }
}
