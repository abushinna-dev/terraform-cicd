# Subnet for this tenant
resource "google_compute_subnetwork" "this" {
  name          = "${var.tenant_name}-subnet"
  ip_cidr_range = var.cidr_block
  region        = var.region
  network       = var.network
}

# Firewall that targets tenant VMs by tag
resource "google_compute_firewall" "this" {
  name    = "${var.tenant_name}-fw"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["${var.tenant_name}-web"]
}

# VM instance for tenant
resource "google_compute_instance" "this" {
  name         = "${var.tenant_name}-webserver"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.this.id
    access_config {} # ephemeral public IP
  }

  tags = ["${var.tenant_name}-web"]

  metadata = {
    ssh-keys = "gcpuser:${var.ssh_pub_key}"
  }

  labels = {
    tenant = var.tenant_name
  }

  metadata_startup_script = file("${path.module}/../startup.sh")

}
