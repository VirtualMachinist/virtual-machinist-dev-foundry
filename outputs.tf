# Network
output "vpc_id" {
  description = "VPC ID"
  value       = module.foundry_network.vpc_id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = module.foundry_network.private_subnet_id
}

# VM
output "foundry_vm_name" {
  description = "Foundry VM name"
  value       = google_compute_instance.foundry_vm.name
}

output "foundry_vm_internal_ip" {
  description = "Foundry VM internal IP"
  value       = google_compute_instance.foundry_vm.network_interface[0].network_ip
}

output "foundry_vm_ssh_command" {
  description = "SSH command via IAP"
  value       = "gcloud compute ssh ${google_compute_instance.foundry_vm.name} --zone=${var.zone} --tunnel-through-iap"
}

# GKE
output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.foundry_gke.name
}

output "gke_cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.foundry_gke.endpoint
  sensitive   = true
}

output "gke_get_credentials_command" {
  description = "Command to get GKE credentials"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.foundry_gke.name} --region=${var.region}"
}

# Buckets
output "bucket_raw" {
  description = "Raw data bucket"
  value       = google_storage_bucket.raw.name
}

output "bucket_curated" {
  description = "Curated data bucket"
  value       = google_storage_bucket.curated.name
}

output "bucket_models" {
  description = "Models bucket"
  value       = google_storage_bucket.models.name
}

output "bucket_experiments" {
  description = "Experiments bucket"
  value       = google_storage_bucket.experiments.name
}