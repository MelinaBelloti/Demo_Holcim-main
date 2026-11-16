gcloud services enable cloudresourcemanager.googleapis.com bigquery.googleapis.com


bq query --use_legacy_sql=false 'select * from `lab01_dataset.popular_ny_names` limit 10;'