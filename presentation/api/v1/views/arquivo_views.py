from rest_framework import viewsets

from infrastructure.db.models.arquivo import ArquivoModel
from presentation.api.v1.serializers.arquivo_serializer import ArquivoSerializer


class ArquivoViewSet(viewsets.ModelViewSet):
    queryset = ArquivoModel.objects.all()
    serializer_class = ArquivoSerializer
