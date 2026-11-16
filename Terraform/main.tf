resource "google_bigquery_dataset" "dataset" {
  dataset_id    = var.dataset_id
  friendly_name = "Lab 01 Dataset"
  description   = "Dataset creado para el Laboratorio 1 del curso de BigQuery"
  location      = "US"

  default_table_expiration_ms = 3600000

  labels = {
    env = "dev"
  }
}