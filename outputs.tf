output "tenant1_instance_ip" {
  value       = module.tenant1.instance_external_ip
  description = "External IP of tenant1 VM"
}

output "tenant2_instance_ip" {
  value       = module.tenant2.instance_external_ip
  description = "External IP of tenant2 VM"
}
