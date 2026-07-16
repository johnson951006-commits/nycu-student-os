# nycu-os-staging (OPS §2): pre-prod mirror — real infra shapes, synthetic
# Portal account only, 100k-seed load tests run here.
terraform {
  required_version = ">= 1.9"

  backend "gcs" {
    bucket = "nycu-os-tf-state-staging"
    prefix = "platform"
  }
}

provider "google" {
  project = "nycu-os-staging"
  region  = "asia-east1"
}

provider "google-beta" {
  project = "nycu-os-staging"
  region  = "asia-east1"
}

module "platform" {
  source = "../../modules/platform"

  project_id = "nycu-os-staging"
  env        = "staging"
  image      = "asia-east1-docker.pkg.dev/nycu-os-staging/app/backend:latest"

  # Mirrors prod shapes at reduced scale so load results extrapolate.
  run_scaling = {
    api          = { min = 1, max = 20 }
    sync-worker  = { min = 1, max = 15 }
    notif-worker = { min = 1, max = 5 }
    jobs         = { min = 0, max = 1 }
  }
  sql_tier        = "db-custom-2-7680"
  redis_memory_gb = 1
}
