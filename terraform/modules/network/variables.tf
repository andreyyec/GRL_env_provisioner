variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "allow_incoming_traffic_sources" {
  type = list(string)
}

variable "subnets" {
  type = object({
    range = string,
    cluster_range_name = string,
    cluster_range = string,
    services_range_name = string,
    services_range = string
  })
}
