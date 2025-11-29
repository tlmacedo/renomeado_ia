from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
from django.shortcuts import render, redirect
from django.views import View

from infrastructure.config.providers import container
from infrastructure.db.models.arquivo import ArquivoModel
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
