output "service_account_email" {
  description = "Created Service Account email"
  value       = google_service_account.runner.email
}

output "bucket_name" {
  description = "Cloud Storage bucket name"
  value       = google_storage_bucket.sandbox.name
}

output "bucket_url" {
  description = "Cloud Storage bucket URL"
  value       = google_storage_bucket.sandbox.url
}

output "cloud_run_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.sandbox.uri
}

output "cloud_run_service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_v2_service.sandbox.name
}
