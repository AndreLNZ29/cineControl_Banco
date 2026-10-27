-- CineControl | Etapa 2 | 04_etapa2.sql
-- Execute após 01_ddl.sql e 02_carga.sql (em base cinecontrol já existente).
-- Contém: view de relatório, gatilhos de auditoria, perfis de acesso, índices adicionais.
USE cinecontrol;

-- ══════════════════════════════════════════════════════════════
-- 1. VIEW de relatório consolidado (alimenta o Painel da aplicação)
-- ══════════════════════════════════════════════════════════════
CREATE OR REPLACE VIEW vw_relatorio_sessoes AS
SELECT
    f.titulo               AS filme,
    f.classificacao,
    s.inicio               AS horario,
    sa.nome_numero         AS sala,
    s.preco,
    s.ingressos_disponiveis,
    s.situacao             AS situacao_sessao,
    COUNT(r.id_reserva)    AS total_reservas,
    COALESCE(SUM(r.quantidade), 0) AS ingressos_vendidos
FROM sessao s
JOIN filme  f  ON f.id_filme  = s.id_filme
JOIN sala   sa ON sa.id_sala  = s.id_sala
LEFT JOIN reserva r ON r.id_sessao = s.id_sessao AND r.situacao = 'CONFIRMADA'
GROUP BY s.id_sessao, f.titulo, f.classificacao,
         s.inicio, sa.nome_numero, s.preco, s.ingressos_disponiveis, s.situacao;

-- View pública (restringe colunas sensíveis — usada pelo perfil cc_leitura)
CREATE OR REPLACE VIEW vw_filmes_publico AS
SELECT id_filme, titulo, duracao_min, classificacao, data_lancamento
FROM filme
WHERE situacao = 'EM_CARTAZ';

-- ══════════════════════════════════════════════════════════════
-- 2. TABELA DE AUDITORIA
-- ══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS auditoria_reserva (
    id_auditoria BIGINT AUTO_INCREMENT,
    operacao     VARCHAR(10)  NOT NULL,          -- INSERT | UPDATE
    id_reserva   BIGINT,
    autor        VARCHAR(100) DEFAULT (USER()),
    momento      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_ant    JSON,
    valor_novo   JSON,
    CONSTRAINT pk_auditoria PRIMARY KEY (id_auditoria)
) ENGINE=InnoDB;

-- ══════════════════════════════════════════════════════════════
-- 3. GATILHOS DE AUDITORIA
-- Justificativa: reserva é o evento central do domínio;
-- registrar inserções e cancelamentos garante rastreabilidade
-- de ingressos e eventual resolução de disputas.
-- ══════════════════════════════════════════════════════════════
DROP TRIGGER IF EXISTS trg_audit_reserva_ins;
DELIMITER $$
CREATE TRIGGER trg_audit_reserva_ins
AFTER INSERT ON reserva
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_reserva (operacao, id_reserva, valor_novo)
    VALUES (
        'INSERT',
        NEW.id_reserva,
        JSON_OBJECT(
            'id_cliente', NEW.id_cliente,
            'id_sessao',  NEW.id_sessao,
            'quantidade', NEW.quantidade,
            'situacao',   NEW.situacao
        )
    );
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_audit_reserva_upd;
DELIMITER $$
CREATE TRIGGER trg_audit_reserva_upd
AFTER UPDATE ON reserva
FOR EACH ROW
BEGIN
    IF OLD.situacao <> NEW.situacao OR OLD.quantidade <> NEW.quantidade THEN
        INSERT INTO auditoria_reserva (operacao, id_reserva, valor_ant, valor_novo)
        VALUES (
            'UPDATE',
            NEW.id_reserva,
            JSON_OBJECT('situacao', OLD.situacao, 'quantidade', OLD.quantidade),
            JSON_OBJECT('situacao', NEW.situacao, 'quantidade', NEW.quantidade)
        );
    END IF;
END$$
DELIMITER ;

-- ══════════════════════════════════════════════════════════════
-- 4. ÍNDICES ADICIONAIS (otimização de consultas críticas)
-- ══════════════════════════════════════════════════════════════
-- Consulta crítica 1: sessões futuras por sala
CREATE INDEX IF NOT EXISTS idx_sessao_sala_inicio_sit
    ON sessao (id_sala, inicio, situacao);

-- Consulta crítica 2: reservas por cliente em período
CREATE INDEX IF NOT EXISTS idx_reserva_cli_data_sit
    ON reserva (id_cliente, data_reserva, situacao);

-- Consulta crítica 3: título de filmes em cartaz (LIKE prefixado)
CREATE INDEX IF NOT EXISTS idx_filme_titulo_sit
    ON filme (situacao, titulo);

-- ══════════════════════════════════════════════════════════════
-- 5. PERFIS DE ACESSO (menor privilégio)
-- ══════════════════════════════════════════════════════════════
-- Perfil 1: leitura pública (frontend não autenticado)
CREATE USER IF NOT EXISTS 'cc_leitura'@'localhost'
    IDENTIFIED BY 'LeituraSenha#2026';
GRANT SELECT ON cinecontrol.vw_filmes_publico   TO 'cc_leitura'@'localhost';
GRANT SELECT ON cinecontrol.vw_relatorio_sessoes TO 'cc_leitura'@'localhost';

-- Perfil 2: operacional (atendente — reserva e consultas)
CREATE USER IF NOT EXISTS 'cc_operacional'@'localhost'
    IDENTIFIED BY 'OperSenha#2026';
GRANT SELECT ON cinecontrol.*                    TO 'cc_operacional'@'localhost';
GRANT INSERT, UPDATE ON cinecontrol.reserva      TO 'cc_operacional'@'localhost';
GRANT UPDATE ON cinecontrol.sessao               TO 'cc_operacional'@'localhost';

-- Perfil 3: gestor (DML completo, sem DDL)
CREATE USER IF NOT EXISTS 'cc_gestor'@'localhost'
    IDENTIFIED BY 'GestorSenha#2026';
GRANT SELECT, INSERT, UPDATE, DELETE ON cinecontrol.* TO 'cc_gestor'@'localhost';

FLUSH PRIVILEGES;

-- ══════════════════════════════════════════════════════════════
-- 6. EXEMPLO DE TRANSAÇÃO DOCUMENTADA
-- (para incluir no relatório como evidência de B3)
-- ══════════════════════════════════════════════════════════════

-- TRANSAÇÃO DE SUCESSO:
-- START TRANSACTION;
-- INSERT INTO reserva (id_cliente, id_sessao, quantidade)
--     VALUES (1, 1, 2);                              -- RN09
-- UPDATE sessao
--     SET ingressos_disponiveis = ingressos_disponiveis - 2
--     WHERE id_sessao = 1;                           -- RN10
-- COMMIT;

-- TRANSAÇÃO COM FALHA (banco permanece íntegro):
-- START TRANSACTION;
-- INSERT INTO reserva (id_cliente, id_sessao, quantidade) VALUES (1, 1, 1);
-- UPDATE sessao SET ingressos_disponiveis = -9999 WHERE id_sessao = 1;
--   --> viola ck_sessao_disponibilidade → erro → ROLLBACK automático da app
-- ROLLBACK;
