from rest_framework import serializers

from infrastructure.db.models.arquivo import ArquivoModel


class ArquivoSerializer(serializers.ModelSerializer):
    class Meta:
        model = ArquivoModel
        fields = ["id", "nome_original", "nome_sugerido", "nome_final", "tipo_arquivo", "tamanho", "data_upload",
                  "status"]
