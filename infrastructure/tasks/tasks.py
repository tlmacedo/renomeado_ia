from celery import shared_task

from infrastructure.config.providers import container


@shared_task(name="tasks.generate_suggestions")
def generate_suggestions(arquivo_id: int):
    uc = container.gerar_sugestoes_uc()
    return uc.execute(arquivo_id)
