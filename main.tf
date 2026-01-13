# ====================
# VPC Network (via module)
# ====================
module "foundry_network" {
  source = "github.com/VirtualMachinist/virtual-machinist-terraform-modules//modules/gcp_vpc?ref=v0.1.0"

  project_id   = var.project_id
  vpc_name     = var.vpc_name
  region       = var.region
  public_cidr  = var.public_cidr
  private_cidr = var.private_cidr
}

# ====================
# Foundry VM (Private Subnet)
# ====================
resource "google_compute_instance" "foundry_vm" {
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = 100  # GB
    }
  }

  network_interface {
    subnetwork = module.foundry_network.private_subnet_id
    # No external IP - access via IAP
  }

  tags = ["allow-iap-ssh"]

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io docker-compose python3 python3-pip python3-venv git
    usermod -aG docker $USER
    
    # Install cloud CLIs
    pip3 install google-cloud-storage requests pandas
    
    # Install Terraform
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt-get update && apt-get install -y terraform
    
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }
}

# ====================
# GKE Autopilot Cluster
# ====================
resource "google_container_cluster" "foundry_gke" {
  name     = var.gke_cluster_name
  location = var.region

  enable_autopilot = true

  network    = module.foundry_network.vpc_id
  subnetwork = module.foundry_network.private_subnet_id

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false  # Allow kubectl from outside
    master_ipv4_cidr_block  = var.gke_master_cidr
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.private_cidr
      display_name = "foundry-private-subnet"
    }
  }

  deletion_protection = false  # Set true for prod
}

# ====================
# GCS Data Lake Buckets
# ====================
resource "google_storage_bucket" "raw" {
  name     = "${var.bucket_prefix}-raw"
  location = var.bucket_location

  uniform_bucket_level_access = true
  force_destroy               = true  # Set false for prod
}

resource "google_storage_bucket" "curated" {
  name     = "${var.bucket_prefix}-curated"
  location = var.bucket_location

  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket" "models" {
  name     = "${var.bucket_prefix}-models"
  location = var.bucket_location

  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket" "experiments" {
  name     = "${var.bucket_prefix}-experiments"
  location = var.bucket_location

  uniform_bucket_level_access = true
  force_destroy               = true
}