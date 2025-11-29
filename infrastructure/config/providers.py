from application.use_cases.gerar_sugestoes import GerarSugestoesUseCase
from core.services.ai_naming_service import AINamingService
from infrastructure.db.repositories.arquivo_repo_django import ArquivoRepositoryDjango


class Container:
    def arquivo_repo(self):
        return ArquivoRepositoryDjango()

    def ai_service(self):
        return AINamingService()

    def gerar_sugestoes_uc(self):
        return GerarSugestoesUseCase(self.arquivo_repo(), self.ai_service())

    def celery(self):
        from renomeador_ia.celery import app
        return app


container = Container()
