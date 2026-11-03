# CineControl — Banco de Dados

Projeto acadêmico de gerenciamento de cinema. O repositório reúne o banco relacional da Etapa 1 e uma aplicação web em Streamlit para a Etapa 2.

## Funcionalidades

- Cadastro e consulta de usuários, clientes, administradores, filmes, gêneros, atores, salas, assentos, sessões e reservas.
- Relacionamentos entre filmes e gêneros e entre filmes e atores por tabelas associativas.
- Histórico da situação dos filmes, regras de integridade, índices, views e triggers de auditoria.
- Aplicação Streamlit com operações CRUD, consultas parametrizadas e fluxo transacional de reservas.
- Demonstrações de rollback, perfis de acesso, hash de senha e proteção contra injeção de SQL.

## Tecnologias

- MySQL 8.0+
- Python 3.10+
- Streamlit, pandas, `mysql-connector-python` e `python-dotenv`
- draw.io para modelagem

## Estrutura do projeto

```text
app/                          Aplicação Streamlit
  .env                        Credenciais locais (não versionado)
  app.py                      Interface da aplicação
  db.py                       Acesso ao MySQL e transações
docs/                         Modelos e relatórios
  dicionario-dados.pdf        Dicionário de dados completo
  mer-conceitual.drawio       Diagrama MER editável
  mer-conceitual.png          Diagrama MER (imagem)
  mer.pdf                     MER em PDF
  modelo-logico.pdf           Modelo lógico relacional
  relatorio-etapa-1.pdf       Relatório da Etapa 1
sql/                          Todos os scripts SQL (Etapas 1 e 2)
  01_ddl.sql                  Criação do banco, tabelas e restrições
  02_carga.sql                Dados de teste
  03_consultas.sql            Consultas SQL da Etapa 1
  04_etapa2.sql               Objetos e recursos da Etapa 2
  05_otimizacao.sql           Consultas EXPLAIN para análise de índices
.gitignore
README.md
requirements.txt              Dependências Python
```

## Configurar o banco de dados

Com o MySQL 8.0 instalado e em execução, execute os scripts na ordem abaixo, a partir da raiz do repositório:

```bash
# Etapa 1 — cria o banco e carrega os dados iniciais
mysql -u root -p < sql/01_ddl.sql
mysql -u root -p cinecontrol < sql/02_carga.sql
mysql -u root -p cinecontrol < sql/03_consultas.sql

# Etapa 2 — adiciona views, triggers, índices e perfis de acesso
mysql -u root -p cinecontrol < sql/04_etapa2.sql
```

> **Atenção:** `01_ddl.sql` recria o banco `cinecontrol` e apaga os dados de versões anteriores.  

## Instalar e executar a aplicação

Na raiz do repositório, instale as dependências:

```bash
pip install -r requirements.txt
```

Crie um arquivo `.env` dentro da pasta `app/` com as credenciais do seu MySQL:

```dotenv
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=sua_senha
DB_NAME=cinecontrol
SENHA_SAL=defina_um_valor_aleatorio
```

> O arquivo `.env` não é versionado. A aplicação o procura junto de `db.py`; variáveis de ambiente já definidas no sistema têm prioridade.

Inicie o Streamlit a partir da pasta `app/`:

```bash
cd app
streamlit run app.py
```

A aplicação estará disponível em <http://localhost:8501>.

## Recursos da aplicação

| Recurso | Localização |
|---|---|
| CRUD de filmes, sessões, clientes e reservas | Menu da aplicação (`app/app.py`) |
| Consultas parametrizadas | Página "Consultas" |
| Relatório consolidado via view | Página "Início / Relatório" |
| Reserva transacional e demonstração de rollback | Páginas "Reservas" e "Transação (demo)" |
| Perfis de acesso e view pública | `sql/04_etapa2.sql` |
| Índices e análise com EXPLAIN | `sql/05_otimizacao.sql` |
| Gatilhos de auditoria | `sql/04_etapa2.sql` |

Na página **Segurança (demo)**, a entrada `' OR '1'='1` demonstra que a busca é enviada como parâmetro SQL e tratada como texto literal — sem injeção.

## Documentação e modelo de dados

A pasta `docs/` contém os diagramas, relatórios e o dicionário de dados do projeto. As principais entidades são `USUARIO`, `CLIENTE`, `ADMINISTRADOR`, `FILME`, `GENERO`, `ATOR`, `SALA`, `ASSENTO`, `SESSAO` e `RESERVA`.
