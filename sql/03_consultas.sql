-- CineControl | Etapa 1 | 03_consultas.sql
-- SGBD: MySQL 8.0+
USE cinecontrol;

-- 01. Quais filmes estão atualmente em cartaz?
SELECT id_filme, titulo, classificacao, duracao_min
FROM filme WHERE situacao = 'EM_CARTAZ'
ORDER BY titulo;

-- 02. Quais filmes têm duração entre 100 e 120 minutos?
SELECT id_filme, titulo, duracao_min
FROM filme WHERE duracao_min BETWEEN 100 AND 120
ORDER BY duracao_min, titulo;

-- 03. Quais filmes possuem "Aurora" ou "Neon" no título?
-- (MySQL não tem ILIKE; LIKE já é case-insensitive com a collation utf8mb4_unicode_ci)
SELECT id_filme, titulo
FROM filme
WHERE titulo LIKE '%Aurora%' OR titulo LIKE '%Neon%'
ORDER BY titulo;

-- 04. Quais sessões ocorrerão nas salas 1, 2 ou 3?
SELECT id_sessao, id_sala, inicio, preco
FROM sessao WHERE id_sala IN (1,2,3)
ORDER BY inicio;

-- 05. Quais filmes ainda não possuem descrição?
SELECT id_filme, titulo
FROM filme WHERE descricao IS NULL
ORDER BY titulo;

-- 06. Quais filmes e seus gêneros principais estão programados?
SELECT f.titulo, g.nome AS genero_principal, COUNT(s.id_sessao) AS qtd_sessoes
FROM filme f
JOIN filme_genero fg ON fg.id_filme = f.id_filme AND fg.principal = TRUE
JOIN genero g ON g.id_genero = fg.id_genero
LEFT JOIN sessao s ON s.id_filme = f.id_filme
GROUP BY f.id_filme, f.titulo, g.nome
ORDER BY qtd_sessoes DESC, f.titulo;

-- 07. Quais clientes possuem reservas e quantas?
SELECT u.nome, COUNT(r.id_reserva) AS qtd_reservas
FROM cliente c
JOIN usuario u ON u.id_usuario = c.id_usuario
LEFT JOIN reserva r ON r.id_cliente = c.id_usuario
GROUP BY c.id_usuario, u.nome
ORDER BY qtd_reservas DESC, u.nome;

-- 08. Quais salas possuem mais de 10 sessões programadas?
SELECT sa.nome_numero, COUNT(s.id_sessao) AS qtd_sessoes
FROM sala sa
JOIN sessao s ON s.id_sala = sa.id_sala
WHERE s.situacao = 'PROGRAMADA'
GROUP BY sa.id_sala, sa.nome_numero
HAVING COUNT(s.id_sessao) > 10
ORDER BY qtd_sessoes DESC;

-- 09. Mostre filme, sala e horário das próximas sessões.
SELECT f.titulo, sa.nome_numero, s.inicio, s.preco
FROM sessao s
JOIN filme f ON f.id_filme = s.id_filme
JOIN sala sa ON sa.id_sala = s.id_sala
WHERE s.inicio >= CURRENT_TIMESTAMP
ORDER BY s.inicio
LIMIT 20;

-- 10. Quantos ingressos confirmados cada sessão já possui?
SELECT s.id_sessao, f.titulo, s.inicio,
       COALESCE(SUM(CASE WHEN r.situacao = 'CONFIRMADA' THEN r.quantidade ELSE 0 END),0)
       AS ingressos_reservados
FROM sessao s
JOIN filme f ON f.id_filme = s.id_filme
LEFT JOIN reserva r ON r.id_sessao = s.id_sessao
GROUP BY s.id_sessao, f.titulo, s.inicio
ORDER BY ingressos_reservados DESC, s.id_sessao;

-- 11. Quais clientes fizeram mais reservas que a média de reservas por cliente?
SELECT u.nome, COUNT(r.id_reserva) AS qtd_reservas
FROM cliente c
JOIN usuario u ON u.id_usuario = c.id_usuario
JOIN reserva r ON r.id_cliente = c.id_usuario
GROUP BY c.id_usuario, u.nome
HAVING COUNT(r.id_reserva) > (
    SELECT AVG(qtd)
    FROM (
        SELECT c2.id_usuario, COUNT(r2.id_reserva) AS qtd
        FROM cliente c2
        LEFT JOIN reserva r2 ON r2.id_cliente = c2.id_usuario
        GROUP BY c2.id_usuario
    ) AS medias
)
ORDER BY qtd_reservas DESC;

-- 12. Quais filmes possuem pelo menos uma reserva confirmada? (EXISTS)
SELECT f.id_filme, f.titulo
FROM filme f
WHERE EXISTS (
    SELECT 1
    FROM sessao s
    JOIN reserva r ON r.id_sessao = s.id_sessao
    WHERE s.id_filme = f.id_filme
      AND r.situacao = 'CONFIRMADA'
)
ORDER BY f.titulo;

-- 13. Quais sessões têm ocupação acima da média geral?
SELECT f.titulo, s.id_sessao,
       ROUND(
         (SUM(CASE WHEN r.situacao = 'CONFIRMADA' THEN r.quantidade ELSE 0 END)
          / NULLIF(sa.capacidade,0)) * 100, 2
       ) AS ocupacao_percentual
FROM sessao s
JOIN filme f ON f.id_filme = s.id_filme
JOIN sala sa ON sa.id_sala = s.id_sala
LEFT JOIN reserva r ON r.id_sessao = s.id_sessao
GROUP BY f.titulo, s.id_sessao, sa.capacidade
HAVING (
  SUM(CASE WHEN r.situacao = 'CONFIRMADA' THEN r.quantidade ELSE 0 END)
  / NULLIF(sa.capacidade,0)
) > (
  SELECT AVG(ocupacao)
  FROM (
    SELECT s2.id_sessao,
           SUM(CASE WHEN r2.situacao = 'CONFIRMADA' THEN r2.quantidade ELSE 0 END)
           / NULLIF(sa2.capacidade,0) AS ocupacao
    FROM sessao s2
    JOIN sala sa2 ON sa2.id_sala = s2.id_sala
    LEFT JOIN reserva r2 ON r2.id_sessao = s2.id_sessao
    GROUP BY s2.id_sessao, sa2.capacidade
  ) AS ocupacoes
)
ORDER BY ocupacao_percentual DESC;

-- 14. Quais clientes reservaram ingressos para mais de um filme diferente?
SELECT u.nome, COUNT(DISTINCT s.id_filme) AS filmes_diferentes
FROM cliente c
JOIN usuario u ON u.id_usuario = c.id_usuario
JOIN reserva r ON r.id_cliente = c.id_usuario
JOIN sessao s ON s.id_sessao = r.id_sessao
WHERE r.situacao = 'CONFIRMADA'
GROUP BY c.id_usuario, u.nome
HAVING COUNT(DISTINCT s.id_filme) > 1
ORDER BY filmes_diferentes DESC, u.nome;

-- 15. Quais salas apresentam menor disponibilidade média nas sessões programadas?
SELECT sa.nome_numero,
       ROUND(AVG(s.ingressos_disponiveis), 2) AS disponibilidade_media,
       COUNT(*) AS sessoes
FROM sala sa
JOIN sessao s ON s.id_sala = sa.id_sala
WHERE s.situacao = 'PROGRAMADA'
GROUP BY sa.id_sala, sa.nome_numero
ORDER BY disponibilidade_media ASC, sa.nome_numero
LIMIT 3;
