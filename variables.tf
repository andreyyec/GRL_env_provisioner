variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
  default = "us-west1"
}

variable "cluster_user" {
  type = string
  default = ""
}

variable "cluster_passwd" {
  type = string
  default = ""
}

variable "gke_machine_type" {
  type = string
  default = "n1-standard-1"
}

variable "node_count" {
  type = number
  default = 1
}

variable "master_cidr" {
  type = string
  default = "172.19.0.0/28"
}

variable "additional_authorized_networks" {
  type = list(object({
    display_name = string
    cidr_block = string
  }))
}
