terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
  backend "gcs" {
    bucket  = "tmam-practical-state-bucket"
    prefix  = "env/prod" # path inside the bucket
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

# Shared VPC
resource "google_compute_network" "main" {
  name = "multi-tenant-network"
  auto_create_subnetworks = false
}

## Tenant modules (pass network id + settings)

module "tenant1" {
  source       = "./tenants/tenant1"
  tenant_name  = "tenant1"
  network      = google_compute_network.main.id
  cidr_block   = var.tenants["tenant1"].cidr_block
  region       = var.tenants["tenant1"].region
  zone         = var.tenants["tenant1"].zone
  machine_type = var.tenants["tenant1"].machine_type
  ssh_pub_key  = var.ssh_pub_key
}

module "tenant2" {
  source       = "./tenants/tenant2"
  tenant_name  = "tenant2"
  network      = google_compute_network.main.id
  cidr_block   = var.tenants["tenant2"].cidr_block
  region       = var.tenants["tenant2"].region
  zone         = var.tenants["tenant2"].zone
  machine_type = var.tenants["tenant2"].machine_type
  ssh_pub_key  = var.ssh_pub_key
}
