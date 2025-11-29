from dataclasses import dataclass
from datetime import datetime
from typing import Optional, Literal

Status = Literal["pendente", "processando", "processado", "erro"]


@dataclass(frozen=True)
class Arquivo:
    id: Optional[int]
    nome_original: str
    nome_sugerido: Optional[str]
    nome_final: Optional[str]
    tipo_arquivo: str
    tamanho: int
    data_upload: datetime
    status: Status = "pendente"
