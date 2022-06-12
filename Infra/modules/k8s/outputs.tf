output "k8s_external_ip" {
  value = yandex_kubernetes_cluster.kube_master.master.0.external_v4_endpoint
}

output "k8s_internal_ip" {
  value = yandex_kubernetes_cluster.kube_master.master.0.internal_v4_endpoint
}

output "claster_certificate" {
  value = yandex_kubernetes_cluster.kube_master.master.0.cluster_ca_certificate
  sensitive = true
}

output "k8s_id" {
  value = yandex_kubernetes_cluster.kube_master.id
}
