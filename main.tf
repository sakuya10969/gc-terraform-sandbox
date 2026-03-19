# -------------------------------------------------------------------
# APIs
# -------------------------------------------------------------------
locals {
  apis = [
    "run.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.apis)

  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = true
}

# -------------------------------------------------------------------
# Service Account
# -------------------------------------------------------------------
resource "google_service_account" "runner" {
  account_id   = var.service_account_id
  display_name = "Terraform Sandbox Runner"
  project      = var.project_id

  depends_on = [google_project_service.apis]
}

# -------------------------------------------------------------------
# Cloud Storage
# -------------------------------------------------------------------
resource "google_storage_bucket" "sandbox" {
  name     = var.bucket_name
  location = var.region
  project  = var.project_id

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true

  depends_on = [google_project_service.apis]
}

# Bucket-level IAM: SA に objectViewer を付与
resource "google_storage_bucket_iam_member" "runner_object_viewer" {
  bucket = google_storage_bucket.sandbox.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.runner.email}"
}

# -------------------------------------------------------------------
# Cloud Run
# -------------------------------------------------------------------
resource "google_cloud_run_v2_service" "sandbox" {
  name                = var.cloud_run_service_name
  location            = var.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      resources {
        limits = {
          cpu    = "1"
          memory = "128Mi"
        }
        cpu_idle          = true
        startup_cpu_boost = false
      }
    }

    service_account = google_service_account.runner.email
  }

  depends_on = [google_project_service.apis]
}

# Cloud Run IAM: 認証必須 (allow_unauthenticated = false の場合は付与しない)
resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  count = var.allow_unauthenticated ? 1 : 0

  project  = google_cloud_run_v2_service.sandbox.project
  location = google_cloud_run_v2_service.sandbox.location
  name     = google_cloud_run_v2_service.sandbox.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
