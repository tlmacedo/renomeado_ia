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
