-- CineControl | Etapa 2 | 05_otimizacao.sql
-- Estudo de desempenho (B4): EXPLAIN antes e depois de índices para 3 consultas críticas.
USE cinecontrol;

-- ══════════════════════════════════════════════════════════════
-- CONSULTA CRÍTICA 1: Sessões futuras por sala
-- Pergunta de negócio: Quais sessões estão programadas para uma sala específica?
-- ══════════════════════════════════════════════════════════════

-- ANTES do índice (verificar com EXPLAIN):
EXPLAIN SELECT s.id_sessao, f.titulo, s.inicio, s.ingressos_disponiveis
FROM sessao s JOIN filme f ON f.id_filme = s.id_filme
WHERE s.id_sala = 1 AND s.situacao = 'PROGRAMADA'
ORDER BY s.inicio;

-- Criar índice:
-- CREATE INDEX idx_sessao_sala_inicio_sit ON sessao (id_sala, inicio, situacao);
-- (já criado em 04_etapa2.sql)

-- DEPOIS do índice:
EXPLAIN SELECT s.id_sessao, f.titulo, s.inicio, s.ingressos_disponiveis
FROM sessao s JOIN filme f ON f.id_filme = s.id_filme
WHERE s.id_sala = 1 AND s.situacao = 'PROGRAMADA'
ORDER BY s.inicio;

-- ══════════════════════════════════════════════════════════════
-- CONSULTA CRÍTICA 2: Reservas de um cliente por período
-- Pergunta de negócio: Quais reservas confirmadas um cliente fez no último mês?
-- ══════════════════════════════════════════════════════════════

EXPLAIN SELECT r.id_reserva, f.titulo, s.inicio, r.quantidade, r.data_reserva
FROM reserva r
JOIN sessao s ON s.id_sessao = r.id_sessao
JOIN filme  f ON f.id_filme  = s.id_filme
WHERE r.id_cliente = 1
  AND r.situacao   = 'CONFIRMADA'
  AND r.data_reserva BETWEEN '2026-01-01' AND '2026-12-31'
ORDER BY r.data_reserva DESC;

-- Índice: idx_reserva_cli_data_sit ON reserva (id_cliente, data_reserva, situacao)

EXPLAIN SELECT r.id_reserva, f.titulo, s.inicio, r.quantidade, r.data_reserva
FROM reserva r
JOIN sessao s ON s.id_sessao = r.id_sessao
JOIN filme  f ON f.id_filme  = s.id_filme
WHERE r.id_cliente = 1
  AND r.situacao   = 'CONFIRMADA'
  AND r.data_reserva BETWEEN '2026-01-01' AND '2026-12-31'
ORDER BY r.data_reserva DESC;

-- ══════════════════════════════════════════════════════════════
-- CONSULTA CRÍTICA 3: Busca de filmes em cartaz por título
-- Pergunta de negócio: Quais filmes em cartaz contêm determinada palavra no título?
-- ══════════════════════════════════════════════════════════════

EXPLAIN SELECT id_filme, titulo, duracao_min, classificacao
FROM filme
WHERE situacao = 'EM_CARTAZ'
  AND titulo LIKE 'Horizonte%';

-- Índice: idx_filme_titulo_sit ON filme (situacao, titulo)
-- Nota: LIKE 'X%' (prefixado) usa o índice; LIKE '%X%' não usa — documentar isso.

EXPLAIN SELECT id_filme, titulo, duracao_min, classificacao
FROM filme
WHERE situacao = 'EM_CARTAZ'
  AND titulo LIKE 'Horizonte%';
