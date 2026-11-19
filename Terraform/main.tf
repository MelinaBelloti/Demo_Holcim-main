

# ==========================================
# 1. Habilitacion de APIs
# ==========================================

resource "google_project_service" "bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  project = var.project_id
  service = "storage.googleapis.com"

  disable_on_destroy = false
}

# ==========================================
# 2. Cloud Storage - Archivos originales
# ==========================================

resource "google_storage_bucket" "holcim_raw" {
  name     = "${var.project_id}-holcim-raw"
  location = var.region

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = {
    environment = "dev"
    project     = "holcim"
    layer       = "bronze"
  }

  depends_on = [
    google_project_service.storage
  ]
}

# ==========================================
# 3. BigQuery - Arquitectura Medallion
# ==========================================

# Capa Bronze

resource "google_bigquery_dataset" "bronze" {
  dataset_id  = "holcim_bronze"
  description = "Capa Bronze: Datos originales sin procesar"
  location    = var.bq_location

  depends_on = [
    google_project_service.bigquery
  ]
}

# Capa Silver

resource "google_bigquery_dataset" "silver" {
  dataset_id  = "holcim_silver"
  description = "Capa Silver: Datos limpios, estructurados y validados"
  location    = var.bq_location

  depends_on = [
    google_project_service.bigquery
  ]
}

# Capa Gold

resource "google_bigquery_dataset" "gold" {
  dataset_id  = "holcim_gold"
  description = "Capa Gold: Datos agregados para analitica y BI"
  location    = var.bq_location

  depends_on = [
    google_project_service.bigquery
  ]
}
