"""
CineControl — Interface Streamlit (Etapa 2)
Execute: streamlit run app.py
"""

import streamlit as st
import pandas as pd
from datetime import datetime
import hashlib
import os
from db import get_connection, execute_query, execute_transaction
from mysql.connector import Error

st.set_page_config(page_title="CineControl", page_icon="🎬", layout="wide")

# ──────────────────────────────────────────────────────────────
# HELPERS
# ──────────────────────────────────────────────────────────────

def hash_senha(senha: str) -> str:
    """Hash simples com sal fixo para demonstração (produção usaria bcrypt)."""
    sal = os.getenv("SENHA_SAL", "cinecontrol_sal_2026")
    return hashlib.sha256((sal + senha).encode()).hexdigest()

def msg_ok(texto):
    st.success(texto)

def msg_err(texto):
    st.error(texto)

def df(rows):
    return pd.DataFrame(rows) if rows else pd.DataFrame()

# ──────────────────────────────────────────────────────────────
# SIDEBAR — NAVEGAÇÃO
# ──────────────────────────────────────────────────────────────

st.sidebar.title("🎬 CineControl")
pagina = st.sidebar.radio("Menu", [
    "🏠 Início / Relatório",
    "🎥 Filmes",
    "🕐 Sessões",
    "👤 Clientes",
    "🎟️ Reservas",
    "🔍 Consultas",
    "🔐 Segurança (demo)",
    "⚙️ Transação (demo)",
])

# ──────────────────────────────────────────────────────────────
# PÁGINA: RELATÓRIO CONSOLIDADO (view)
# ──────────────────────────────────────────────────────────────

if pagina == "🏠 Início / Relatório":
    st.title("🎬 CineControl — Painel")
    st.caption("Relatório alimentado pela view `vw_relatorio_sessoes` do banco.")

    # Tenta criar a view se não existir
    _view_sql = """
    CREATE OR REPLACE VIEW vw_relatorio_sessoes AS
    SELECT
        f.titulo AS filme,
        f.classificacao,
        s.inicio AS horario,
        sa.nome_numero AS sala,
        s.preco,
        s.ingressos_disponiveis AS ingressos_disponiveis,
        s.situacao AS situacao_sessao,
        COALESCE(COUNT(r.id_reserva), 0) AS total_reservas,
        COALESCE(SUM(r.quantidade), 0) AS ingressos_vendidos
    FROM sessao s
    JOIN filme f ON f.id_filme = s.id_filme
    JOIN sala sa ON sa.id_sala = s.id_sala
    LEFT JOIN reserva r ON r.id_sessao = s.id_sessao AND r.situacao = 'CONFIRMADA'
    GROUP BY s.id_sessao, f.titulo, f.classificacao, s.inicio,
             sa.nome_numero, s.preco, s.ingressos_disponiveis, s.situacao
    """
    try:
        execute_query(_view_sql, fetch=False)
    except Exception:
        pass  # view já existe ou erro menor

    try:
        rows = execute_query("SELECT * FROM vw_relatorio_sessoes ORDER BY horario DESC LIMIT 100")
        if rows:
            st.dataframe(df(rows), use_container_width=True)
        else:
            st.info("Nenhuma sessão cadastrada ainda.")
    except Exception as e:
        st.error(f"Erro ao carregar relatório: {e}")

# ──────────────────────────────────────────────────────────────
# PÁGINA: FILMES — CRUD
# ──────────────────────────────────────────────────────────────

elif pagina == "🎥 Filmes":
    st.title("🎥 Filmes")
    aba = st.tabs(["Listar", "Cadastrar", "Editar", "Excluir"])

    # LISTAR
    with aba[0]:
        try:
            rows = execute_query(
                "SELECT id_filme, titulo, duracao_min, classificacao, situacao, data_lancamento FROM filme ORDER BY titulo"
            )
            st.dataframe(df(rows), use_container_width=True)
        except Exception as e:
            msg_err(e)

    # CADASTRAR
    with aba[1]:
        with st.form("form_filme_new"):
            titulo = st.text_input("Título *")
            descricao = st.text_area("Descrição")
            duracao = st.number_input("Duração (min) *", min_value=1, max_value=500, value=100)
            classif = st.selectbox("Classificação *", ["L","10","12","14","16","18"])
            data_lanc = st.date_input("Data de lançamento")
            situacao = st.selectbox("Situação *", ["EM_CARTAZ","FUTURO","PAUSADO","ENCERRADO"])
            if st.form_submit_button("Cadastrar"):
                if not titulo:
                    msg_err("Título obrigatório.")
                else:
                    try:
                        execute_query(
                            "INSERT INTO filme (titulo, descricao, duracao_min, classificacao, data_lancamento, situacao) VALUES (%s,%s,%s,%s,%s,%s)",
                            (titulo, descricao or None, duracao, classif, data_lanc, situacao),
                            fetch=False,
                        )
                        msg_ok("Filme cadastrado!")
                    except Error as e:
                        msg_err(f"Erro: {e.msg}")

    # EDITAR
    with aba[2]:
        try:
            filmes = execute_query("SELECT id_filme, titulo FROM filme ORDER BY titulo")
            opcoes = {f["titulo"]: f["id_filme"] for f in filmes}
            escolha = st.selectbox("Selecione o filme", list(opcoes.keys()))
            if escolha:
                fid = opcoes[escolha]
                dados = execute_query("SELECT * FROM filme WHERE id_filme = %s", (fid,))
                d = dados[0] if dados else {}
                with st.form("form_filme_edit"):
                    titulo_e = st.text_input("Título", value=d.get("titulo",""))
                    duracao_e = st.number_input("Duração (min)", min_value=1, max_value=500, value=int(d.get("duracao_min",100)))
                    classif_e = st.selectbox("Classificação", ["L","10","12","14","16","18"],
                                             index=["L","10","12","14","16","18"].index(d.get("classificacao","L")))
                    sit_e = st.selectbox("Situação", ["EM_CARTAZ","FUTURO","PAUSADO","ENCERRADO"],
                                         index=["EM_CARTAZ","FUTURO","PAUSADO","ENCERRADO"].index(d.get("situacao","EM_CARTAZ")))
                    if st.form_submit_button("Salvar"):
                        try:
                            execute_query(
                                "UPDATE filme SET titulo=%s, duracao_min=%s, classificacao=%s, situacao=%s WHERE id_filme=%s",
                                (titulo_e, duracao_e, classif_e, sit_e, fid),
                                fetch=False,
                            )
                            msg_ok("Filme atualizado!")
                        except Error as e:
                            msg_err(f"Erro: {e.msg}")
        except Exception as e:
            msg_err(e)

    # EXCLUIR
    with aba[3]:
        try:
            filmes = execute_query("SELECT id_filme, titulo FROM filme ORDER BY titulo")
            opcoes = {f["titulo"]: f["id_filme"] for f in filmes}
            escolha = st.selectbox("Selecione o filme para excluir", list(opcoes.keys()), key="del_filme")
            if st.button("Excluir", type="primary"):
                try:
                    execute_query("DELETE FROM filme WHERE id_filme = %s", (opcoes[escolha],), fetch=False)
                    msg_ok("Filme excluído.")
                except Error as e:
                    msg_err(f"Restrição: {e.msg}")
        except Exception as e:
            msg_err(e)

# ──────────────────────────────────────────────────────────────
# PÁGINA: SESSÕES — CRUD
# ──────────────────────────────────────────────────────────────

elif pagina == "🕐 Sessões":
    st.title("🕐 Sessões")
    aba = st.tabs(["Listar", "Cadastrar", "Editar", "Excluir"])

    with aba[0]:
        try:
            rows = execute_query("""
                SELECT s.id_sessao, f.titulo AS filme, sa.nome_numero AS sala,
                       s.inicio, s.preco, s.ingressos_disponiveis, s.situacao
                FROM sessao s
                JOIN filme f ON f.id_filme = s.id_filme
                JOIN sala sa ON sa.id_sala = s.id_sala
                ORDER BY s.inicio DESC LIMIT 200
            """)
            st.dataframe(df(rows), use_container_width=True)
        except Exception as e:
            msg_err(e)

    with aba[1]:
        try:
            filmes = execute_query("SELECT id_filme, titulo FROM filme ORDER BY titulo")
            salas  = execute_query("SELECT id_sala, nome_numero FROM sala WHERE situacao='ATIVA'")
            fm = {f["titulo"]: f["id_filme"] for f in filmes}
            sm = {s["nome_numero"]: s["id_sala"] for s in salas}
            with st.form("form_sessao_new"):
                f_esc = st.selectbox("Filme *", list(fm.keys()))
                s_esc = st.selectbox("Sala *", list(sm.keys()))
                inicio = st.datetime_input("Início *", value=datetime.now()) if hasattr(st, "datetime_input") else st.text_input("Início (YYYY-MM-DD HH:MM)", value=str(datetime.now())[:16])
                preco  = st.number_input("Preço (R$) *", min_value=0.0, value=25.0, step=0.5)
                disp   = st.number_input("Ingressos disponíveis *", min_value=0, value=100)
                sit    = st.selectbox("Situação", ["PROGRAMADA","EM_EXIBICAO","ENCERRADA","CANCELADA"])
                if st.form_submit_button("Cadastrar"):
                    try:
                        execute_query(
                            "INSERT INTO sessao (id_filme,id_sala,inicio,preco,ingressos_disponiveis,situacao) VALUES (%s,%s,%s,%s,%s,%s)",
                            (fm[f_esc], sm[s_esc], str(inicio), preco, disp, sit),
                            fetch=False,
                        )
                        msg_ok("Sessão cadastrada!")
                    except Error as e:
                        msg_err(f"Erro: {e.msg}")
        except Exception as e:
            msg_err(e)

    with aba[2]:
        try:
            sessoes = execute_query("""
                SELECT s.id_sessao, CONCAT(f.titulo,' — ',s.inicio) AS label
                FROM sessao s JOIN filme f ON f.id_filme=s.id_filme ORDER BY s.inicio DESC LIMIT 100
            """)
            op = {r["label"]: r["id_sessao"] for r in sessoes}
            esc = st.selectbox("Sessão", list(op.keys()))
            if esc:
                d = execute_query("SELECT * FROM sessao WHERE id_sessao=%s", (op[esc],))[0]
                with st.form("form_sessao_edit"):
                    preco_e = st.number_input("Preço", value=float(d["preco"]))
                    disp_e  = st.number_input("Ingressos disponíveis", value=int(d["ingressos_disponiveis"]))
                    sit_e   = st.selectbox("Situação", ["PROGRAMADA","EM_EXIBICAO","ENCERRADA","CANCELADA"],
                                           index=["PROGRAMADA","EM_EXIBICAO","ENCERRADA","CANCELADA"].index(d["situacao"]))
                    if st.form_submit_button("Salvar"):
                        execute_query(
                            "UPDATE sessao SET preco=%s, ingressos_disponiveis=%s, situacao=%s WHERE id_sessao=%s",
                            (preco_e, disp_e, sit_e, op[esc]), fetch=False
                        )
                        msg_ok("Atualizado!")
        except Exception as e:
            msg_err(e)

    with aba[3]:
        try:
            sessoes = execute_query("""
                SELECT s.id_sessao, CONCAT(f.titulo,' — ',s.inicio) AS label
                FROM sessao s JOIN filme f ON f.id_filme=s.id_filme ORDER BY s.inicio DESC LIMIT 100
            """)
            op = {r["label"]: r["id_sessao"] for r in sessoes}
            esc = st.selectbox("Sessão para excluir", list(op.keys()), key="del_sessao")
            if st.button("Excluir sessão", type="primary"):
                try:
                    execute_query("DELETE FROM sessao WHERE id_sessao=%s", (op[esc],), fetch=False)
                    msg_ok("Excluída.")
                except Error as e:
                    msg_err(f"Restrição: {e.msg}")
        except Exception as e:
            msg_err(e)

# ──────────────────────────────────────────────────────────────
# PÁGINA: CLIENTES — CRUD
# ──────────────────────────────────────────────────────────────

elif pagina == "👤 Clientes":
    st.title("👤 Clientes")
    aba = st.tabs(["Listar", "Cadastrar", "Editar", "Excluir"])

    with aba[0]:
        try:
            rows = execute_query("""
                SELECT u.id_usuario, u.nome, u.email, u.ativo, c.data_cadastro
                FROM usuario u JOIN cliente c ON c.id_usuario=u.id_usuario
                ORDER BY u.nome
            """)
            st.dataframe(df(rows), use_container_width=True)
        except Exception as e:
            msg_err(e)

    with aba[1]:
        with st.form("form_cli_new"):
            nome  = st.text_input("Nome *")
            email = st.text_input("E-mail *")
            senha = st.text_input("Senha *", type="password")
            if st.form_submit_button("Cadastrar"):
                if not (nome and email and senha):
                    msg_err("Todos os campos são obrigatórios.")
                else:
                    try:
                        h = hash_senha(senha)
                        execute_transaction([
                            ("INSERT INTO usuario (nome, email, senha_hash) VALUES (%s,%s,%s)", (nome, email, h)),
                            ("INSERT INTO cliente (id_usuario) SELECT LAST_INSERT_ID()", ()),
                        ])
                        msg_ok("Cliente cadastrado!")
                    except Error as e:
                        msg_err(f"Erro: {e.msg}")

    with aba[2]:
        try:
            clientes = execute_query("SELECT u.id_usuario, u.nome FROM usuario u JOIN cliente c ON c.id_usuario=u.id_usuario ORDER BY u.nome")
            op = {r["nome"]: r["id_usuario"] for r in clientes}
            esc = st.selectbox("Cliente", list(op.keys()))
            if esc:
                d = execute_query("SELECT * FROM usuario WHERE id_usuario=%s", (op[esc],))[0]
                with st.form("form_cli_edit"):
                    nome_e  = st.text_input("Nome", value=d["nome"])
                    email_e = st.text_input("E-mail", value=d["email"])
                    ativo_e = st.checkbox("Ativo", value=bool(d["ativo"]))
                    if st.form_submit_button("Salvar"):
                        execute_query(
                            "UPDATE usuario SET nome=%s, email=%s, ativo=%s WHERE id_usuario=%s",
                            (nome_e, email_e, ativo_e, op[esc]), fetch=False
                        )
                        msg_ok("Atualizado!")
        except Exception as e:
            msg_err(e)

    with aba[3]:
        try:
            clientes = execute_query("SELECT u.id_usuario, u.nome FROM usuario u JOIN cliente c ON c.id_usuario=u.id_usuario ORDER BY u.nome")
            op = {r["nome"]: r["id_usuario"] for r in clientes}
            esc = st.selectbox("Cliente para excluir", list(op.keys()), key="del_cli")
            if st.button("Excluir cliente", type="primary"):
                try:
                    execute_query("DELETE FROM usuario WHERE id_usuario=%s", (op[esc],), fetch=False)
                    msg_ok("Excluído.")
                except Error as e:
                    msg_err(f"Restrição: {e.msg}")
        except Exception as e:
            msg_err(e)

# ──────────────────────────────────────────────────────────────
# PÁGINA: RESERVAS — CRUD
# ──────────────────────────────────────────────────────────────

elif pagina == "🎟️ Reservas":
    st.title("🎟️ Reservas")
    aba = st.tabs(["Listar", "Nova Reserva (transação)", "Cancelar"])

    with aba[0]:
        try:
            rows = execute_query("""
                SELECT r.id_reserva, u.nome AS cliente,
                       f.titulo AS filme, s.inicio,
                       r.quantidade, r.situacao, r.data_reserva
                FROM reserva r
                JOIN cliente c ON c.id_usuario=r.id_cliente
                JOIN usuario u ON u.id_usuario=c.id_usuario
                JOIN sessao s ON s.id_sessao=r.id_sessao
                JOIN filme f ON f.id_filme=s.id_filme
                ORDER BY r.data_reserva DESC LIMIT 200
            """)
            st.dataframe(df(rows), use_container_width=True)
        except Exception as e:
            msg_err(e)

    # TRANSAÇÃO: inserir reserva e decrementar ingressos_disponiveis atomicamente
    with aba[1]:
        st.subheader("Nova reserva — operação transacional (altera reserva + sessao)")
        st.caption("Esta operação é executada em uma única transação explícita (BEGIN … COMMIT).")
        try:
            clientes = execute_query("SELECT u.id_usuario, u.nome FROM usuario u JOIN cliente c ON c.id_usuario=u.id_usuario ORDER BY u.nome")
            sessoes  = execute_query("""
                SELECT s.id_sessao, CONCAT(f.titulo,' — ',DATE_FORMAT(s.inicio,'%d/%m/%Y %H:%i'),' — R$',s.preco) AS label,
                       s.ingressos_disponiveis
                FROM sessao s JOIN filme f ON f.id_filme=s.id_filme
                WHERE s.situacao='PROGRAMADA' AND s.ingressos_disponiveis>0
                ORDER BY s.inicio
            """)
            cli_op = {r["nome"]: r["id_usuario"] for r in clientes}
            ses_op = {r["label"]: {"id": r["id_sessao"], "disp": r["ingressos_disponiveis"]} for r in sessoes}

            cli_esc = st.selectbox("Cliente", list(cli_op.keys()))
            ses_esc = st.selectbox("Sessão disponível", list(ses_op.keys()))
            qtd     = st.number_input("Quantidade de ingressos", min_value=1, max_value=10, value=1)

            if st.button("Confirmar reserva"):
                id_cli = cli_op[cli_esc]
                id_ses = ses_op[ses_esc]["id"]
                disp   = ses_op[ses_esc]["disp"]
                if qtd > disp:
                    msg_err(f"Apenas {disp} ingresso(s) disponível(is).")
                else:
                    try:
                        execute_transaction([
                            (
                                "INSERT INTO reserva (id_cliente, id_sessao, quantidade) VALUES (%s,%s,%s)",
                                (id_cli, id_ses, qtd),
                            ),
                            (
                                "UPDATE sessao SET ingressos_disponiveis = ingressos_disponiveis - %s WHERE id_sessao = %s",
                                (qtd, id_ses),
                            ),
                        ])
                        msg_ok(f"Reserva confirmada! {qtd} ingresso(s) reservado(s).")
                    except Error as e:
                        msg_err(f"Transação revertida: {e.msg}")
        except Exception as e:
            msg_err(e)

    with aba[2]:
        try:
            reservas = execute_query("""
                SELECT r.id_reserva, CONCAT('#',r.id_reserva,' — ',u.nome,' — ',f.titulo) AS label
                FROM reserva r
                JOIN cliente c ON c.id_usuario=r.id_cliente
                JOIN usuario u ON u.id_usuario=c.id_usuario
                JOIN sessao s ON s.id_sessao=r.id_sessao
                JOIN filme f ON f.id_filme=s.id_filme
                WHERE r.situacao='CONFIRMADA'
                ORDER BY r.id_reserva DESC LIMIT 100
            """)
            op = {r["label"]: r["id_reserva"] for r in reservas}
            esc = st.selectbox("Reserva", list(op.keys()))
            if st.button("Cancelar reserva", type="primary"):
                try:
                    # Transação: cancela reserva e devolve ingressos
                    rid = op[esc]
                    r = execute_query("SELECT * FROM reserva WHERE id_reserva=%s", (rid,))[0]
                    execute_transaction([
                        ("UPDATE reserva SET situacao='CANCELADA' WHERE id_reserva=%s", (rid,)),
                        ("UPDATE sessao SET ingressos_disponiveis=ingressos_disponiveis+%s WHERE id_sessao=%s",
                         (r["quantidade"], r["id_sessao"])),
                    ])
                    msg_ok("Reserva cancelada e ingressos devolvidos.")
                except Error as e:
                    msg_err(f"Erro: {e.msg}")
        except Exception as e:
            msg_err(e)

# ──────────────────────────────────────────────────────────────
# PÁGINA: CONSULTAS PARAMETRIZADAS
# ──────────────────────────────────────────────────────────────

elif pagina == "🔍 Consultas":
    st.title("🔍 Consultas Parametrizadas")

    opcao = st.selectbox("Escolha a consulta", [
        "1. Sessões por filme (filtro por título)",
        "2. Ranking de filmes por reservas (filtro por período)",
    ])

    if opcao.startswith("1"):
        st.subheader("Sessões por filme")
        filtro = st.text_input("Parte do título do filme", value="")
        if st.button("Buscar"):
            try:
                rows = execute_query("""
                    SELECT f.titulo, f.classificacao, sa.nome_numero AS sala,
                           s.inicio, s.preco, s.ingressos_disponiveis, s.situacao
                    FROM sessao s
                    JOIN filme f ON f.id_filme = s.id_filme
                    JOIN sala sa ON sa.id_sala = s.id_sala
                    WHERE f.titulo LIKE %s
                    ORDER BY s.inicio
                """, (f"%{filtro}%",))
                st.dataframe(df(rows), use_container_width=True)
                st.caption(f"{len(rows)} resultado(s) — consulta com LIKE parametrizado (sem concatenação de string)")
            except Exception as e:
                msg_err(e)

    elif opcao.startswith("2"):
        st.subheader("Ranking de filmes por ingressos reservados")
        col1, col2 = st.columns(2)
        with col1:
            data_ini = st.date_input("De", value=datetime(2026, 1, 1).date())
        with col2:
            data_fim = st.date_input("Até", value=datetime.today().date())
        if st.button("Buscar"):
            try:
                rows = execute_query("""
                    SELECT f.titulo, f.classificacao,
                           COUNT(DISTINCT r.id_reserva) AS qtd_reservas,
                           SUM(r.quantidade) AS ingressos_vendidos,
                           SUM(r.quantidade * s.preco) AS receita_total
                    FROM reserva r
                    JOIN sessao s ON s.id_sessao = r.id_sessao
                    JOIN filme f ON f.id_filme = s.id_filme
                    WHERE r.situacao = 'CONFIRMADA'
                      AND DATE(r.data_reserva) BETWEEN %s AND %s
                    GROUP BY f.id_filme, f.titulo, f.classificacao
                    HAVING SUM(r.quantidade) > 0
                    ORDER BY ingressos_vendidos DESC
                """, (str(data_ini), str(data_fim)))
                st.dataframe(df(rows), use_container_width=True)
                st.caption("Consulta com JOIN, GROUP BY, HAVING e filtro de período parametrizado.")
            except Exception as e:
                msg_err(e)

# ──────────────────────────────────────────────────────────────
# PÁGINA: SEGURANÇA (demo)
# ──────────────────────────────────────────────────────────────

elif pagina == "🔐 Segurança (demo)":
    st.title("🔐 Segurança e Controle de Acesso")

    st.subheader("Demonstração: Injeção de SQL — a aplicação resiste")
    entrada = st.text_input("Tente injetar SQL no campo de busca de título", value="' OR '1'='1")
    if st.button("Testar injeção"):
        try:
            rows = execute_query(
                "SELECT id_filme, titulo FROM filme WHERE titulo LIKE %s LIMIT 5",
                (f"%{entrada}%",)
            )
            st.info(f"Resultado seguro: {len(rows)} filme(s) encontrado(s). O driver parametrizou a entrada — nenhuma injeção ocorreu.")
            st.dataframe(df(rows))
        except Exception as e:
            msg_err(e)

    st.divider()
    st.subheader("Perfis de acesso (executar no MySQL como root)")
    st.code("""
-- Perfil 1: somente leitura (cliente web)
CREATE USER IF NOT EXISTS 'cc_leitura'@'localhost' IDENTIFIED BY 'LeituraSenha#2026';
GRANT SELECT ON cinecontrol.* TO 'cc_leitura'@'localhost';

-- Perfil 2: operacional (atendente — pode inserir reservas, atualizar sessões)
CREATE USER IF NOT EXISTS 'cc_operacional'@'localhost' IDENTIFIED BY 'OperSenha#2026';
GRANT SELECT, INSERT, UPDATE ON cinecontrol.reserva TO 'cc_operacional'@'localhost';
GRANT SELECT, UPDATE ON cinecontrol.sessao TO 'cc_operacional'@'localhost';
GRANT SELECT ON cinecontrol.filme TO 'cc_operacional'@'localhost';
GRANT SELECT ON cinecontrol.sala TO 'cc_operacional'@'localhost';
GRANT SELECT ON cinecontrol.usuario TO 'cc_operacional'@'localhost';
GRANT SELECT ON cinecontrol.cliente TO 'cc_operacional'@'localhost';

-- Perfil 3: gestor (acesso total exceto DROP/estrutura)
CREATE USER IF NOT EXISTS 'cc_gestor'@'localhost' IDENTIFIED BY 'GestorSenha#2026';
GRANT SELECT, INSERT, UPDATE, DELETE ON cinecontrol.* TO 'cc_gestor'@'localhost';

FLUSH PRIVILEGES;

-- View de restrição: clientes veem apenas filmes EM_CARTAZ (sem preço interno)
CREATE OR REPLACE VIEW vw_filmes_publico AS
SELECT id_filme, titulo, duracao_min, classificacao, data_lancamento
FROM filme WHERE situacao = 'EM_CARTAZ';

GRANT SELECT ON cinecontrol.vw_filmes_publico TO 'cc_leitura'@'localhost';
""", language="sql")

    st.subheader("Armazenamento de senhas")
    st.info("Senhas são armazenadas com SHA-256 + sal (variável de ambiente SENHA_SAL). Em produção, usar bcrypt ou argon2.")
    senha_demo = st.text_input("Digite uma senha para ver o hash gerado", type="password")
    if senha_demo:
        st.code(f"Hash: {hash_senha(senha_demo)}")

# ──────────────────────────────────────────────────────────────
# PÁGINA: TRANSAÇÃO (demo)
# ──────────────────────────────────────────────────────────────

elif pagina == "⚙️ Transação (demo)":
    st.title("⚙️ Demonstração de Transação")
    st.caption("Operação multitabela com BEGIN … COMMIT / ROLLBACK explícito.")

    st.subheader("Cenário: nova reserva com falha proposital")
    st.markdown("""
    Ao clicar em **Falha proposital**, o sistema inicia a transação, insere a reserva,
    mas depois tenta atualizar a sessão com um valor inválido (`-9999` ingressos),
    violando a constraint `ck_sessao_disponibilidade`. O ROLLBACK é acionado e
    **nenhuma linha fica alterada** — demonstrando a atomicidade.
    """)

    try:
        sessoes = execute_query("""
            SELECT s.id_sessao, CONCAT(f.titulo,' — ',s.inicio) AS label, s.ingressos_disponiveis
            FROM sessao s JOIN filme f ON f.id_filme=s.id_filme
            WHERE s.situacao='PROGRAMADA' ORDER BY s.inicio LIMIT 20
        """)
        clientes = execute_query("SELECT u.id_usuario, u.nome FROM usuario u JOIN cliente c ON c.id_usuario=u.id_usuario LIMIT 10")

        if sessoes and clientes:
            ses_op = {r["label"]: r["id_sessao"] for r in sessoes}
            cli_op = {r["nome"]: r["id_usuario"] for r in clientes}
            ses_esc = st.selectbox("Sessão (demo)", list(ses_op.keys()))
            cli_esc = st.selectbox("Cliente (demo)", list(cli_op.keys()))

            col1, col2 = st.columns(2)
            with col1:
                if st.button("✅ Transação com COMMIT (sucesso)"):
                    try:
                        execute_transaction([
                            ("INSERT INTO reserva (id_cliente,id_sessao,quantidade) VALUES (%s,%s,%s)",
                             (cli_op[cli_esc], ses_op[ses_esc], 1)),
                            ("UPDATE sessao SET ingressos_disponiveis=ingressos_disponiveis-1 WHERE id_sessao=%s",
                             (ses_op[ses_esc],)),
                        ])
                        st.success("COMMIT executado — reserva criada e ingresso decrementado.")
                    except Error as e:
                        st.error(f"Erro inesperado: {e.msg}")

            with col2:
                if st.button("❌ Transação com ROLLBACK (falha proposital)"):
                    conn = get_connection()
                    try:
                        cur = conn.cursor()
                        conn.start_transaction()
                        # Passo 1: insere reserva (válido)
                        cur.execute(
                            "INSERT INTO reserva (id_cliente,id_sessao,quantidade) VALUES (%s,%s,%s)",
                            (cli_op[cli_esc], ses_op[ses_esc], 1)
                        )
                        # Passo 2: tenta set ingressos para -9999 (viola CHECK)
                        cur.execute(
                            "UPDATE sessao SET ingressos_disponiveis=-9999 WHERE id_sessao=%s",
                            (ses_op[ses_esc],)
                        )
                        conn.commit()
                        st.success("COMMIT (não deveria chegar aqui)")
                    except Error as e:
                        conn.rollback()
                        st.error(f"ROLLBACK executado — banco permanece íntegro. Erro: {e.msg}")
                    finally:
                        conn.close()
        else:
            st.warning("Cadastre sessões e clientes primeiro.")
    except Exception as e:
        msg_err(e)

    st.divider()
    st.subheader("Gatilhos de auditoria (executar no MySQL)")
    st.code("""
-- Tabela de auditoria
CREATE TABLE IF NOT EXISTS auditoria_reserva (
    id_auditoria BIGINT AUTO_INCREMENT PRIMARY KEY,
    operacao      VARCHAR(10) NOT NULL,
    id_reserva    BIGINT,
    autor         VARCHAR(100) DEFAULT (USER()),
    momento       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valor_ant     JSON,
    valor_novo    JSON
);

-- Gatilho 1: registra INSERT de reserva
CREATE TRIGGER trg_audit_reserva_ins
AFTER INSERT ON reserva
FOR EACH ROW
INSERT INTO auditoria_reserva (operacao, id_reserva, valor_novo)
VALUES ('INSERT', NEW.id_reserva,
        JSON_OBJECT('id_cliente', NEW.id_cliente,
                    'id_sessao',  NEW.id_sessao,
                    'quantidade', NEW.quantidade,
                    'situacao',   NEW.situacao));

-- Gatilho 2: registra UPDATE de situação da reserva
CREATE TRIGGER trg_audit_reserva_upd
AFTER UPDATE ON reserva
FOR EACH ROW
INSERT INTO auditoria_reserva (operacao, id_reserva, valor_ant, valor_novo)
VALUES ('UPDATE', NEW.id_reserva,
        JSON_OBJECT('situacao', OLD.situacao, 'quantidade', OLD.quantidade),
        JSON_OBJECT('situacao', NEW.situacao, 'quantidade', NEW.quantidade));
""", language="sql")
