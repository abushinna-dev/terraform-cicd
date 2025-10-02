tenants = {
  tenant1 = {
    cidr_block    = "10.0.1.0/24"
    region        = "us-central1"
    zone          = "us-central1-a"
    machine_type  = "e2-medium"
  }
  tenant2 = {
    cidr_block    = "10.0.2.0/24"
    region        = "us-central1"
    zone          = "us-central1-b"
    machine_type  = "e2-medium"
  }
}

project = "tmam-practical" # project
region  = "us-central1"    # default region
zone    = "us-central1-a"  # default zone
