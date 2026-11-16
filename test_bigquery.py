
from google.cloud import bigquery

PROJECT_ID = "proyecto-demo-514900"

client = bigquery.Client(project=PROJECT_ID)

query = """
SELECT
    CURRENT_DATE() AS fecha_actual,
    CURRENT_TIMESTAMP() AS fecha_hora,
    'Hello from BigQuery!' AS mensaje
"""

job = client.query(
    query,
    location="US",
    job_config=bigquery.QueryJobConfig(
        dry_run=False,
        use_query_cache=True,
        maximum_bytes_billed=1_000_000
    )
)

results = job.result()

for row in results:
    print("Fecha:", row.fecha_actual)
    print("Timestamp:", row.fecha_hora)
    print("Mensaje:", row.mensaje)

