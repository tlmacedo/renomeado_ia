# 📋 Checklist do Projeto — Renomeador de Arquivos com IA

Legenda:

- [x] Concluído
- [ ] Pendente
- Observações de “parcial” aparecem como sub-itens

---

## 📋 FASE 1: MVP - Fundações do Sistema (4 semanas)

### 🔧 Configuração do Ambiente

- [x] Instalar PyCharm Professional
- [x] Configurar Python 3.11+ com `pipenv` ou `poetry`
- [x] Instalar Docker e Docker-Compose
- [x] Configurar PostgreSQL (via Docker ou local)
- [x] Criar repositório Git no GitHub/GitLab
- [x] Configurar `.gitignore` para Python/Django
- [x] Criar `requirements.txt` com dependências básicas:
    - [x] Django
    - [x] djangorestframework
    - [x] psycopg2-binary
    - [x] python-decouple
    - [x] Pillow
    - [x] python-magic
    - [x] celery
    - [x] redis
    - [x] gunicorn
    - [x] amqp==5.3.1
    - [x] asgiref==3.11.0
    - [x] billiard==4.2.3
    - [x] celery-types==0.23.0
    - [x] click==8.3.1
    - [x] click-didyoumean==0.3.1
    - [x] click-plugins==1.1.1.2
    - [x] click-repl==0.3.0
    - [x] kombu==5.5.4
    - [x] packaging==25.0
    - [x] prompt_toolkit==3.0.52
    - [x] python-dateutil==2.9.0.post0
    - [x] six==1.17.0
    - [x] sqlparse==0.5.4
    - [x] tzdata==2025.2
    - [x] vine==5.1.0
    - [x] wcwidth==0.2.14

### 🏗️ Estrutura do Projeto Django

- [x] Criar projeto Django: `django-admin startproject renomeador_ia`
- [x] Estruturar pastas seguindo Clean Architecture:
    - [x] `core/` (entidades, repositories, services)
    - [x] `infrastructure/` (adapters, config)
    - [x] `application/` (use_cases, dtos)
    - [x] `presentation/` (templates, static, views)
    - [ ] `tests/` (pendente)
- [x] Configurar `settings`:
    - [x] Banco PostgreSQL
    - [x] Arquivos de mídia (MEDIA_ROOT, MEDIA_URL)
    - [x] Configurações de segurança básicas (ALLOWED_HOSTS, CSRF_TRUSTED_ORIGINS, proxy)

### 📊 Modelos de Dados (Core/Entities)

- [x] Criar modelo `Arquivo` (Django + dataclass de domínio)
    - [x] nome_original (CharField)
    - [x] nome_sugerido (CharField)
    - [x] nome_final (CharField)
    - [x] tipo_arquivo (CharField)
    - [x] tamanho (Integer/BigInteger)
    - [x] data_upload (DateTimeField)
    - [x] status (CharField)
    - [ ] choices para status (pendente: “pendente, processando, processado, erro”)
- [ ] Criar modelo `HistoricoRenomeacao`
    - [ ] arquivo (ForeignKey)
    - [ ] nome_anterior (CharField)
    - [ ] nome_novo (CharField)
    - [ ] data_alteracao (DateTimeField)
- [ ] Executar migrações: `python manage.py makemigrations && migrate`

### 🎨 Interface Básica (Presentation)

- [ ] Instalar TailwindCSS via CDN ou npm
- [x] Criar template base (`base.html`):
    - [x] Header com logo/título
    - [x] Navegação básica
    - [x] Container principal
    - [x] Footer
- [x] Criar páginas:
    - [x] `home.html` - página inicial
    - [x] `upload.html` - formulário de upload
    - [x] `lista_arquivos.html` - listagem de arquivos
- [x] Configurar arquivos estáticos (CSS, JS)

### 📤 Sistema de Upload

- [x] Criar formulário Django para upload (`forms.py`)
- [ ] Implementar view de upload (validações):
    - [ ] Validação de tipos de arquivo permitidos (via python-magic)
    - [ ] Validação de tamanho máximo
    - [x] Salvar arquivo no sistema
    - [x] Criar registro no banco de dados
- [ ] Adicionar Dropzone.js para drag-and-drop:
    - [ ] Incluir biblioteca no template
    - [ ] Configurar upload assíncrono via AJAX
    - [ ] Feedback visual durante upload

### ✏️ Renomeação Manual

- [ ] Criar formulário de edição de nome
- [ ] Implementar view de renomeação:
    - [ ] Permitir edição do nome do arquivo
    - [ ] Validar novo nome (caracteres permitidos)
    - [ ] Atualizar arquivo físico e registro no banco
    - [ ] Registrar no histórico
- [ ] Criar interface de listagem:
    - [ ] Mostrar arquivos uploadados
    - [ ] Botões para renomear/download/excluir
    - [ ] Paginação se necessário

### 🧪 Testes da Fase 1

- [ ] Testes unitários para modelos
- [ ] Testes de integração para upload
- [ ] Testes de interface (formulários)
- [ ] Teste manual completo do fluxo

---

## 📋 FASE 2: IA e Processamento de Metadados (3 semanas)

### 📚 Processamento de Documentos

- [ ] Instalar bibliotecas:
    - [ ] `PyPDF2` ou `pdfplumber`
    - [ ] `python-docx`
    - [ ] `textract`
    - [ ] `spacy` + modelo em português (`pt_core_news_sm`)
- [ ] Criar serviço de extração de texto (`core/services/text_extractor.py`):
    - [ ] Método para PDFs
    - [ ] Método para DOCX
    - [ ] Método genérico usando textract
    - [ ] Tratamento de erros e encoding
- [ ] Implementar analisador de conteúdo:
    - [ ] Extrair palavras-chave com spaCy
    - [ ] Identificar tópicos principais
    - [ ] Detectar entidades nomeadas (pessoas, organizações)

### 🖼️ Processamento de Mídias

- [ ] Instalar bibliotecas:
    - [ ] `opencv-python`
    - [ ] `python-exif`
- [ ] Criar serviço de metadados (`core/services/metadata_extractor.py`):
    - [ ] Extrair EXIF de imagens (data, localização, câmera)
    - [ ] Extrair metadados de vídeos (duração, resolução)
    - [ ] Tratar casos onde metadados não existem
- [ ] Implementar detecção básica de conteúdo:
    - [ ] Usar OpenCV para análise básica de imagens
    - [ ] Detectar rostos, objetos simples (opcional)

### 🤖 Sistema de Sugestão de Nomes

- [ ] Criar serviço de IA (`core/services/ai_naming_service.py`):
    - [ ] Lógica para documentos (baseada em palavras-chave)
    - [ ] Lógica para mídias (baseada em metadados)
    - [ ] Fallback para nomes padrão se IA falhar
- [ ] Implementar diferentes estratégias:
    - [ ] Baseada em data: `YYYY-MM-DD_tipo.ext`
    - [ ] Baseada em conteúdo: `topico_subtopico.ext`
    - [ ] Baseada em localização: `local_data.ext`
- [ ] Integrar OpenAI API (opcional):
    - [ ] Configurar chave da API
    - [ ] Criar prompts para sugestão de nomes
    - [ ] Implementar fallback local se API falhar

### 👁️ Pré-visualização de Sugestões

- [ ] Modificar view de upload para incluir processamento:
    - [ ] Após upload, processar arquivo automaticamente
    - [ ] Gerar múltiplas sugestões de nome
    - [ ] Armazenar sugestões no banco temporariamente
- [ ] Criar interface de pré-visualização:
    - [ ] Mostrar nome original vs. sugestões
    - [ ] Permitir edição manual das sugestões
    - [ ] Botões para aceitar/rejeitar sugestões
- [ ] Implementar AJAX para experiência fluida:
    - [ ] Processar arquivos em background
    - [ ] Mostrar loading durante processamento
    - [ ] Atualizar interface quando processamento terminar

### 🧪 Testes da Fase 2

- [ ] Testes para extratores de texto e metadados
- [ ] Testes para serviço de IA/sugestões
- [ ] Testes de integração para fluxo completo
- [ ] Testes com diferentes tipos de arquivo

---

## 📋 FASE 3: Funcionalidades Avançadas (3 semanas)

### 📝 Sistema de Templates

- [ ] Criar modelo `TemplateNomenclatura`
    - [ ] nome, padrao, descricao, usuario
- [ ] Implementar parser de templates
- [ ] Interface para CRUD de templates

### 📜 Sistema de Tags Inteligentes

- [ ] Criar modelo `Tag`
- [ ] Criar modelo `ArquivoTag` (many-to-many)
- [ ] Implementar gerador de tags
- [ ] Interface de tags

### ⚡ Processamento Assíncrono (Celery)

- [x] Instalar e configurar Celery (`celery[redis]`, broker Redis, settings)
- [ ] Criar tasks assíncronas:
    - [ ] `process_document.delay(arquivo_id)`
    - [ ] `extract_metadata.delay(arquivo_id)`
    - [x] `generate_suggestions.delay(arquivo_id)` (já existe como `tasks.generate_suggestions`)
- [x] Configurar worker Celery (script de inicialização)
- [x] Monitoramento com Flower

### 📊 Histórico e Relatórios

- [ ] Expandir `HistoricoRenomeacao`
- [ ] Criar views de relatórios
- [ ] Interface de histórico

### 🧪 Testes da Fase 3

- [ ] Testes para sistema de templates
- [ ] Testes para tasks Celery
- [ ] Testes de performance
- [ ] Testes de concorrência

---

## 📋 FASE 4: Polimentos e Extensões (2 semanas)

### ☁️ Integração com Nuvem

- [ ] Instalar SDKs (Drive/Dropbox/S3)
- [ ] Implementar conectores
- [ ] Interface de integração

### 🎨 Melhorias de UI/UX

- [ ] Dark/light mode
- [ ] Responsividade completa
- [ ] Acessibilidade

### 🔒 Segurança e Validação

- [ ] Verificações avançadas
- [ ] Configurações de produção (HTTPS, CSP, rate limit)
- [ ] Backup e recuperação

### 🚀 Deploy e Monitoramento

- [x] Criar configuração Docker
    - [x] `Dockerfile` para aplicação
    - [x] `docker-compose.yml` (web + db + redis + celery + flower + nginx)
    - [x] Scripts de inicialização (entrypoints)
- [ ] Configurar CI/CD (GitHub Actions/GitLab CI)
- [ ] Monitoramento (Sentry, logs, métricas)

### 📖 Documentação

- [ ] README detalhado
- [x] CHECKLIST.md (este arquivo)
- [ ] Guia de instalação
- [ ] Documentação da API
- [ ] Documentação do usuário

### 🧪 Testes Finais

- [ ] Testes de carga
- [ ] Testes de segurança
- [ ] Testes de usabilidade
- [ ] Correção de bugs

---

## ✅ Entrega Final

- [ ] Código fonte completo no repositório
- [ ] Aplicação deployada e funcional
- [ ] Documentação completa
- [ ] Testes automatizados funcionando
- [ ] Manual de manutenção
- [ ] Plano de evolução/roadmap
