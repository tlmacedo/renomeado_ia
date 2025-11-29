from typing import List

from core.repositories.arquivo_repo import ArquivoRepository
from core.services.ai_naming_service import AINamingService


class GerarSugestoesUseCase:
    def __init__(self, repo: ArquivoRepository, ai: AINamingService):
        self.repo = repo
        self.ai = ai

    def execute(self, arquivo_id: int) -> List[str]:
        arquivo = self.repo.get(arquivo_id)
        sugestoes = self.ai.sugerir_nomes(arquivo)
        return sugestoes or [f"{arquivo.tipo_arquivo}_{arquivo.data_upload:%Y%m%d}"]
