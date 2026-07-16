# Platform skeleton (INFRA-010, OPS §1/§3): every component of the OPS §1.1
# topology declared as code — projects wire these up per env via
# ../../environments/<env>. Skeleton = real resources with production shapes;
# feature tasks extend (never replace) these declarations.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.8"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.8"
    }
  }
}

locals {
  services = ["api", "sync-worker", "notif-worker", "jobs"]
  # Pub/Sub topology (OPS §1.2 / BA §12): four topics, each with a DLQ.
  topics  = ["sync.jobs.interactive", "sync.jobs.background", "sync.events", "notif.dispatch"]
  secrets = ["fcm-service-account", "jwt-signing-keys", "log-hash-key"]
  apis = [
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "pubsub.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "firebase.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each           = toset(local.apis)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# ── Firebase (FCM per env; APNs .p8 upload is a console runbook step) ────────
resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id

  depends_on = [google_project_service.apis]
}

# ── Networking: custom VPC, private data tier, static-IP NAT (OPS §1.2) ─────
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "nycu-os-${var.env}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  project       = var.project_id
  name          = "main"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.0.0/20"
}

resource "google_vpc_access_connector" "serverless" {
  project       = var.project_id
  name          = "run-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"
}

# Static egress IP so NYCU IT can allowlist us (OPS §1.2 — relationship
# management for the existential upstream).
resource "google_compute_address" "portal_egress" {
  project = var.project_id
  name    = "portal-egress"
  region  = var.region
}

resource "google_compute_router" "egress" {
  project = var.project_id
  name    = "egress"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "egress" {
  project                            = var.project_id
  name                               = "egress-nat"
  region                             = var.region
  router                             = google_compute_router.egress.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.portal_egress.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Private services access for Cloud SQL / Memorystore private IPs.
resource "google_compute_global_address" "psa_range" {
  project       = var.project_id
  name          = "psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "psa" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa_range.name]
}

# ── Data tier (OPS §1.2): Cloud SQL PG16 HA + Memorystore Redis HA ──────────
resource "google_sql_database_instance" "pg" {
  project          = var.project_id
  name             = "nycu-os-${var.env}"
  region           = var.region
  database_version = "POSTGRES_16"

  settings {
    tier              = var.sql_tier
    availability_type = "REGIONAL"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }
  }

  depends_on = [google_service_networking_connection.psa]
}

resource "google_redis_instance" "cache" {
  project            = var.project_id
  name               = "nycu-os-${var.env}"
  region             = var.region
  tier               = "STANDARD_HA"
  memory_size_gb     = var.redis_memory_gb
  redis_version      = "REDIS_7_2"
  authorized_network = google_compute_network.vpc.id
}

# ── Async: Pub/Sub topics + DLQs, dead-letter after 5 deliveries ────────────
resource "google_pubsub_topic" "main" {
  for_each = toset(local.topics)
  project  = var.project_id
  name     = each.value
}

resource "google_pubsub_topic" "dlq" {
  for_each = toset(local.topics)
  project  = var.project_id
  name     = "${each.value}.dlq"
}

resource "google_pubsub_subscription" "main" {
  for_each = toset(local.topics)
  project  = var.project_id
  name     = "${each.value}.sub"
  topic    = google_pubsub_topic.main[each.value].id

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dlq[each.value].id
    max_delivery_attempts = 5
  }
}

# ── Crypto & secrets (OPS §1.2 / §8): KMS envelope key + Secret Manager ─────
resource "google_kms_key_ring" "main" {
  project  = var.project_id
  name     = "nycu-os-${var.env}"
  location = var.region
}

resource "google_kms_crypto_key" "portal_cookies" {
  name            = "portal-cookies"
  key_ring        = google_kms_key_ring.main.id
  rotation_period = "7776000s" # 90d (BIS §7.3)
}

resource "google_secret_manager_secret" "secrets" {
  for_each  = toset(local.secrets)
  project   = var.project_id
  secret_id = each.value

  replication {
    auto {}
  }
}

# ── Compute: one image, four Cloud Run services (BIS §1.2/§10.1) ────────────
resource "google_cloud_run_v2_service" "services" {
  for_each = toset(local.services)
  project  = var.project_id
  name     = each.value
  location = var.region

  template {
    scaling {
      min_instance_count = var.run_scaling[each.value].min
      max_instance_count = var.run_scaling[each.value].max
    }
    vpc_access {
      connector = google_vpc_access_connector.serverless.id
      egress    = "ALL_TRAFFIC"
    }
    containers {
      image = var.image
      env {
        name  = "APP_PROFILE"
        value = each.value == "api" ? "api" : each.value
      }
    }
  }
}

# ── Edge: Global HTTPS LB + Cloud Armor in front of the api service ─────────
resource "google_compute_region_network_endpoint_group" "api" {
  project               = var.project_id
  name                  = "api-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.services["api"].name
  }
}

resource "google_compute_security_policy" "edge" {
  project = var.project_id
  name    = "edge-policy"

  # /internal/* is OIDC-only and blocked from the public edge (OPS §1.2).
  rule {
    action   = "deny(403)"
    priority = 1000
    match {
      expr {
        expression = "request.path.startsWith('/internal/')"
      }
    }
    description = "internal surface is never public"
  }

  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default allow"
  }
}

resource "google_compute_backend_service" "api" {
  project         = var.project_id
  name            = "api-backend"
  protocol        = "HTTPS"
  security_policy = google_compute_security_policy.edge.id

  backend {
    group = google_compute_region_network_endpoint_group.api.id
  }
}

resource "google_compute_url_map" "main" {
  project         = var.project_id
  name            = "api-lb"
  default_service = google_compute_backend_service.api.id
}

resource "google_compute_managed_ssl_certificate" "api" {
  project = var.project_id
  name    = "api-cert"

  managed {
    domains = ["api-${var.env}.nycu-os.app"]
  }
}

resource "google_compute_target_https_proxy" "api" {
  project          = var.project_id
  name             = "api-proxy"
  url_map          = google_compute_url_map.main.id
  ssl_certificates = [google_compute_managed_ssl_certificate.api.id]
}

resource "google_compute_global_address" "lb" {
  project = var.project_id
  name    = "api-lb-ip"
}

resource "google_compute_global_forwarding_rule" "https" {
  project    = var.project_id
  name       = "api-https"
  target     = google_compute_target_https_proxy.api.id
  ip_address = google_compute_global_address.lb.id
  port_range = "443"
}

output "portal_egress_ip" {
  description = "Static NAT IP for the NYCU allowlist request"
  value       = google_compute_address.portal_egress.address
}

output "lb_ip" {
  value = google_compute_global_address.lb.address
}
