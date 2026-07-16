# nycu-os-dev (OPS §2): shared integration env, ephemeral data, fixture Portal.
terraform {
  required_version = ">= 1.9"

  backend "gcs" {
    bucket = "nycu-os-tf-state-dev"
    prefix = "platform"
  }
}

provider "google" {
  project = "nycu-os-dev"
  region  = "asia-east1"
}

provider "google-beta" {
  project = "nycu-os-dev"
  region  = "asia-east1"
}

module "platform" {
  source = "../../modules/platform"

  project_id = "nycu-os-dev"
  env        = "dev"
  image      = "asia-east1-docker.pkg.dev/nycu-os-dev/app/backend:latest"

  # Dev floors everything to near-zero (OPS §9 cost posture).
  run_scaling = {
    api          = { min = 0, max = 4 }
    sync-worker  = { min = 0, max = 2 }
    notif-worker = { min = 0, max = 2 }
    jobs         = { min = 0, max = 1 }
  }
  sql_tier        = "db-custom-1-3840"
  redis_memory_gb = 1
}
