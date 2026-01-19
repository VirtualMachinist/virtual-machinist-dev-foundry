terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "fsvm-foundry-tf-state"  # Create this bucket manually first
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}