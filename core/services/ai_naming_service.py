from typing import List

from core.entities.arquivo import Arquivo


class AINamingService:
    def sugerir_nomes(self, arquivo: Arquivo) -> List[str]:
        base = arquivo.nome_original.rsplit(".", 1)[0]
        sugestoes = [
            f"{base}_renomeado",
            f"{arquivo.tipo_arquivo}_{arquivo.data_upload:%Y%m%d}",
        ]
        return list(dict.fromkeys(sugestoes))
