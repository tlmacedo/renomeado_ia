# Renomeador de Arquivos com IA

## Sobre o Projeto

Este é um aplicativo Django que utiliza inteligência artificial para sugerir novos nomes para arquivos enviados. Os
usuários podem fazer upload de arquivos, receber sugestões de nomes geradas por IA e aprovar o nome final.

## Funcionalidades

* Upload de arquivos
* Geração de nomes de arquivos sugeridos por IA
* Aprovação e renomeação de arquivos
* Acompanhamento do status do processo de renomeação

## Como executar o projeto

1. **Clone o repositório:**
   ```bash
   git clone <url-do-repositorio>
   ```
2. **Crie e ative um ambiente virtual:**
   ```bash
   python -m venv venv
   source venv/bin/activate
   ```
3. **Instale as dependências:**
   ```bash
   pip install -r requirements.txt
   ```
4. **Execute as migrações do banco de dados:**
   ```bash
   python manage.py migrate
   ```
5. **Inicie o servidor de desenvolvimento:**
   ```bash
   python manage.py runserver
   ```

## Estrutura do Projeto

O projeto segue uma arquitetura limpa, com as seguintes camadas:

* **presentation:** Contém a interface do usuário (templates, views do Django).
* **application:** Orquestra os casos de uso da aplicação.
* **core:** Contém as entidades de negócio e regras de negócio principais.
* **infrastructure:** Contém as implementações de interfaces externas, como banco de dados e a integração com a IA.
