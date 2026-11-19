
variable "project_id" {
  type        = string
  description = "ID del proyecto de Google Cloud"
  default     = "proyecto-demo-514900"
}

variable "region" {
  type        = string
  description = "Region de los recursos de Google Cloud"
  default     = "us-central1"
}

variable "bq_location" {
  type        = string
  description = "Ubicacion de los datasets de BigQuery"
  default     = "US"
}
