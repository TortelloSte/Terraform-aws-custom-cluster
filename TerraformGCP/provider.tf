provider "google" {
  project = "devops-test"
  region  = "europe-west"
}

terraform {
  backend "gcs" {
    bucket = "tortello-tf-state-staging"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.2.0"
    }
  }
}