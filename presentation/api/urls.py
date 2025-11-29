from django.urls import path, include
from rest_framework.routers import DefaultRouter

from presentation.api.v1.views.arquivo_views import ArquivoViewSet

router = DefaultRouter()
router.register("arquivos", ArquivoViewSet, basename="arquivo")

urlpatterns = [
    path("v1/", include(router.urls)),
]
