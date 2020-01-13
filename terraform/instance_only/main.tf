locals {
  zones = [
    "${var.region}-a",
    "${var.region}-b",
    "${var.region}-c",
  ]
  default_authorized_networks = [
    {
      cidr_block   = module.networking.subnet_cidr_range
      display_name = "subnet-range"
    },
  ]
  subnet = {
    range               = "10.2.0.0/16",
    cluster_range_name  = "cluster"
    cluster_range       = "172.18.0.0/20",
    services_range_name = "services"
    services_range      = "172.18.32.0/20",
  }
  startup-script = file("${path.module}/../../scripts/install_application.sh")
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "networking" {
  source = "../modules/network"
  project_id = var.project_id
  region = var.region
  name = var.name
  subnets = local.subnet
  allow_incoming_traffic_sources = ["0.0.0.0/0"]
}

module "instance" {
  source       = "../modules/vm_instance"
  project      = var.project_id
  name         = "${var.name}-instance-default"
  network      = module.networking.vpc_self_link
  subnet       = module.networking.vpc_subnet_self_link
  enable_external_ip = true
  machine_type = var.gke_machine_type

  tags = [
    "dev"
  ]

  scopes = [
    "monitoring-write",
    "logging-write",
    "compute-rw"
  ]

  zone                    = "${var.region}-a"
  metadata_startup_script = local.startup-script
}
