variable "subnets" {
  type = any
}

variable "route_table_id" {
  type = string
}

variable "network_id" {
  type= string
}

variable "folder_id" {
  type = string
}

variable "zone" {
  type = string
  default = "ru-central1-b"
}