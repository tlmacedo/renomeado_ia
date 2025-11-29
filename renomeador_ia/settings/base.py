from pathlib import Path

from decouple import config, Csv

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = config("SECRET_KEY", default="dev-secret-key")
DEBUG = config("DEBUG", default=True, cast=bool)

# Segurança/Proxy
ALLOWED_HOSTS = config("ALLOWED_HOSTS", default="localhost,127.0.0.1", cast=Csv())
CSRF_TRUSTED_ORIGINS = config(
    "CSRF_TRUSTED_ORIGINS",
    default="http://localhost,http://localhost:8000,http://localhost:8080,http://127.0.0.1,http://127.0.0.1:8000,http://127.0.0.1:8080",
    cast=Csv()
)
USE_X_FORWARDED_HOST = True  # útil atrás de proxy/Nginx

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
