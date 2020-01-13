output "vpc_self_link" {
  value = google_compute_network.vpc.self_link
}

output "vpc_subnet_self_link" {
  value = google_compute_subnetwork.subnet.self_link
}

output "subnet_cidr_range" {
  value = google_compute_subnetwork.subnet.ip_cidr_range
}

output "cluster_subnet_range" {
  value = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
}

output "services_subnet_range" {
  value = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
}