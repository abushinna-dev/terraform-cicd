variable "network" {
  description = "Shared VPC network id"
  type        = string
}

variable "tenant_name" {
  description = "Tenant identifier"
  type        = string
}

variable "cidr_block" {
  description = "CIDR for tenant subnet"
  type        = string
}

variable "region" {
  description = "Region to create subnet in"
  type        = string
}

variable "zone" {
  description = "Zone for the VM"
  type        = string
}

variable "ssh_pub_key" {
  description = "Public SSH key string"
  type        = string
}

variable "machine_type" {
  description = "The machine type for the tenant's VM."
  type        = string
}