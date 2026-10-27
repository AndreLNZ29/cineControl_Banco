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
docs/                         Modelos e relatórios
qsl/                          Scripts SQL da Etapa 1
  01_ddl.sql                  Criação do banco, tabelas e regras
  02_carga.sql                Dados de teste da Etapa 1
  03_consultas.sql            Consultas SQL
cinecontrol_etapa2/app/       Aplicação Streamlit e scripts da Etapa 2
  app.py                      Interface da aplicação
  db.py                       Acesso ao MySQL e transações
  requirements.txt            Dependências Python
  .env.example                Modelo de configuração local
  sql/04_etapa2.sql           Objetos e recursos da Etapa 2
  sql/05_otimizacao.sql        Consultas EXPLAIN para análise de índices
  sql/seed_etapa2.sql          Dados de demonstração da Etapa 2
```

## Configurar o banco de dados

Com o MySQL 8.0 instalado e em execução, execute os scripts da Etapa 1 na ordem abaixo, a partir da raiz do repositório:

```bash
mysql -u root -p < qsl/01_ddl.sql
mysql -u root -p cinecontrol < qsl/02_carga.sql
mysql -u root -p cinecontrol < qsl/03_consultas.sql
```

> **Atenção:** `01_ddl.sql` recria o banco `cinecontrol` e pode remover os dados de uma versão anterior.

Em seguida, aplique a estrutura da Etapa 2:

```bash
mysql -u root -p cinecontrol < cinecontrol_etapa2/app/sql/04_etapa2.sql
```

Para carregar os dados de demonstração adicionais, execute também:

```bash
mysql -u root -p cinecontrol < cinecontrol_etapa2/app/sql/seed_etapa2.sql
```

## Instalar e executar a aplicação

No terminal, entre na pasta da aplicação e instale as dependências:

```bash
cd cinecontrol_etapa2/app
pip install -r requirements.txt
```

Crie o arquivo local `.env` a partir do modelo:

```bash
cp .env.example .env
```

No PowerShell, use `Copy-Item .env.example .env`. Edite `.env` com as credenciais do seu MySQL:

```dotenv
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=sua_senha
DB_NAME=cinecontrol
SENHA_SAL=defina_um_valor_aleatorio
```

O arquivo `.env` contém configurações privadas e não deve ser enviado ao Git. A aplicação procura esse arquivo junto de `db.py`; variáveis de ambiente já definidas no sistema têm prioridade.

Inicie o Streamlit dentro da pasta `cinecontrol_etapa2/app`:

```bash
streamlit run app.py
```

A aplicação estará disponível em <http://localhost:8501>.

## Recursos da aplicação

| Recurso | Localização |
|---|---|
| CRUD de filmes, sessões, clientes e reservas | Menu da aplicação (`app.py`) |
| Consultas parametrizadas | Página “Consultas” |
| Relatório consolidado via view | Página “Início / Relatório” |
| Reserva transacional e demonstração de rollback | Páginas “Reservas” e “Transação (demo)” |
| Perfis de acesso e view pública | `sql/04_etapa2.sql` |
| Índices e análise com EXPLAIN | `sql/05_otimizacao.sql` |
| Gatilhos de auditoria | `sql/04_etapa2.sql` |

Na página **Segurança (demo)**, a entrada `' OR '1'='1` pode ser usada para demonstrar que a busca é enviada como parâmetro SQL e tratada como texto literal.

## Documentação e modelo de dados

As pastas `docs/` e `qsl/` contêm os diagramas, relatórios, dicionário de dados e scripts SQL do projeto. As principais entidades são `USUARIO`, `CLIENTE`, `ADMINISTRADOR`, `FILME`, `GENERO`, `ATOR`, `SALA`, `ASSENTO`, `SESSAO` e `RESERVA`.
