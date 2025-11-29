from django.urls import path

from .views.arquivo import HomeView, UploadView, ListaArquivosView

urlpatterns = [
    path("", HomeView.as_view(), name="home"),
    path("upload/", UploadView.as_view(), name="upload"),
    path("arquivos/", ListaArquivosView.as_view(), name="lista_arquivos"),
]
