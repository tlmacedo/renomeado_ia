#!/usr/bin/env bash
set -euo pipefail

mkdir -p scripts

echo "=> Gerando Dockerfile..."
cat <<'DOCKER' > Dockerfile
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
DOCKER

echo "=> Gerando docker-compose.yml (prod)..."
cat <<'YML' > docker-compose.yml
version: "3.9"

services:
  db:
    image: postgres:15
    container_name: renomeador_db
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-renomeador}
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
    ports:
      - "5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-renomeador}"]
      interval: 5s
      timeout: 5s
      retries: 10

  redis:
    image: redis:7
    container_name: renomeador_redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 10

  web:
    build: .
    container_name: renomeador_web
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    env_file:
      - .env.docker
    environment:
      DJANGO_SETTINGS_MODULE: renomeador_ia.settings.base
      DEBUG: "0"
      ALLOWED_HOSTS: "*"
      POSTGRES_HOST: db
      POSTGRES_PORT: "5432"
      REDIS_URL: redis://redis:6379/0
      COLLECTSTATIC: "1"
    command: ["/app/scripts/entrypoint.sh", "gunicorn", "renomeador_ia.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]
    ports:
      - "8000:8000"
    volumes:
      - staticfiles:/app/staticfiles
      - media:/app/media

  celery:
    build: .
    container_name: renomeador_celery
    depends_on:
      web:
        condition: service_started
    env_file:
      - .env.docker
    environment:
      DJANGO_SETTINGS_MODULE: renomeador_ia.settings.base
      DEBUG: "0"
      POSTGRES_HOST: db
      POSTGRES_PORT: "5432"
      REDIS_URL: redis://redis:6379/0
    command: ["/app/scripts/celery_entrypoint.sh", "celery", "-A", "renomeador_ia.celery:app", "worker", "-l", "info"]
    volumes:
      - media:/app/media

  flower:
    image: mher/flower:1.2.0
    container_name: renomeador_flower
    depends_on:
      - redis
    environment:
      FLOWER_PORT: "5555"
      CELERY_BROKER_URL: redis://redis:6379/0
      CELERY_RESULT_BACKEND: redis://redis:6379/0
    ports:
      - "5555:5555"

volumes:
  db_data:
  redis_data:
  staticfiles:
  media:
YML

echo "=> Gerando docker-compose.dev.yml (dev com hot-reload)..."
cat <<'YML' > docker-compose.dev.yml
version: "3.9"

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: renomeador
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports: ["5432:5432"]
    volumes:
      - db_data:/var/lib/postgresql/data

  redis:
    image: redis:7
    ports: ["6379:6379"]
    volumes:
      - redis_data:/data

  web:
    build: .
    env_file:
      - .env.docker
    environment:
      DJANGO_SETTINGS_MODULE: renomeador_ia.settings.base
      DEBUG: "1"
      ALLOWED_HOSTS: "*"
      POSTGRES_HOST: db
      POSTGRES_PORT: "5432"
      REDIS_URL: redis://redis:6379/0
      COLLECTSTATIC: "0"
    command: ["/app/scripts/entrypoint.sh", "python", "manage.py", "runserver", "0.0.0.0:8000"]
    ports: ["8000:8000"]
    volumes:
      - ./:/app:cached
      - staticfiles:/app/staticfiles
      - media:/app/media

  celery:
    build: .
    env_file:
      - .env.docker
    environment:
      DJANGO_SETTINGS_MODULE: renomeador_ia.settings.base
      DEBUG: "1"
      POSTGRES_HOST: db
      POSTGRES_PORT: "5432"
      REDIS_URL: redis://redis:6379/0
    command: ["/app/scripts/celery_entrypoint.sh", "celery", "-A", "renomeador_ia.celery:app", "worker", "-l", "info"]
    volumes:
      - ./:/app:cached
      - media:/app/media

  flower:
    image: mher/flower:1.2.0
    environment:
      FLOWER_PORT: "5555"
      CELERY_BROKER_URL: redis://redis:6379/0
      CELERY_RESULT_BACKEND: redis://redis:6379/0
    ports: ["5555:5555"]

volumes:
  db_data:
  redis_data:
  staticfiles:
  media:
YML

echo "=> Gerando .dockerignore..."
cat <<'IGN' > .dockerignore
__pycache__/
*.pyc
*.pyo
*.pyd
*.sqlite3
.env
.venv/
.envrc
*.log
node_modules/
dist/
build/
media/uploads/
staticfiles/
.git/
.gitignore
IGN

echo "=> Gerando scripts/entrypoint.sh..."
cat <<'SH' > scripts/entrypoint.sh
#!/usr/bin/env bash
set -euo pipefail

export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE:-renomeador_ia.settings.base}"

echo "Waiting for Postgres ${POSTGRES_HOST:-localhost}:${POSTGRES_PORT:-5432}..."
python - <<'PY'
import os, time, sys
import psycopg2
host = os.environ.get("POSTGRES_HOST", "localhost")
port = int(os.environ.get("POSTGRES_PORT", "5432"))
db = os.environ.get("POSTGRES_DB", "renomeador")
user = os.environ.get("POSTGRES_USER", "postgres")
pwd = os.environ.get("POSTGRES_PASSWORD", "postgres")
for i in range(60):
    try:
        psycopg2.connect(host=host, port=port, dbname=db, user=user, password=pwd).close()
        sys.exit(0)
    except Exception as e:
        time.sleep(1)
print("Postgres não respondeu a tempo", file=sys.stderr)
sys.exit(1)
PY

python manage.py migrate --noinput

if [ "${COLLECTSTATIC:-1}" = "1" ]; then
  python manage.py collectstatic --noinput || true
fi

exec "$@"
SH

echo "=> Gerando scripts/celery_entrypoint.sh..."
cat <<'SH' > scripts/celery_entrypoint.sh
#!/usr/bin/env bash
set -euo pipefail

export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE:-renomeador_ia.settings.base}"

echo "Aguardando Postgres para Celery..."
python - <<'PY'
import os, time, sys
import psycopg2
host = os.environ.get("POSTGRES_HOST", "localhost")
port = int(os.environ.get("POSTGRES_PORT", "5432"))
db = os.environ.get("POSTGRES_DB", "renomeador")
user = os.environ.get("POSTGRES_USER", "postgres")
pwd = os.environ.get("POSTGRES_PASSWORD", "postgres")
for i in range(60):
    try:
        psycopg2.connect(host=host, port=port, dbname=db, user=user, password=pwd).close()
        sys.exit(0)
    except Exception:
        time.sleep(1)
print("Postgres não respondeu a tempo", file=sys.stderr)
sys.exit(1)
PY

exec "$@"
SH

chmod +x scripts/entrypoint.sh scripts/celery_entrypoint.sh

# Requirements padrão (sobrescreve)
echo "=> Gerando requirements.txt..."
cat <<'REQ' > requirements.txt
Django>=4.2
djangorestframework
psycopg2-binary
python-decouple
Pillow
python-magic
celery>=5.3
redis>=4.5
gunicorn
REQ

# .env.docker com defaults seguros
echo "=> Gerando .env.docker..."
cat <<'ENV' > .env.docker
# Django
SECRET_KEY=dev-secret-key
DEBUG=0
ALLOWED_HOSTS=*
DJANGO_SETTINGS_MODULE=renomeador_ia.settings.base

# Database
POSTGRES_DB=renomeador
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=db
POSTGRES_PORT=5432

# Redis / Celery
REDIS_URL=redis://redis:6379/0
ENV

echo "=> Docker scaffolding criado com sucesso."
echo
echo "Modo produção-like:"
echo "  docker compose up -d --build"
echo "  App: http://localhost:8000"
echo "  Flower: http://localhost:5555"
echo
echo "Modo desenvolvimento (hot-reload):"
echo "  docker compose -f docker-compose.dev.yml up --build"
echo
echo "Dicas:"
echo "- Ajuste .env.docker conforme necessário (DEBUG=1 para mais verbosidade)."
echo "- Volumes nomeados: db_data, redis_data, staticfiles, media."
echo "- Para logs do worker: docker logs -f renomeador_celery"
