variable "folder_id" {
  type = string
}

variable "platform_id" {
  type = string
  default = "standard-v3"

}

variable "name" {
  type = string
}

variable "zone" {
  type = string
  default = "ru-central1-b"
}

variable "ssh_user_name" {
  type = string
  default = "ubuntu"
}

variable "ssh_key_public" {
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZ7BielMu4POiNMlL9HC7EKqIIwAxOsXM2D08wQJFo7116IO7Z8zIzA7OrI+08EF0lQWpzQca8dYVOpZNUvxHDfpaQeO39ExCo6xRKvEX8p6bVpDFmFMWYd3ItoQmMQ3B/Ip+l3CBC9j8nBQ3MWJSWC0pTvM5fe40Oj4wktqp7AYRSzkrJYEOHMGYcIOIGVIYKD15dNNllNJfYC0fx/tsdZGRLduJbu85Zh+ySIN6ecjDnhxqEhP9BoTLaEOxjjAVnAeDCcLQU9US3CQZJOucEvV4mtK6peIB96GrVI42oMG3uuyAG+FJq0g9WhyA3gSQPHnLTJCn0nfh5p5qShS+/2xPAqEOxAp0pxTxOJN/omNae3Pn77ZYVEHg540auE9e4ciPhAJpg3fjO8njPDOmRjyN+Jx3JHH/TSgowBOklbqLpc7i5IXPuHFH/jI1Z2fm/g4sWsnAGM4I039gfed5AaLYJgbQ9ISPFZtQyxUhYyPq/mXCzZoD+qA2AoTXdr9E= Key for Instances in Oracle Cloud"
}

variable "ip_address" {
  type = string
  default = null
}

variable "subnet_id" {
  type = string
}

variable "network_id" {
  type = string
}

variable "vpn_address_name" {
  type = string
  default = "vpn-ip-address"
}