###                ###
### KUBERNETES IAM ###
###                ###
resource "yandex_iam_service_account" "service_account" {
  name = "service-account-${formatdate("YYYY-MM-DD-hh-mm", timestamp())}-${var.name}"
}

resource "yandex_iam_service_account" "node_account" {
  name = "node-account-${formatdate("YYYY-MM-DD-hh-mm", timestamp())}-${var.name}"
}

resource "yandex_resourcemanager_folder_iam_member" "service_account" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.service_account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "node_account" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.node_account.id}"
}


resource "yandex_kms_symmetric_key" "kms_key" {
  name              = "kms-key-${var.name}"
  description       = "Key for k8s nodes"
  default_algorithm = "AES_256"

}
