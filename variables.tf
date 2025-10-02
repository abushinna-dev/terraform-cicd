variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "ssh_pub_key" {
  description = "SSH key to login"
  type        = string
}

variable "tenants" {
  description = "A map of tenant configurations."
  type = map(object({
    cidr_block   = string
    region       = string
    zone         = string
    machine_type = string
  }))
  default = {}
}
