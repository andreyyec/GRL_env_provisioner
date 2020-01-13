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
    range_name    = var.subnets.cluster_range_name
    ip_cidr_range = var.subnets.cluster_range
  }

  secondary_ip_range {
    range_name    = var.subnets.services_range_name
    ip_cidr_range = var.subnets.services_range
  }
}

resource "google_compute_firewall" "allow_public_incoming_traffic_firewall_rule" {
  name        = "${google_compute_network.vpc.name}-allow-incoming-public-web-traffic"
  project     = var.project_id
  description = "Global SSH allow"

  network = google_compute_network.vpc.self_link

  source_ranges = var.allow_incoming_traffic_sources

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports = [
      80, 443, 22, 3000
    ]
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