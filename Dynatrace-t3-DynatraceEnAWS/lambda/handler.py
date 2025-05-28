import os
import json
import urllib.request
from datetime import datetime

def lambda_handler(event, context):
    print("📦 Evento S3 recibido")

    # Leer variables de entorno
    dt_env_url = os.environ["DT_ENV_URL"]
    dt_api_token = os.environ["DT_API_TOKEN"]

    # Obtener detalles del objeto desde el evento S3
    try:
        record = event["Records"][0]
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]
    except Exception as e:
        print("❌ Error procesando evento S3:", e)
        return

    # Crear mensaje de log
    log_message = f"📤 Objeto '{key}' subido al bucket '{bucket}' desde Lambda"

    # Crear payload JSON
    log_payload = json.dumps([
        {
            "content": log_message,
            "log.source": "lambda-s3",
            "log.level": "INFO",
            "dt.source": "terraform-test",
            "bucket": bucket,
            "object.key": key,
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }
    ])

    # Enviar a Dynatrace
    req = urllib.request.Request(
        url=f"{dt_env_url}/api/v2/logs/ingest",
        data=log_payload.encode("utf-8"),
        headers={
            "Content-Type": "application/json; charset=utf-8",
            "Authorization": f"Api-Token {dt_api_token}"
        },
        method="POST"
    )

    try:
        with urllib.request.urlopen(req) as res:
            print("✅ Log enviado a Dynatrace:", res.status)
            print(res.read().decode())
    except Exception as e:
        print("❌ Error al enviar log:", e)




