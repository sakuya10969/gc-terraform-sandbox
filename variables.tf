variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-northeast1"
}

variable "bucket_name" {
  description = "Cloud Storage bucket name (must be globally unique)"
  type        = string
  default     = "tf-sandbox-gcs"
}

variable "cloud_run_service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "tf-sandbox-run"
}

variable "service_account_id" {
  description = "Service Account ID"
  type        = string
  default     = "tf-sandbox-runner"
}

variable "allow_unauthenticated" {
  description = "Whether to allow unauthenticated access to Cloud Run"
  type        = bool
  default     = false
}
