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
