# ====================
# General Project Vars
# ====================
variable "project_id" {
  description = "GCP project ID for Foundry environment"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for zonal resources"
  type        = string
  default     = "us-central1-a"
}

# ====================
# Network Vars
# ====================
variable "vpc_name" {
  description = "Name of the Foundry VPC"
  type        = string
  default     = "foundry-vpc"
}

variable "public_cidr" {
  description = "CIDR for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_cidr" {
  description = "CIDR for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# ====================
# VM Vars
# ====================
variable "vm_name" {
  description = "Name of the Foundry VM"
  type        = string
  default     = "foundry-vm"
}

variable "vm_machine_type" {
  description = "Machine type for Foundry VM"
  type        = string
  default     = "n2-standard-4"
}

variable "vm_image" {
  description = "Boot disk image"
  type        = string
  default     = "centos-cloud/centos-stream-9"
}

# ====================
# GKE Vars
# ====================
variable "gke_cluster_name" {
  description = "Name of GKE Autopilot cluster"
  type        = string
  default     = "foundry-gke"
}

variable "gke_master_cidr" {
  description = "CIDR for GKE master (private cluster)"
  type        = string
  default     = "172.16.0.0/28"
}

# ====================
# Storage Vars
# ====================
variable "bucket_location" {
  description = "Location for GCS buckets"
  type        = string
  default     = "US"
}

variable "bucket_prefix" {
  description = "Prefix for bucket names (must be globally unique)"
  type        = string
  default     = "vm-foundry"
}