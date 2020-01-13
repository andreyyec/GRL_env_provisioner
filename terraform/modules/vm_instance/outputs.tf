output "external_ip" {
  value = google_compute_instance.instance.network_interface[*].access_config[*].nat_ip
}
output "instance_id" {
  value = google_compute_instance.instance.instance_id
}
output "internal_ip" {
  value = google_compute_instance.instance.network_interface[*].network_ip
}
