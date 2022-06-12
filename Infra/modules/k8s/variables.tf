variable "zone" {
  type        = string
  default     = "ru-central1-b"
  description = "(Optional) The default availability zone to operate under, if not specified by a given resource."
}

variable "folder_id" {
  type        = string
  description = "(Required) The ID of the folder to operate under, if not specified by a given resource."
}

variable "name" {
  type        = string
  description = "(Required) Name of the Kubernetes cluster and connected resources"
}

variable "kubernetes_version" {
  type        = string
  description = "(Optional) Version of Kubernetes cluster"
  default     = "1.21"
}

variable "disksize" {
  type        = number
  description = "(Required) Disk size for Kubernetes nodes"
  default = 40
}

variable "subnet_id" {
  type = string
}

variable "network_id" {
  type = string
}

variable "scale_policy" {
  type = any
  default = {
    min     = 1
    max     = 3
    initial = 2
  }
}

variable "cpu_count" {
  type = number
  default = 2
}

variable "memory" {
  type = number
  default = 2
}

variable "cluster_ipv4_range" {
  type = string
  default = "10.112.0.0/16"
}

variable "service_ipv4_range" {
  type = string
  default = "10.96.0.0/16"
}
