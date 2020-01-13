locals {
  zones = [
    "${var.region}-a",
    "${var.region}-b",
    "${var.region}-c",
  ]
  default_authorized_networks = [
    {
      cidr_block   = google_compute_subnetwork.subnet.ip_cidr_range
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

resource google_compute_network "vpc" {
  project                 = var.project_id
  name                    = var.name
  auto_create_subnetworks = false
}

resource google_compute_subnetwork "subnet" {
  project = var.project_id
  name    = var.name
  network = google_compute_network.vpc.self_link
  region  = var.region

  ip_cidr_range = "10.2.0.0/16"

  secondary_ip_range {
    range_name    = local.subnet.cluster_range_name
    ip_cidr_range = local.subnet.cluster_range
  }
  secondary_ip_range {
    range_name    = local.subnet.services_range_name
    ip_cidr_range = local.subnet.services_range
  }
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
  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  node_locations = local.zones

  remove_default_node_pool = false
  initial_node_count       = var.node_count

  node_config {
    machine_type = "n1-standard-1"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
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

resource "google_compute_router" "router" {
  project = var.project_id
  name    = var.name
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  project = var.project_id
  name    = var.name

  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
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
      port        = 3000
      target_port = 3000
    }
  }
}

//resource "kubernetes_ingress" "ingress_timeoff" {
//  metadata {
//    name = "timeoff-ingress"
////    annotations = {
////      "kubernetes.io/ingress.class"             = "citrix-ingress"
////      "ingress.citrix.com/insecure-termination" = "allow"
////    }
//  }
//  spec {
////    tls {
////      secret_name = "cert-key"
////    }
//    rule {
//      host = "www.acastrocr.com"
//      http {
//        path {
//          path = "/"
//          backend {
//            service_name = "grl-lb-service"
//            service_port = 3000
//          }
//        }
//      }
//    }
//  }
//}

module "instance" {
  source       = "../modules/gcp/vm_instance"
  project      = var.project_id
  name         = "${var.name}-instance-default"
  network      = google_compute_network.vpc.self_link
  subnet       = google_compute_subnetwork.subnet.self_link
  enable_external_ip = true

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
