
import re
import pandas as pd

from io import BytesIO
from datetime import datetime, timezone

from google.cloud import storage
from google.cloud import bigquery


# ==========================================
# 1. CONFIGURACION
# ==========================================

PROJECT_ID = "proyecto-demo-514900"
BUCKET_NAME = "proyecto-demo-514900-holcim-raw"
DATASET_ID = "holcim_bronze"

FILES = {
    "cement_plants_raw": "Raw/China cement plants.xlsx",
    "energy_statistics_raw": "Raw/Energy statistics for China cement plants.xlsx"
}


# ==========================================
# 2. NORMALIZACION DE COLUMNAS
# ==========================================

def normalize_column_name(column):

    name = str(column).strip().lower()
    name = name.replace(" ", "_")

    # Reemplazar caracteres no permitidos
    name = re.sub(r"[^a-zA-Z0-9_]", "_", name)

    # Evitar guiones bajos consecutivos
    name = re.sub(r"_+", "_", name).strip("_")

    # BigQuery no permite nombres que comiencen con numeros
    if name and name[0].isdigit():
        name = f"col_{name}"

    return name


# ==========================================
# 3. CONEXION A GOOGLE CLOUD
# ==========================================

storage_client = storage.Client(project=PROJECT_ID)
bigquery_client = bigquery.Client(project=PROJECT_ID)

bucket = storage_client.bucket(BUCKET_NAME)

print("Conexion a Google Cloud exitosa.")


# ==========================================
# 4. LECTURA Y CARGA A BRONZE
# ==========================================

for table_name, file_path in FILES.items():

    print("\n" + "=" * 50)
    print(f"Procesando archivo: {file_path}")
    print("=" * 50)

    # Descargar Excel desde Cloud Storage
    blob = bucket.blob(file_path)
    file_content = blob.download_as_bytes()

    # Leer Excel con Pandas
    df = pd.read_excel(BytesIO(file_content))

    print(f"Filas originales: {len(df)}")
    print(f"Columnas originales: {len(df.columns)}")

    # Normalizar nombres de columnas
    df.columns = [
        normalize_column_name(column)
        for column in df.columns
    ]

    # Verificar nombres duplicados después de normalizar
    if df.columns.duplicated().any():
        duplicated = df.columns[df.columns.duplicated()].tolist()
        raise ValueError(
            f"Columnas duplicadas en {file_path}: {duplicated}"
        )

    # Conservar los valores originales como texto
    df = df.astype("string")

    # Agregar metadatos de ingesta
    df["source_file"] = file_path
    df["ingestion_timestamp"] = datetime.now(timezone.utc)

    # Identificar tabla destino
    table_id = (
        f"{PROJECT_ID}.{DATASET_ID}.{table_name}"
    )

    # Configurar carga completa
    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
        autodetect=True
    )

    # Cargar DataFrame en BigQuery
    job = bigquery_client.load_table_from_dataframe(
        df,
        table_id,
        job_config=job_config
    )

    # Esperar finalizacion de la carga
    job.result()

    # Consultar informacion de la tabla
    table = bigquery_client.get_table(table_id)

    print(f"\nTabla cargada: {table_id}")
    print(f"Filas cargadas: {table.num_rows}")
    print(f"Columnas cargadas: {len(table.schema)}")

    print("\nColumnas en BigQuery:")

    for field in table.schema:
        print(f"- {field.name}: {field.field_type}")


# ==========================================
# 5. FINALIZACION
# ==========================================

print("\n" + "=" * 50)
print("Proceso de ingesta Bronze finalizado.")
print("=" * 50)
