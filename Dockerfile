# Imagem base
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_VIRTUALENVS_CREATE=false

# Dependências de sistema para Pillow/psycopg2/python-magic
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc \
    libpq-dev \
    libmagic1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Requisitos
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Código
COPY . /app

# Compila bytecode (opcional)
RUN python -m compileall -q /app || true

# Entrypoints
RUN chmod +x /app/scripts/entrypoint.sh /app/scripts/celery_entrypoint.sh

EXPOSE 8000

# Por padrão, apenas abre shell; compose define o CMD/entrypoint
CMD ["/bin/bash"]
