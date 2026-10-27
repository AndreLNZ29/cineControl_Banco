# CineControl — Etapa 2

## Pré-requisitos

- Python 3.10+
- MySQL 8.0+ com o banco `cinecontrol` criado (Etapa 1)
- pip

## Instalação

```bash
# 1. Entre na pasta da aplicação
cd app/

# 2. Instale as dependências
pip install -r requirements.txt

# 3. Configure as credenciais
cp .env.example .env
# Edite .env com host, usuário e senha do seu MySQL

# 4. Execute os scripts da Etapa 2 no banco
mysql -u root -p cinecontrol < sql/04_etapa2.sql

# 5. Suba a aplicação
streamlit run app.py
```

A aplicação abre em `http://localhost:8501`.

## Estrutura dos novos arquivos

```
app/
├── app.py              # Interface Streamlit (B1)
├── db.py               # Camada de acesso — prepared statements (B2)
├── requirements.txt
├── .env.example        # Modelo de credenciais (o .env real fica fora do git)
└── sql/
    ├── 04_etapa2.sql   # View, gatilhos, índices, perfis de acesso (B3/B4/B5/B6)
    └── 05_otimizacao.sql  # EXPLAINs antes/depois para o relatório (B4)
```

## O que está implementado

| Requisito | Onde |
|-----------|------|
| B1 — CRUD (Filmes, Sessões, Clientes, Reservas) | `app.py` |
| B1 — 2 consultas parametrizadas | Página "Consultas" |
| B1 — Relatório via view | Página "Início / Relatório" |
| B1 — Operação transacional (reserva + sessao) | Página "Reservas" aba "Nova Reserva" |
| B1 — Tratamento de erro visível | Todas as páginas (msg_err) |
| B2 — Prepared statements | `db.py` — cursor.execute(sql, params) |
| B2 — Credenciais fora do código | `.env` (não versionado) |
| B3 — Transação explícita | `execute_transaction()` em `db.py` |
| B3 — Cenário de falha/rollback | Página "Transação (demo)" |
| B4 — Índices + EXPLAIN | `sql/05_otimizacao.sql` |
| B5 — Perfis de acesso | `sql/04_etapa2.sql` seção 5 |
| B5 — View de restrição | `vw_filmes_publico` |
| B5 — Hash de senha | `hash_senha()` em `app.py` |
| B6 — Gatilhos de auditoria | `sql/04_etapa2.sql` seção 3 |

## Demonstração de injeção de SQL resistida

Na página **Segurança (demo)**, insira `' OR '1'='1` no campo de busca.
O resultado mostrará 0 filmes (entrada literal) — o driver parametrizou
a query e nenhuma injeção ocorreu.
