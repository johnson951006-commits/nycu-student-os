# Platform module inputs (OPS §1/§2): one module, three env instantiations.
variable "project_id" {
  description = "GCP project (nycu-os-dev / nycu-os-staging / nycu-os-prod)"
  type        = string
}

variable "env" {
  description = "Environment name: dev | staging | prod"
  type        = string
}

variable "region" {
  description = "Primary region — asia-east1 (Taiwan; OPS §1.1)"
  type        = string
  default     = "asia-east1"
}

variable "image" {
  description = "Container image (one image, 4 services — BIS §10.2)"
  type        = string
}

variable "sql_tier" {
  description = "Cloud SQL machine tier (DB §12 sizing ladder)"
  type        = string
  default     = "db-custom-4-16384"
}

variable "redis_memory_gb" {
  type    = number
  default = 1
}

variable "run_scaling" {
  description = "Per-service min/max instances (BIS §10.1)"
  type        = map(object({ min = number, max = number }))
  default = {
    api            = { min = 2, max = 40 }
    sync-worker    = { min = 1, max = 30 }
    notif-worker   = { min = 1, max = 10 }
    jobs           = { min = 0, max = 1 }
  }
}
