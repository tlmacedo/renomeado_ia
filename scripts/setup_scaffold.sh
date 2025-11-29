#!/usr/bin/env bash
set -euo pipefail

echo "=> Preparando estrutura de diretórios..."
mkdir -p \
  renomeador_ia/settings \
  infrastructure/db/models \
  infrastructure/db/repositories \
  infrastructure/config \
  infrastructure/tasks \
  presentation/web/templates \
  presentation/web/static/css \
  presentation/web/static/js \
  presentation/web/views \
  presentation/api/v1/serializers \
  presentation/api/v1/views

touch infrastructure/__init__.py \
      infrastructure/db/__init__.py \
      infrastructure/db/models/__init__.py \
      infrastructure/db/repositories/__init__.py \
      infrastructure/config/__init__.py \
      infrastructure/tasks/__init__.py \
      presentation/__init__.py \
      presentation/web/__init__.py \
      presentation/api/__init__.py \
      presentation/api/v1/__init__.py \
      presentation/api/v1/serializers/__init__.py \
      presentation/api/v1/views/__init__.py

echo "=> Escrevendo renomeador_ia/celery.py..."
cat <<'PY' > renomeador_ia/celery.py
import os
from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "renomeador_ia.settings.dev")

app = Celery("renomeador_ia")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()
PY

echo "=> Escrevendo renomeador_ia/__init__.py..."
cat <<'PY' > renomeador_ia/__init__.py
try:
    from .celery import app as celery_app
    __all__ = ("celery_app",)
except Exception:
    celery_app = None
    __all__ = ()
PY

echo "=> Escrevendo renomeador_ia/settings/base.py..."
cat <<'PY' > renomeador_ia/settings/base.py
import os
from pathlib import Path
from decouple import config, Csv

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = config("SECRET_KEY", default="dev-secret-key")
DEBUG = config("DEBUG", default=True, cast=bool)
ALLOWED_HOSTS = config("ALLOWED_HOSTS", default="*", cast=Csv())

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",

    "rest_framework",

    "infrastructure.db.apps.DbConfig",
    "infrastructure.tasks.apps.TasksConfig",
    "presentation.web.apps.WebConfig",
    "presentation.api.apps.ApiConfig",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "renomeador_ia.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / ".." / "presentation" / "web" / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "renomeador_ia.wsgi.application"
ASGI_APPLICATION = "renomeador_ia.asgi.application"

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": config("POSTGRES_DB", default="renomeador"),
        "USER": config("POSTGRES_USER", default="postgres"),
        "PASSWORD": config("POSTGRES_PASSWORD", default="postgres"),
        "HOST": config("POSTGRES_HOST", default="localhost"),
        "PORT": config("POSTGRES_PORT", default="5432"),
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

LANGUAGE_CODE = "pt-br"
TIME_ZONE = "America/Manaus"
USE_I18N = True
USE_TZ = True

STATIC_URL = "/static/"
STATIC_ROOT = (BASE_DIR / ".." / "staticfiles").resolve()
STATICFILES_DIRS = [(BASE_DIR / ".." / "presentation" / "web" / "static").resolve()]

MEDIA_URL = "/media/"
MEDIA_ROOT = (BASE_DIR / ".." / "media").resolve()

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

REST_FRAMEWORK = {
    "DEFAULT_PERMISSION_CLASSES": ["rest_framework.permissions.AllowAny"],
}

CELERY_BROKER_URL = config("REDIS_URL", default="redis://localhost:6379/0")
CELERY_RESULT_BACKEND = config("REDIS_URL", default="redis://localhost:6379/0")
CELERY_TIMEZONE = TIME_ZONE
PY

echo "=> Escrevendo renomeador_ia/settings/__init__.py..."
cat <<'PY' > renomeador_ia/settings/__init__.py
from .base import *
PY

echo "=> Escrevendo renomeador_ia/settings/dev.py..."
cat <<'PY' > renomeador_ia/settings/dev.py
from .base import *

DEBUG = True
PY

echo "=> Escrevendo renomeador_ia/urls.py..."
cat <<'PY' > renomeador_ia/urls.py
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("presentation.web.urls")),
    path("api/", include("presentation.api.urls")),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
PY

echo "=> Escrevendo infrastructure/db/apps.py..."
cat <<'PY' > infrastructure/db/apps.py
from django.apps import AppConfig

class DbConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.db"
    label = "infrastructure_db"
PY

echo "=> Escrevendo infrastructure/tasks/apps.py..."
cat <<'PY' > infrastructure/tasks/apps.py
from django.apps import AppConfig

class TasksConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.tasks"
    label = "infrastructure_tasks"
PY

echo "=> Escrevendo infrastructure/tasks/tasks.py..."
cat <<'PY' > infrastructure/tasks/tasks.py
from celery import shared_task
from infrastructure.config.providers import container

@shared_task(name="tasks.generate_suggestions")
def generate_suggestions(arquivo_id: int):
    uc = container.gerar_sugestoes_uc()
    return uc.execute(arquivo_id)
PY

echo "=> Escrevendo infrastructure/db/models/arquivo.py..."
cat <<'PY' > infrastructure/db/models/arquivo.py
from django.db import models

class ArquivoModel(models.Model):
    nome_original = models.CharField(max_length=255)
    nome_sugerido = models.CharField(max_length=255, null=True, blank=True)
    nome_final = models.CharField(max_length=255, null=True, blank=True)
    tipo_arquivo = models.CharField(max_length=50)
    tamanho = models.BigIntegerField()
    data_upload = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, default="pendente")

    class Meta:
        db_table = "arquivo"
        ordering = ["-id"]

    def __str__(self) -> str:
        return self.nome_final or self.nome_sugerido or self.nome_original
PY

echo "=> Atualizando infrastructure/db/models/__init__.py..."
cat <<'PY' > infrastructure/db/models/__init__.py
from .arquivo import ArquivoModel
PY

echo "=> Escrevendo infrastructure/db/mappers.py..."
cat <<'PY' > infrastructure/db/mappers.py
from core.entities.arquivo import Arquivo
from .models.arquivo import ArquivoModel

def to_entity(m: ArquivoModel) -> Arquivo:
    return Arquivo(
        id=m.id,
        nome_original=m.nome_original,
        nome_sugerido=m.nome_sugerido,
        nome_final=m.nome_final,
        tipo_arquivo=m.tipo_arquivo,
        tamanho=m.tamanho,
        data_upload=m.data_upload,
        status=m.status,
    )
PY

echo "=> Escrevendo infrastructure/db/repositories/arquivo_repo_django.py..."
cat <<'PY' > infrastructure/db/repositories/arquivo_repo_django.py
from typing import Iterable, Optional
from core.entities.arquivo import Arquivo
from core.repositories.arquivo_repo import ArquivoRepository
from infrastructure.db.models.arquivo import ArquivoModel
from infrastructure.db.mappers import to_entity

class ArquivoRepositoryDjango(ArquivoRepository):
    def add(self, arquivo: Arquivo) -> Arquivo:
        m = ArquivoModel.objects.create(
            nome_original=arquivo.nome_original,
            nome_sugerido=arquivo.nome_sugerido,
            nome_final=arquivo.nome_final,
            tipo_arquivo=arquivo.tipo_arquivo,
            tamanho=arquivo.tamanho,
            status=arquivo.status,
        )
        return to_entity(m)

    def get(self, arquivo_id: int) -> Arquivo:
        m = ArquivoModel.objects.get(id=arquivo_id)
        return to_entity(m)

    def update(self, arquivo: Arquivo) -> Arquivo:
        m = ArquivoModel.objects.get(id=arquivo.id)
        m.nome_original = arquivo.nome_original
        m.nome_sugerido = arquivo.nome_sugerido
        m.nome_final = arquivo.nome_final
        m.tipo_arquivo = arquivo.tipo_arquivo
        m.tamanho = arquivo.tamanho
        m.status = arquivo.status
        m.save()
        return to_entity(m)

    def list(self, status: Optional[str] = None) -> Iterable[Arquivo]:
        qs = ArquivoModel.objects.all()
        if status:
            qs = qs.filter(status=status)
        return [to_entity(m) for m in qs]
PY

echo "=> Escrevendo infrastructure/config/providers.py..."
cat <<'PY' > infrastructure/config/providers.py
from infrastructure.db.repositories.arquivo_repo_django import ArquivoRepositoryDjango
from core.services.ai_naming_service import AINamingService
from application.use_cases.gerar_sugestoes import GerarSugestoesUseCase

class Container:
    def arquivo_repo(self):
        return ArquivoRepositoryDjango()

    def ai_service(self):
        return AINamingService()

    def gerar_sugestoes_uc(self):
        return GerarSugestoesUseCase(self.arquivo_repo(), self.ai_service())

    def celery(self):
        from renomeador_ia.celery import app
        return app

container = Container()
PY

echo "=> Escrevendo presentation/web/apps.py..."
cat <<'PY' > presentation/web/apps.py
from django.apps import AppConfig

class WebConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "presentation.web"
    label = "presentation_web"
PY

echo "=> Escrevendo presentation/api/apps.py..."
cat <<'PY' > presentation/api/apps.py
from django.apps import AppConfig

class ApiConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "presentation.api"
    label = "presentation_api"
PY

echo "=> Escrevendo presentation/web/forms.py..."
cat <<'PY' > presentation/web/forms.py
from django import forms

class UploadForm(forms.Form):
    arquivo = forms.FileField()
PY

echo "=> Escrevendo presentation/web/views/arquivo.py..."
cat <<'PY' > presentation/web/views/arquivo.py
from django.views import View
from django.shortcuts import render, redirect
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from infrastructure.db.models.arquivo import ArquivoModel
from infrastructure.config.providers import container
from presentation.web import forms

class HomeView(View):
    def get(self, request):
        return render(request, "home.html")

class UploadView(View):
    def get(self, request):
        return render(request, "upload.html", {"form": forms.UploadForm()})

    def post(self, request):
        form = forms.UploadForm(request.POST, request.FILES)
        if not form.is_valid():
            return render(request, "upload.html", {"form": form})

        f = form.cleaned_data["arquivo"]
        path = default_storage.save(f"uploads/{f.name}", ContentFile(f.read()))
        m = ArquivoModel.objects.create(
            nome_original=f.name,
            tipo_arquivo=f.content_type or "desconhecido",
            tamanho=f.size,
            status="pendente",
        )
        container.celery().send_task("tasks.generate_suggestions", args=[m.id])
        return redirect("lista_arquivos")

class ListaArquivosView(View):
    def get(self, request):
        arquivos = ArquivoModel.objects.all()
        return render(request, "lista_arquivos.html", {"arquivos": arquivos})
PY

echo "=> Escrevendo presentation/web/urls.py..."
cat <<'PY' > presentation/web/urls.py
from django.urls import path
from .views.arquivo import HomeView, UploadView, ListaArquivosView

urlpatterns = [
    path("", HomeView.as_view(), name="home"),
    path("upload/", UploadView.as_view(), name="upload"),
    path("arquivos/", ListaArquivosView.as_view(), name="lista_arquivos"),
]
PY

echo "=> Escrevendo templates base.html..."
cat <<'PY' > presentation/web/templates/base.html
<!doctype html>
<html lang="pt-br">
  <head>
    <meta charset="utf-8" />
    <title>Renomeador IA</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
  </head>
  <body>
    <header><h1>Renomeador IA</h1></header>
    <nav><a href="/">Home</a> | <a href="/upload/">Upload</a> | <a href="/arquivos/">Arquivos</a></nav>
    <main>{% block content %}{% endblock %}</main>
  </body>
</html>
PY

echo "=> Escrevendo templates home.html..."
cat <<'PY' > presentation/web/templates/home.html
{% extends "base.html" %}
{% block content %}
<p>Bem-vindo!</p>
{% endblock %}
PY

echo "=> Escrevendo templates upload.html..."
cat <<'PY' > presentation/web/templates/upload.html
{% extends "base.html" %}
{% block content %}
<h2>Upload</h2>
<form method="post" enctype="multipart/form-data">
  {% csrf_token %}
  {{ form.as_p }}
  <button type="submit">Enviar</button>
</form>
{% endblock %}
PY

echo "=> Escrevendo templates lista_arquivos.html..."
cat <<'PY' > presentation/web/templates/lista_arquivos.html
{% extends "base.html" %}
{% block content %}
<h2>Arquivos</h2>
<table>
  <thead><tr><th>ID</th><th>Nome</th><th>Sugerido</th><th>Status</th></tr></thead>
  <tbody>
    {% for a in arquivos %}
      <tr>
        <td>{{ a.id }}</td>
        <td>{{ a.nome_original }}</td>
        <td>{{ a.nome_sugerido|default:"-" }}</td>
        <td>{{ a.status }}</td>
      </tr>
    {% endfor %}
  </tbody>
</table>
{% endblock %}
PY

echo "=> Escrevendo presentation/api/urls.py..."
cat <<'PY' > presentation/api/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from presentation.api.v1.views.arquivo_views import ArquivoViewSet

router = DefaultRouter()
router.register("arquivos", ArquivoViewSet, basename="arquivo")

urlpatterns = [
    path("v1/", include(router.urls)),
]
PY

echo "=> Escrevendo presentation/api/v1/serializers/arquivo_serializer.py..."
cat <<'PY' > presentation/api/v1/serializers/arquivo_serializer.py
from rest_framework import serializers
from infrastructure.db.models.arquivo import ArquivoModel

class ArquivoSerializer(serializers.ModelSerializer):
    class Meta:
        model = ArquivoModel
        fields = ["id", "nome_original", "nome_sugerido", "nome_final", "tipo_arquivo", "tamanho", "data_upload", "status"]
PY

echo "=> Escrevendo presentation/api/v1/views/arquivo_views.py..."
cat <<'PY' > presentation/api/v1/views/arquivo_views.py
from rest_framework import viewsets
from infrastructure.db.models.arquivo import ArquivoModel
from presentation.api.v1.serializers.arquivo_serializer import ArquivoSerializer

class ArquivoViewSet(viewsets.ModelViewSet):
    queryset = ArquivoModel.objects.all()
    serializer_class = ArquivoSerializer
PY

echo "=> Criando .env.example..."
cat <<'PY' > .env.example
SECRET_KEY=dev-secret-key
DEBUG=True
ALLOWED_HOSTS=*
POSTGRES_DB=renomeador
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
REDIS_URL=redis://localhost:6379/0
PY

echo "=> Garantindo stubs de domínio (core)..."
mkdir -p core/entities core/repositories core/services
touch core/__init__.py core/entities/__init__.py core/repositories/__init__.py core/services/__init__.py

cat <<'PY' > core/entities/arquivo.py
from dataclasses import dataclass
from datetime import datetime
from typing import Optional, Literal

Status = Literal["pendente", "processando", "processado", "erro"]

@dataclass(frozen=True)
class Arquivo:
    id: Optional[int]
    nome_original: str
    nome_sugerido: Optional[str]
    nome_final: Optional[str]
    tipo_arquivo: str
    tamanho: int
    data_upload: datetime
    status: Status = "pendente"
PY

cat <<'PY' > core/repositories/arquivo_repo.py
from typing import Protocol, Iterable, Optional
from core.entities.arquivo import Arquivo

class ArquivoRepository(Protocol):
    def add(self, arquivo: Arquivo) -> Arquivo: ...
    def get(self, arquivo_id: int) -> Arquivo: ...
    def update(self, arquivo: Arquivo) -> Arquivo: ...
    def list(self, status: Optional[str] = None) -> Iterable[Arquivo]: ...
PY

cat <<'PY' > core/services/ai_naming_service.py
from typing import List
from core.entities.arquivo import Arquivo

class AINamingService:
    def sugerir_nomes(self, arquivo: Arquivo) -> List[str]:
        base = arquivo.nome_original.rsplit(".", 1)[0]
        sugestoes = [
            f"{base}_renomeado",
            f"{arquivo.tipo_arquivo}_{arquivo.data_upload:%Y%m%d}",
        ]
        return list(dict.fromkeys(sugestoes))
PY

echo "=> Garantindo application/use_cases..."
mkdir -p application/use_cases application/dtos application/orchestrators
touch application/__init__.py application/use_cases/__init__.py application/dtos/__init__.py application/orchestrators/__init__.py

cat <<'PY' > application/use_cases/gerar_sugestoes.py
from typing import List
from core.repositories.arquivo_repo import ArquivoRepository
from core.services.ai_naming_service import AINamingService

class GerarSugestoesUseCase:
    def __init__(self, repo: ArquivoRepository, ai: AINamingService):
        self.repo = repo
        self.ai = ai

    def execute(self, arquivo_id: int) -> List[str]:
        arquivo = self.repo.get(arquivo_id)
        sugestoes = self.ai.sugerir_nomes(arquivo)
        return sugestoes or [f"{arquivo.tipo_arquivo}_{arquivo.data_upload:%Y%m%d}"]
PY

echo "=> Pronto!"
echo
echo "Próximos passos:"
echo "1) Crie seu .env: cp .env.example .env"
echo "2) Exporte a variável de settings: export DJANGO_SETTINGS_MODULE=renomeador_ia.settings.dev"
echo "3) Migre o banco:"
echo "   python manage.py makemigrations infrastructure_db"
echo "   python manage.py migrate"
echo "4) Suba o servidor: python manage.py runserver 0.0.0.0:8000"
echo "5) Em outro terminal, suba o Celery: celery -A renomeador_ia.celery:app worker -l info"
