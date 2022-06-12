variable "folder_id" {
  type = string
}

variable "subnets" {
  type = list(object({
    name = string
    cidrs = list(string)
  }))
}

variable "name" {
  type = string
}

variable "zone" {
  type = string
  default = "ru-central1-b"
}