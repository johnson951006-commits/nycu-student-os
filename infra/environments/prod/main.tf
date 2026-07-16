# nycu-os-prod (OPS §2): live environment — real Portal, PDPA-scope data,
# deploys only via tag + gated approval (OPS §3.2 canary flow).
terraform {
  required_version = ">= 1.9"

  backend "gcs" {
    bucket = "nycu-os-tf-state-prod"
    prefix = "platform"
  }
}

provider "google" {
  project = "nycu-os-prod"
  region  = "asia-east1"
}

provider "google-beta" {
  project = "nycu-os-prod"
  region  = "asia-east1"
}

module "platform" {
  source = "../../modules/platform"

  project_id = "nycu-os-prod"
  env        = "prod"
  image      = "asia-east1-docker.pkg.dev/nycu-os-prod/app/backend:latest"

  # BIS §10.1 production shapes (api min2/max40 · sync 1/30 · notif 1/10 · jobs 0/1).
  run_scaling = {
    api          = { min = 2, max = 40 }
    sync-worker  = { min = 1, max = 30 }
    notif-worker = { min = 1, max = 10 }
    jobs         = { min = 0, max = 1 }
  }
  sql_tier        = "db-custom-4-16384"
  redis_memory_gb = 5
}
