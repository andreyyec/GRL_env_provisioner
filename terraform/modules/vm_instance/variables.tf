variable "name" {
  type = string
}

variable "project" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "zone" {
  type = string
}

variable "subnet" {
  type = string
}

variable "image" {
  type    = string
  default = "ubuntu-os-cloud/ubuntu-1804-lts"
}
variable "enable_external_ip" {
  type    = bool
  default = "false"
}
variable "boot_disk_size" {
  type    = string
  default = "10"
}
variable "can_ip_forward" {
  type    = bool
  default = "true"
}
variable "metadata_startup_script" {
  type    = string
  default = null
}
variable "tags" {
  type    = list(string)
  default = null
}
variable "scopes" {
  type    = list(string)
  default = null
}
variable "network" {
  type = string
}
