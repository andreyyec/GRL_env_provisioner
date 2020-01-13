output "endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "ca_cert" {
  value = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

output "cert" {
  value = google_container_cluster.primary.master_auth.0.client_certificate
}

output "key" {
  value = google_container_cluster.primary.master_auth.0.client_key
}
output "cluster_name" {
  value = google_container_cluster.primary.name
}