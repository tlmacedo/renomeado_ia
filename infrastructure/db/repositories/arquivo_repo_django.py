from typing import Iterable, Optional

from core.entities.arquivo import Arquivo
from core.repositories.arquivo_repo import ArquivoRepository
from infrastructure.db.mappers import to_entity
from infrastructure.db.models.arquivo import ArquivoModel


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
