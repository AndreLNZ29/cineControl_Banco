"""
CineControl - Camada de acesso ao banco de dados
Usa prepared statements (parameterized queries) em todas as operações.
Credenciais lidas de variáveis de ambiente ou arquivo .env (nunca hardcoded).
"""

import os
from pathlib import Path
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv

# Resolva o .env ao lado deste módulo, independentemente do diretório de
# onde o Streamlit foi iniciado. Variáveis já definidas no sistema prevalecem.
load_dotenv(dotenv_path=Path(__file__).with_name(".env"), override=False)

def get_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", "1987"),
        database=os.getenv("DB_NAME", "cinecontrol"),
        charset="utf8mb4",
        autocommit=False,
    )

def execute_query(sql, params=None, fetch=True):
    """Executa uma consulta parametrizada e retorna os resultados."""
    conn = get_connection()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, params or ())
        if fetch:
            return cur.fetchall()
        conn.commit()
        return cur.lastrowid
    except Error as e:
        conn.rollback()
        raise e
    finally:
        conn.close()

def execute_transaction(operations):
    """
    Executa múltiplas operações em uma única transação explícita.
    operations: lista de (sql, params)
    Retorna lista de lastrowid para cada operação.
    """
    conn = get_connection()
    results = []
    try:
        cur = conn.cursor(dictionary=True)
        conn.start_transaction()
        for sql, params in operations:
            cur.execute(sql, params or ())
            results.append(cur.lastrowid)
        conn.commit()
        return results
    except Error as e:
        conn.rollback()
        raise e
    finally:
        conn.close()
