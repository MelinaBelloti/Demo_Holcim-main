
# ==========================================
# Outputs - Proyecto Holcim
# ==========================================

output "holcim_bucket_name" {
  value       = google_storage_bucket.holcim_raw.name
  description = "Nombre del bucket de almacenamiento Holcim"
}

output "bronze_dataset_id" {
  value       = google_bigquery_dataset.bronze.dataset_id
  description = "ID del dataset Bronze"
}

output "silver_dataset_id" {
  value       = google_bigquery_dataset.silver.dataset_id
  description = "ID del dataset Silver"
}

output "gold_dataset_id" {
  value       = google_bigquery_dataset.gold.dataset_id
  description = "ID del dataset Gold"
}
 