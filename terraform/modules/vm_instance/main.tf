resource "google_compute_instance" "instance" {
  name           = var.name
  project        = var.project
  machine_type   = var.machine_type
  zone           = var.zone
  can_ip_forward = var.can_ip_forward

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.boot_disk_size
    }
  }

  allow_stopping_for_update = true

  dynamic "service_account" {
    for_each = var.scopes != null ? [""] : []
    content {
      scopes = var.scopes
    }
  }


  dynamic "network_interface" {
    for_each = var.enable_external_ip ? [""] : []
    content {
      network            = var.network
      subnetwork         = var.subnet
      subnetwork_project = var.project

      access_config {
        // Ephemeral IP
      }
    }
  }
  dynamic "network_interface" {
    for_each = var.enable_external_ip ? [] : [""]
    content {
      network            = var.network
      subnetwork         = var.subnet
      subnetwork_project = var.project
    }
  }
  tags = var.tags

  metadata_startup_script = var.metadata_startup_script

}
