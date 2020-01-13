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

resource "google_compute_address" "cluster_external_address" {
  project      = var.project_id
  name         = var.name
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_container_cluster" "primary" {
  name       = var.name
  project    = var.project_id
  location   = var.region
  network    = module.networking.vpc_self_link
  subnetwork = module.networking.vpc_subnet_self_link

  node_locations = local.zones

  remove_default_node_pool = false
  initial_node_count       = var.node_count

  node_config {
    machine_type = "n1-standard-1"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = module.networking.cluster_subnet_range
    services_secondary_range_name = module.networking.services_subnet_range
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      iterator = block
      for_each = concat(local.default_authorized_networks, var.additional_authorized_networks)
      content {
        cidr_block   = block.value.cidr_block
        display_name = block.value.display_name
      }
    }
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_cidr
  }

  master_auth {
    username = var.cluster_user
    password = var.cluster_passwd

    client_certificate_config {
      issue_client_certificate = true
    }
  }
}

provider "kubernetes" {
  host                   = google_container_cluster.primary.endpoint
  username = var.cluster_user
  password = var.cluster_passwd
  client_key             = base64decode(google_container_cluster.primary.master_auth[0].client_key)
  client_certificate     = base64decode(google_container_cluster.primary.master_auth[0].client_certificate)
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_deployment" "deployment_grl" {
  metadata {
    name = "deployment-timeoff"
    labels = {
      name = "timeoff"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "timeoff"
      }
    }
    replicas = 2
    template {
      metadata {
        labels = {
          app = "timeoff"
        }
      }
      spec {
        container {
          name  = "timeoff"
          image = "acastro/gorilla-timeoff-management"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_lb" {
  metadata {
    name = "grl-lb-service"
    labels = {
      name = "lb-service"
    }
  }

  spec {
    external_traffic_policy = "Local"
    type                    = "LoadBalancer"
    selector                = {
      app = "timeoff"
    }
    load_balancer_ip = google_compute_address.cluster_external_address.address


    port {
      name        = "external-api"
      port        = 80
      target_port = 3000
    }
  }
}
