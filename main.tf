# ====================
# VPC Network (via module)
# ====================
module "foundry_network" {
  source = "github.com/VirtualMachinist/virtual-machinist-terraform-modules//modules/gcp_vpc?ref=v0.2.0"

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
  # CentOS/Fedora setup (dnf-based)
  dnf update -y
  dnf install -y dnf-plugins-core
  
  # Install Docker
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  systemctl enable docker
  systemctl start docker
  usermod -aG docker $USER
  
  # Install Python
  dnf install -y python3 python3-pip python3-virtualenv git
  pip3 install google-cloud-storage requests pandas
  
  # Install Terraform
  dnf install -y yum-utils
  yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
  dnf install -y terraform
  
  # Install kubectl
  cat <<KUBECTL_EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
KUBECTL_EOF
  dnf install -y kubectl
  
  # Install gcloud CLI
  dnf install -y google-cloud-cli
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
