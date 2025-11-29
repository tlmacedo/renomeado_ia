import os

from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "renomeador_ia.settings.dev")

app = Celery("renomeador_ia")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()
