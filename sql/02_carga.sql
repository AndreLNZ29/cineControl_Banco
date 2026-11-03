-- CineControl | Etapa 1 | 02_carga.sql
-- SGBD: MySQL 8.0+
USE cinecontrol;

-- MySQL não tem generate_series(); usamos uma tabela temporária de números,
-- populada via CTE recursiva, para substituir as gerações da versão PostgreSQL.
DROP TEMPORARY TABLE IF EXISTS numeros;
CREATE TEMPORARY TABLE numeros (n INT PRIMARY KEY);
INSERT INTO numeros (n)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 200
)
SELECT n FROM seq;

INSERT INTO genero (nome) VALUES
('Ação'),('Animação'),('Aventura'),('Comédia'),('Drama'),
('Fantasia'),('Ficção Científica'),('Mistério'),('Romance'),('Suspense');

INSERT INTO usuario (nome, email, senha_hash)
SELECT CONCAT('Cliente ', LPAD(n, 2, '0')),
       CONCAT('cliente', LPAD(n, 2, '0'), '@cinecontrol.local'),
       CONCAT('$2b$12$exemplo_hash_ficticio_cliente_', LPAD(n, 2, '0'))
FROM numeros WHERE n <= 35
UNION ALL
SELECT CONCAT('Administrador ', n),
       CONCAT('admin', n, '@cinecontrol.local'),
       CONCAT('$2b$12$exemplo_hash_ficticio_admin_', n)
FROM numeros WHERE n <= 5;

INSERT INTO cliente (id_usuario, data_cadastro)
SELECT id_usuario, DATE_ADD('2026-01-01', INTERVAL MOD(id_usuario - 1, 180) DAY)
FROM usuario
WHERE email LIKE 'cliente%@cinecontrol.local';

INSERT INTO administrador (id_usuario, nivel_acesso)
SELECT id_usuario,
       CASE WHEN MOD(id_usuario, 2) = 0 THEN 'GESTOR' ELSE 'OPERACIONAL' END
FROM usuario
WHERE email LIKE 'admin%@cinecontrol.local';

INSERT INTO filme (titulo, descricao, duracao_min, classificacao, data_lancamento, situacao) VALUES
('Horizonte de Neon','Uma equipe tenta impedir um apagão em uma cidade futurista.',118,'12','2026-01-15','EM_CARTAZ'),
('O Último Farol','Um faroleiro encontra sinais de uma embarcação desaparecida.',105,'10','2025-12-10','EM_CARTAZ'),
('Código Aurora','Cientistas investigam uma transmissão vinda do espaço.',127,'12','2026-02-20','EM_CARTAZ'),
('Entre Dois Mundos','Uma família atravessa uma fronteira entre realidades.',121,'10','2025-11-18','EM_CARTAZ'),
('Cidade de Papel','Uma jornalista reconstrói histórias de um bairro em transformação.',109,'L','2026-03-05','EM_CARTAZ'),
('Rota 47','Dois irmãos percorrem uma estrada em busca de reconciliação.',114,'12','2026-02-01','EM_CARTAZ'),
('O Jardim das Sombras','Uma restauradora descobre segredos em uma antiga propriedade.',116,'14','2025-10-09','EM_CARTAZ'),
('Maré Alta','Uma equipe de resgate enfrenta uma tempestade costeira.',102,'12','2026-01-29','EM_CARTAZ'),
('Estação Central','Encontros inesperados mudam a rotina de passageiros.',98,'L','2025-09-22','EM_CARTAZ'),
('A Máquina de Ícaro','Um inventor cria uma máquina capaz de alterar pequenos eventos.',132,'10','2026-03-19','EM_CARTAZ'),
('Luzes do Norte','Fotógrafos viajam em busca de um fenômeno raro.',101,'L','2025-12-01','EM_CARTAZ'),
('O Enigma do Lago','Uma investigadora retorna à cidade natal para solucionar um caso.',123,'14','2026-01-11','EM_CARTAZ'),
('Depois da Chuva','Vizinhos reorganizam suas vidas após uma grande tempestade.',106,'12','2025-08-15','EM_CARTAZ'),
('Planeta Íris','Uma missão científica encontra vida em um planeta distante.',129,'10','2026-02-12','EM_CARTAZ'),
('Cartas para Ontem','Uma escritora recebe cartas enviadas décadas antes.',111,'L','2025-07-30','EM_CARTAZ'),
('Ventos de Setembro','Uma atleta retorna à cidade para competir novamente.',104,'L','2026-03-02','EM_CARTAZ'),
('O Som do Silêncio','Um músico redescobre a criatividade após perder a audição.',119,'10','2025-06-12','EM_CARTAZ'),
('A Casa do Relógio','Irmãos investigam fenômenos estranhos em uma casa antiga.',125,'12','2026-01-27','EM_CARTAZ'),
('Pequenos Gigantes','Uma equipe infantil disputa um campeonato local.',97,'L','2025-09-03','EM_CARTAZ'),
('Nuvem de Vidro','Uma arquiteta enfrenta escolhas pessoais durante uma grande obra.',108,'10','2026-02-27','EM_CARTAZ'),
('Além da Linha Azul','Uma viagem de trem conecta pessoas de diferentes gerações.',115,'L','2025-05-21','EM_CARTAZ'),
('O Mapa Invisível','Um cartógrafo encontra uma cidade ausente dos mapas.',128,'12','2026-03-11','EM_CARTAZ'),
('Frequência 9','Um programa de rádio recebe mensagens de origem desconhecida.',110,'14','2025-11-02','EM_CARTAZ'),
('A Última Fotografia','Uma fotógrafa procura a origem de uma imagem sem autoria.',103,'10','2026-01-08','EM_CARTAZ'),
('Sete Minutos','Um motorista tem uma última chance para corrigir um erro.',99,'12','2025-10-17','EM_CARTAZ'),
('Oceano de Dentro','Uma bióloga pesquisa sons misteriosos em alto-mar.',126,'L','2026-02-05','EM_CARTAZ'),
('Manual do Amanhã','Um estudante encontra um manual que descreve o futuro próximo.',107,'10','2026-03-22','EM_CARTAZ'),
('Asas de Concreto','Uma engenheira lidera um projeto urbano experimental.',120,'12','2025-12-19','EM_CARTAZ'),
('A Ponte de Inverno','Uma cidade isolada precisa reconstruir sua única ponte.',112,'10','2026-01-19','EM_CARTAZ'),
('Vizinhos do Tempo','Dois apartamentos passam a compartilhar o mesmo dia.',101,'L','2025-09-28','EM_CARTAZ'),
('O Arquivo Azul','Um arquivista descobre documentos sobre uma operação esquecida.',117,'14','2026-02-16','EM_CARTAZ'),
('Céu de Agosto','Amigos planejam observar uma chuva de meteoros.',95,'L','2025-08-08','EM_CARTAZ'),
('A Cidade Submersa','Arqueólogos exploram estruturas sob um reservatório.',130,'12','2026-01-31','EM_CARTAZ'),
('Noite de Estreia','Uma companhia teatral enfrenta imprevistos antes da estreia.',100,'L','2025-11-25','EM_CARTAZ'),
('A Última Página','Um livreiro procura o final de um manuscrito perdido.',113,'10','2026-03-14','EM_CARTAZ'),
('Horizonte de Neon 2','A equipe retorna para investigar uma nova ameaça.',124,'12','2026-04-10','FUTURO'),
('O Último Farol: Retorno','Novos sinais chegam à costa anos depois.',110,'10','2026-04-20','FUTURO'),
('Código Aurora: Sinal','Uma segunda transmissão amplia o mistério científico.',131,'12','2026-05-02','FUTURO'),
('Planeta Íris: Expedição','A missão retorna ao planeta para continuar a pesquisa.',136,'10','2026-05-15','FUTURO');

UPDATE filme SET id_filme_origem = 1 WHERE id_filme = 36;
UPDATE filme SET id_filme_origem = 2 WHERE id_filme = 37;
UPDATE filme SET id_filme_origem = 3 WHERE id_filme = 38;
UPDATE filme SET id_filme_origem = 14 WHERE id_filme = 39;

INSERT INTO ator (nome, data_nascimento)
SELECT CONCAT('Ator ', LPAD(n, 2, '0')),
       DATE_ADD('1975-01-01', INTERVAL MOD(n * 211, 15000) DAY)
FROM numeros WHERE n <= 40;

INSERT INTO filme_genero (id_filme, id_genero, principal)
SELECT f.id_filme, MOD(f.id_filme - 1, 10) + 1, TRUE
FROM filme f;

INSERT INTO filme_genero (id_filme, id_genero, principal)
SELECT f.id_filme, MOD(f.id_filme + 2, 10) + 1, FALSE
FROM filme f
WHERE MOD(f.id_filme, 3) = 0;

INSERT INTO filme_ator (id_filme, id_ator, personagem, ordem_credito)
SELECT f.id_filme, MOD(f.id_filme - 1, 40) + 1,
       CONCAT('Personagem ', f.id_filme), 1
FROM filme f;

INSERT INTO filme_ator (id_filme, id_ator, personagem, ordem_credito)
SELECT f.id_filme, MOD(f.id_filme + 6, 40) + 1,
       CONCAT('Personagem secundário ', f.id_filme), 2
FROM filme f;

INSERT INTO sala (nome_numero, capacidade, situacao)
SELECT CONCAT('Sala ', n), 20, 'ATIVA'
FROM numeros WHERE n <= 10;

INSERT INTO assento (id_sala, numero, fileira, ativo)
SELECT s.id_sala, num.n, CHAR(65 + FLOOR((num.n - 1) / 10)), TRUE
FROM sala s
CROSS JOIN numeros num
WHERE num.n <= 20;

-- Observação: a base original usava MOD(n-1, 40), mas só existem 39 filmes
-- cadastrados (ids 1..39); com 40 o cálculo gerava id_filme = 40 a cada 40
-- sessões e violava a FK fk_sessao_filme (o mesmo aconteceria no PostgreSQL
-- original). Ajustado aqui para MOD(n-1, 39).
INSERT INTO sessao (id_filme, id_sala, inicio, preco, ingressos_disponiveis, situacao)
SELECT MOD(n - 1, 39) + 1,
       MOD(n - 1, 10) + 1,
       TIMESTAMP('2026-10-01 10:00:00')
           + INTERVAL FLOOR((n - 1) / 10) DAY
           + INTERVAL (MOD(n - 1, 5) * 3) HOUR,
       CASE WHEN MOD(n, 4) = 0 THEN 32.00 WHEN MOD(n, 3) = 0 THEN 28.00 ELSE 25.00 END,
       20,
       'PROGRAMADA'
FROM numeros WHERE n <= 120;

INSERT INTO reserva (id_cliente, id_sessao, quantidade, data_reserva, situacao)
SELECT MOD(n - 1, 35) + 1,
       MOD(n - 1, 120) + 1,
       1 + MOD(n, 4),
       TIMESTAMP('2026-09-01 09:00:00') + INTERVAL (n * 2) HOUR,
       CASE WHEN MOD(n, 17) = 0 THEN 'CANCELADA' ELSE 'CONFIRMADA' END
FROM numeros WHERE n <= 200;

UPDATE sessao s
SET ingressos_disponiveis =
    20 - COALESCE((
        SELECT SUM(r.quantidade)
        FROM reserva r
        WHERE r.id_sessao = s.id_sessao
          AND r.situacao = 'CONFIRMADA'
    ), 0);

INSERT INTO historico_situacao_filme (id_filme, sequencia, situacao, inicio, fim)
SELECT id_filme, 1, 'FUTURO',
       DATE_SUB(CAST(data_lancamento AS DATETIME), INTERVAL 30 DAY),
       CAST(data_lancamento AS DATETIME)
FROM filme
WHERE data_lancamento >= '2026-04-01';

INSERT INTO historico_situacao_filme (id_filme, sequencia, situacao, inicio, fim)
SELECT id_filme, 2, situacao,
       CAST(data_lancamento AS DATETIME), NULL
FROM filme
WHERE data_lancamento < '2026-04-01';

DROP TEMPORARY TABLE IF EXISTS numeros;
