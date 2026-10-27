-- CineControl | seed_completa.sql
-- Substitui (ou complementa) a carga original com dados muito mais ricos.
-- Execute em ordem: 01_ddl.sql → este arquivo → 04_etapa2.sql → seed_etapa2.sql (opcional)
--
-- Para rodar do zero:
--   mysql -u root -p cinecontrol < seed_completa.sql
-- Para rodar sobre banco já populado (sem DROP):
--   Comente as linhas TRUNCATE abaixo.
USE cinecontrol;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE historico_situacao_filme;
TRUNCATE TABLE auditoria_reserva;
TRUNCATE TABLE reserva;
TRUNCATE TABLE sessao;
TRUNCATE TABLE assento;
TRUNCATE TABLE sala;
TRUNCATE TABLE filme_ator;
TRUNCATE TABLE filme_genero;
TRUNCATE TABLE ator;
TRUNCATE TABLE filme;
TRUNCATE TABLE administrador;
TRUNCATE TABLE cliente;
TRUNCATE TABLE usuario;
TRUNCATE TABLE genero;
SET FOREIGN_KEY_CHECKS = 1;

-- ══════════════════════════════════════════════════════════════
-- GÊNEROS
-- ══════════════════════════════════════════════════════════════
INSERT INTO genero (nome) VALUES
('Ação'),('Animação'),('Aventura'),('Comédia'),('Drama'),
('Fantasia'),('Ficção Científica'),('Mistério'),('Romance'),('Suspense'),
('Terror'),('Documentário');

-- ══════════════════════════════════════════════════════════════
-- USUÁRIOS — 40 clientes + 5 admins
-- ══════════════════════════════════════════════════════════════
INSERT INTO usuario (nome, email, senha_hash, ativo) VALUES
('Alice Ferreira',    'alice@cinecontrol.local',    '$2b$12$hash_alice',    TRUE),
('Bruno Carvalho',    'bruno@cinecontrol.local',    '$2b$12$hash_bruno',    TRUE),
('Camila Souza',      'camila@cinecontrol.local',   '$2b$12$hash_camila',   TRUE),
('Diego Rocha',       'diego@cinecontrol.local',    '$2b$12$hash_diego',    TRUE),
('Elena Martins',     'elena@cinecontrol.local',    '$2b$12$hash_elena',    TRUE),
('Felipe Lima',       'felipe@cinecontrol.local',   '$2b$12$hash_felipe',   TRUE),
('Gabriela Nunes',    'gabriela@cinecontrol.local', '$2b$12$hash_gabriela', TRUE),
('Henrique Alves',    'henrique@cinecontrol.local', '$2b$12$hash_henrique', TRUE),
('Isabela Costa',     'isabela@cinecontrol.local',  '$2b$12$hash_isabela',  TRUE),
('João Pedro',        'joao@cinecontrol.local',     '$2b$12$hash_joao',     TRUE),
('Karen Oliveira',    'karen@cinecontrol.local',    '$2b$12$hash_karen',    TRUE),
('Lucas Pereira',     'lucas@cinecontrol.local',    '$2b$12$hash_lucas',    TRUE),
('Mariana Torres',    'mariana@cinecontrol.local',  '$2b$12$hash_mariana',  TRUE),
('Nathan Silva',      'nathan@cinecontrol.local',   '$2b$12$hash_nathan',   TRUE),
('Olivia Ramos',      'olivia@cinecontrol.local',   '$2b$12$hash_olivia',   TRUE),
('Paulo Melo',        'paulo@cinecontrol.local',    '$2b$12$hash_paulo',    TRUE),
('Queila Barbosa',    'queila@cinecontrol.local',   '$2b$12$hash_queila',   TRUE),
('Rafael Gomes',      'rafael@cinecontrol.local',   '$2b$12$hash_rafael',   TRUE),
('Sara Mendes',       'sara@cinecontrol.local',     '$2b$12$hash_sara',     TRUE),
('Thiago Freitas',    'thiago@cinecontrol.local',   '$2b$12$hash_thiago',   TRUE),
('Ursula Campos',     'ursula@cinecontrol.local',   '$2b$12$hash_ursula',   TRUE),
('Vitor Araújo',      'vitor@cinecontrol.local',    '$2b$12$hash_vitor',    TRUE),
('Wanda Figueiredo',  'wanda@cinecontrol.local',    '$2b$12$hash_wanda',    TRUE),
('Xavier Pinto',      'xavier@cinecontrol.local',   '$2b$12$hash_xavier',   TRUE),
('Yasmin Correia',    'yasmin@cinecontrol.local',   '$2b$12$hash_yasmin',   TRUE),
('Zoe Cavalcante',    'zoe@cinecontrol.local',      '$2b$12$hash_zoe',      TRUE),
('André Nascimento',  'andre@cinecontrol.local',    '$2b$12$hash_andre',    TRUE),
('Beatriz Moreira',   'beatriz@cinecontrol.local',  '$2b$12$hash_beatriz',  TRUE),
('Caio Teixeira',     'caio@cinecontrol.local',     '$2b$12$hash_caio',     TRUE),
('Daniela Vieira',    'daniela@cinecontrol.local',  '$2b$12$hash_daniela',  TRUE),
('Eduardo Batista',   'eduardo@cinecontrol.local',  '$2b$12$hash_eduardo',  TRUE),
('Flávia Cunha',      'flavia@cinecontrol.local',   '$2b$12$hash_flavia',   TRUE),
('Gustavo Lopes',     'gustavo@cinecontrol.local',  '$2b$12$hash_gustavo',  TRUE),
('Helena Dias',       'helena@cinecontrol.local',   '$2b$12$hash_helena',   TRUE),
('Igor Cardoso',      'igor@cinecontrol.local',     '$2b$12$hash_igor',     FALSE),
-- Admins
('Admin Geral',       'admin@cinecontrol.local',    '$2b$12$hash_admin1',   TRUE),
('Admin Operacional', 'operacional@cinecontrol.local','$2b$12$hash_admin2', TRUE),
('Gestor Paulo',      'gestor@cinecontrol.local',   '$2b$12$hash_admin3',   TRUE),
('Suporte Ana',       'suporte@cinecontrol.local',  '$2b$12$hash_admin4',   TRUE),
('TI Rafael',         'ti@cinecontrol.local',       '$2b$12$hash_admin5',   TRUE);

INSERT INTO cliente (id_usuario, data_cadastro)
SELECT id_usuario,
       DATE_SUB(CURDATE(), INTERVAL MOD(id_usuario * 7, 365) DAY)
FROM usuario WHERE email NOT LIKE '%admin%'
  AND email NOT LIKE '%operacional%'
  AND email NOT LIKE '%gestor%'
  AND email NOT LIKE '%suporte%'
  AND email NOT LIKE '%ti@%';

INSERT INTO administrador (id_usuario, nivel_acesso)
SELECT id_usuario,
       CASE WHEN email IN ('admin@cinecontrol.local','gestor@cinecontrol.local')
            THEN 'GESTOR' ELSE 'OPERACIONAL' END
FROM usuario
WHERE email IN (
    'admin@cinecontrol.local','operacional@cinecontrol.local',
    'gestor@cinecontrol.local','suporte@cinecontrol.local','ti@cinecontrol.local'
);

-- ══════════════════════════════════════════════════════════════
-- ATORES
-- ══════════════════════════════════════════════════════════════
INSERT INTO ator (nome, data_nascimento) VALUES
('Ana Paula Souza',    '1985-03-12'),
('Carlos Henrique',    '1979-07-04'),
('Fernanda Lima',      '1990-11-22'),
('Rafael Torres',      '1982-05-18'),
('Júlia Alves',        '1995-02-28'),
('Marcos Vinicius',    '1975-09-09'),
('Patrícia Costa',     '1988-12-01'),
('Diego Esteves',      '2000-06-15'),
('Letícia Faria',      '1993-04-07'),
('Bruno Carvalho',     '1980-08-30'),
('Natalia Pontes',     '1997-01-19'),
('Samuel Ribeiro',     '1983-10-25'),
('Camila Braga',       '1991-07-31'),
('Pedro Henrique',     '1976-12-03'),
('Giovanna Melo',      '1999-05-14');

-- ══════════════════════════════════════════════════════════════
-- FILMES
-- ══════════════════════════════════════════════════════════════
INSERT INTO filme (titulo, descricao, duracao_min, classificacao, data_lancamento, situacao) VALUES
-- Em cartaz (estreias recentes)
('Horizonte de Neon',        'Uma equipe tenta impedir um apagão em uma cidade futurista.',                118,'12','2026-09-15','EM_CARTAZ'),
('O Último Farol',           'Um faroleiro encontra sinais de uma embarcação desaparecida.',               105,'10','2026-09-20','EM_CARTAZ'),
('Código Aurora',            'Cientistas investigam uma transmissão vinda do espaço.',                     127,'12','2026-10-01','EM_CARTAZ'),
('Entre Dois Mundos',        'Uma família atravessa uma fronteira entre realidades.',                      121,'10','2026-10-05','EM_CARTAZ'),
('Cidade de Papel',          'Uma jornalista reconstrói histórias de um bairro em transformação.',         109,'L', '2026-10-08','EM_CARTAZ'),
('Rota 47',                  'Dois irmãos percorrem uma estrada em busca de reconciliação.',               114,'12','2026-10-10','EM_CARTAZ'),
('O Jardim das Sombras',     'Uma restauradora descobre segredos em uma antiga propriedade.',              116,'14','2026-10-12','EM_CARTAZ'),
('Maré Alta',                'Uma equipe de resgate enfrenta uma tempestade costeira.',                    102,'12','2026-10-15','EM_CARTAZ'),
('Estação Central',          'Encontros inesperados mudam a rotina de passageiros.',                        98,'L', '2026-10-17','EM_CARTAZ'),
('A Máquina de Ícaro',       'Um inventor cria uma máquina capaz de alterar pequenos eventos.',            132,'10','2026-10-19','EM_CARTAZ'),
('Luzes do Norte',           'Fotógrafos viajam em busca de um fenômeno raro.',                           101,'L', '2026-10-20','EM_CARTAZ'),
('O Enigma do Lago',         'Uma investigadora retorna à cidade natal para solucionar um caso.',          123,'14','2026-10-22','EM_CARTAZ'),
('Planeta Íris',             'Uma missão científica encontra vida em um planeta distante.',                129,'10','2026-10-23','EM_CARTAZ'),
('Cartas para Ontem',        'Uma escritora recebe cartas enviadas décadas antes.',                        111,'L', '2026-10-24','EM_CARTAZ'),
('Ventos de Setembro',       'Uma atleta retorna à cidade para competir novamente.',                       104,'L', '2026-10-25','EM_CARTAZ'),
('O Som do Silêncio',        'Um músico redescobre a criatividade após perder a audição.',                 119,'10','2026-10-25','EM_CARTAZ'),
('A Casa do Relógio',        'Irmãos investigam fenômenos estranhos em uma casa antiga.',                  125,'12','2026-10-26','EM_CARTAZ'),
('Pequenos Gigantes',        'Uma equipe infantil disputa um campeonato local.',                            97,'L', '2026-10-26','EM_CARTAZ'),
-- Em breve
('Horizonte de Neon 2',      'A equipe retorna para investigar uma nova ameaça.',                          124,'12','2026-11-10','FUTURO'),
('O Último Farol: Retorno',  'Novos sinais chegam à costa anos depois.',                                   110,'10','2026-11-15','FUTURO'),
('Código Aurora: Sinal',     'Uma segunda transmissão amplia o mistério científico.',                      131,'12','2026-11-20','FUTURO'),
('Planeta Íris: Expedição',  'A missão retorna ao planeta para continuar a pesquisa.',                     136,'10','2026-12-05','FUTURO'),
-- Encerrados
('Depois da Chuva',          'Vizinhos reorganizam suas vidas após uma grande tempestade.',                106,'12','2026-06-01','ENCERRADO'),
('Além da Linha Azul',       'Uma viagem de trem conecta pessoas de diferentes gerações.',                 115,'L', '2026-07-10','ENCERRADO'),
('Frequência 9',             'Um programa de rádio recebe mensagens de origem desconhecida.',              110,'14','2026-08-05','ENCERRADO');

-- Sequências (autorrelacionamento)
UPDATE filme SET id_filme_origem = 1 WHERE id_filme = 19;
UPDATE filme SET id_filme_origem = 2 WHERE id_filme = 20;
UPDATE filme SET id_filme_origem = 3 WHERE id_filme = 21;
UPDATE filme SET id_filme_origem = 13 WHERE id_filme = 22;

-- ══════════════════════════════════════════════════════════════
-- GÊNEROS DOS FILMES
-- ══════════════════════════════════════════════════════════════
INSERT INTO filme_genero (id_filme, id_genero, principal) VALUES
(1,  7, TRUE),(1,  1, FALSE),   -- Ficção Científica, Ação
(2,  8, TRUE),(2,  5, FALSE),   -- Mistério, Drama
(3,  7, TRUE),(3, 10, FALSE),   -- Ficção Científica, Suspense
(4,  6, TRUE),(4,  5, FALSE),   -- Fantasia, Drama
(5,  5, TRUE),(5,  9, FALSE),   -- Drama, Romance
(6,  5, TRUE),(6,  4, FALSE),   -- Drama, Comédia
(7,  8, TRUE),(7, 11, FALSE),   -- Mistério, Terror
(8,  1, TRUE),(8,  3, FALSE),   -- Ação, Aventura
(9,  5, TRUE),(9,  4, FALSE),   -- Drama, Comédia
(10, 7, TRUE),(10, 3, FALSE),   -- Ficção Científica, Aventura
(11, 12,TRUE),(11, 3, FALSE),   -- Documentário, Aventura
(12, 8, TRUE),(12,10, FALSE),   -- Mistério, Suspense
(13, 7, TRUE),(13, 3, FALSE),   -- Ficção Científica, Aventura
(14, 9, TRUE),(14, 5, FALSE),   -- Romance, Drama
(15, 5, TRUE),(15, 9, FALSE),   -- Drama, Romance
(16, 5, TRUE),(16, 8, FALSE),   -- Drama, Mistério
(17, 11,TRUE),(17, 8, FALSE),   -- Terror, Mistério
(18, 4, TRUE),(18, 3, FALSE),   -- Comédia, Aventura
(19, 7, TRUE),(19, 1, FALSE),
(20, 8, TRUE),(20, 5, FALSE),
(21, 7, TRUE),(21,10, FALSE),
(22, 7, TRUE),(22, 3, FALSE),
(23, 5, TRUE),(23, 4, FALSE),
(24, 5, TRUE),(24, 9, FALSE),
(25, 10,TRUE),(25, 8, FALSE);

-- ══════════════════════════════════════════════════════════════
-- ELENCO
-- ══════════════════════════════════════════════════════════════
INSERT INTO filme_ator (id_filme, id_ator, personagem, ordem_credito) VALUES
(1,  1, 'Dra. Clara Voss',      1),(1,  2, 'Ren Nakamura',        2),(1,  3, 'Agente Solis',        3),
(2,  4, 'Faroleiro Alcântara',  1),(2,  5, 'Marinha Costa',       2),
(3,  6, 'Prof. Esteves',        1),(3,  7, 'Dra. Beatriz Cunha',  2),(3,  8, 'Engenheiro Luz',      3),
(4,  9, 'Mãe Helena',           1),(4, 10, 'Filho Mateus',        2),
(5,  1, 'Jornalista Vera',      1),(5, 11, 'Editor Braga',        2),
(6,  2, 'Irmão Caio',           1),(6, 12, 'Irmão Tiago',         2),
(7,  3, 'Restauradora Ines',    1),(7, 13, 'Arquivista Doria',    2),
(8,  4, 'Capitão Ramos',        1),(8, 14, 'Detetive Sousa',      2),
(9,  5, 'Passageira Helena',    1),(9, 15, 'Viajante Duarte',     2),
(10, 6, 'Inventor Belo',        1),(10, 1, 'Assistente Paula',    2),
(11, 7, 'Fotógrafa Lena',       1),(11, 2, 'Guia Marco',          2),
(12, 8, 'Investigadora Sena',   1),(12, 3, 'Delegado Cruz',       2),
(13, 9, 'Cientista Mara',       1),(13, 4, 'Piloto Fonseca',      2),
(14, 10,'Escritora Íris',       1),(14, 5, 'Carteiro Alceu',      2),
(15, 11,'Atleta Julia',         1),(15, 6, 'Técnico Barros',      2),
(16, 12,'Músico Edu',           1),(16, 7, 'Terapeuta Lara',      2),
(17, 13,'Irmã Sofia',           1),(17, 8, 'Irmão Bruno',         2),
(18, 14,'Goleiro Pato',         1),(18, 9, 'Técnica Cida',        2);

-- ══════════════════════════════════════════════════════════════
-- SALAS
-- ══════════════════════════════════════════════════════════════
INSERT INTO sala (nome_numero, capacidade, situacao) VALUES
('Sala 1 — VIP',        80,  'ATIVA'),
('Sala 2 — IMAX',      200,  'ATIVA'),
('Sala 3 — 3D',        120,  'ATIVA'),
('Sala 4 — Standard',  100,  'ATIVA'),
('Sala 5 — Standard',  100,  'ATIVA'),
('Sala 6 — Standard',   90,  'ATIVA'),
('Sala 7 — Infantil',   60,  'ATIVA'),
('Sala 8 — Standard',  100,  'ATIVA'),
('Sala 9 — 4DX',        50,  'ATIVA'),
('Sala 10 — Manutenção',80,  'MANUTENCAO');

-- Assentos (letras A-H, 10 por fileira)
INSERT INTO assento (id_sala, numero, fileira, ativo)
SELECT s.id_sala,
       n.num,
       CHAR(64 + CEIL(n.num / 10)),
       TRUE
FROM sala s
JOIN (
    SELECT a * 10 + b AS num
    FROM (SELECT 0 a UNION SELECT 1 UNION SELECT 2 UNION SELECT 3
          UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) x
    JOIN (SELECT 1 b UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
          UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) y
    WHERE a * 10 + b BETWEEN 1 AND 80
) n ON n.num <= s.capacidade
WHERE s.situacao = 'ATIVA';

-- ══════════════════════════════════════════════════════════════
-- SESSÕES — passadas (últimos 7 dias) + hoje + próximos 7 dias
-- Filmes em cartaz (ids 1-18) distribuídos pelas salas ativas (1-9)
-- ══════════════════════════════════════════════════════════════
INSERT INTO sessao (id_filme, id_sala, inicio, preco, ingressos_disponiveis, situacao) VALUES
-- ── 7 dias atrás ────────────────────────────────────────────
(1,  1, DATE_SUB(NOW(), INTERVAL 7 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 14 HOUR, 45.00, 0,  'ENCERRADA'),
(2,  2, DATE_SUB(NOW(), INTERVAL 7 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 16 HOUR, 55.00, 0,  'ENCERRADA'),
(3,  3, DATE_SUB(NOW(), INTERVAL 7 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 19 HOUR, 38.00, 0,  'ENCERRADA'),
(4,  4, DATE_SUB(NOW(), INTERVAL 7 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 21 HOUR, 32.00, 0,  'ENCERRADA'),
-- ── 6 dias atrás ────────────────────────────────────────────
(5,  1, DATE_SUB(NOW(), INTERVAL 6 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 14 HOUR, 45.00, 0,  'ENCERRADA'),
(6,  2, DATE_SUB(NOW(), INTERVAL 6 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 15 HOUR, 55.00, 0,  'ENCERRADA'),
(7,  3, DATE_SUB(NOW(), INTERVAL 6 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 17 HOUR, 38.00, 0,  'ENCERRADA'),
(8,  4, DATE_SUB(NOW(), INTERVAL 6 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 20 HOUR, 32.00, 0,  'ENCERRADA'),
-- ── 5 dias atrás ────────────────────────────────────────────
(9,  1, DATE_SUB(NOW(), INTERVAL 5 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 14 HOUR, 45.00, 0,  'ENCERRADA'),
(10, 2, DATE_SUB(NOW(), INTERVAL 5 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 16 HOUR, 55.00, 0,  'ENCERRADA'),
(11, 3, DATE_SUB(NOW(), INTERVAL 5 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 19 HOUR, 38.00, 0,  'ENCERRADA'),
(12, 5, DATE_SUB(NOW(), INTERVAL 5 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 21 HOUR, 32.00, 0,  'ENCERRADA'),
-- ── 4 dias atrás ────────────────────────────────────────────
(1,  2, DATE_SUB(NOW(), INTERVAL 4 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 13 HOUR, 55.00, 0,  'ENCERRADA'),
(3,  3, DATE_SUB(NOW(), INTERVAL 4 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 15 HOUR, 38.00, 0,  'ENCERRADA'),
(5,  4, DATE_SUB(NOW(), INTERVAL 4 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 18 HOUR, 32.00, 0,  'ENCERRADA'),
(13, 5, DATE_SUB(NOW(), INTERVAL 4 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 20 HOUR, 32.00, 0,  'ENCERRADA'),
-- ── 3 dias atrás ────────────────────────────────────────────
(2,  1, DATE_SUB(NOW(), INTERVAL 3 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 14 HOUR, 45.00, 0,  'ENCERRADA'),
(4,  2, DATE_SUB(NOW(), INTERVAL 3 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 17 HOUR, 55.00, 0,  'ENCERRADA'),
(14, 3, DATE_SUB(NOW(), INTERVAL 3 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 19 HOUR, 38.00, 0,  'ENCERRADA'),
(15, 6, DATE_SUB(NOW(), INTERVAL 3 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 21 HOUR, 28.00, 0,  'ENCERRADA'),
-- ── 2 dias atrás ────────────────────────────────────────────
(6,  1, DATE_SUB(NOW(), INTERVAL 2 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 13 HOUR, 45.00, 0,  'ENCERRADA'),
(7,  2, DATE_SUB(NOW(), INTERVAL 2 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 15 HOUR, 55.00, 0,  'ENCERRADA'),
(16, 3, DATE_SUB(NOW(), INTERVAL 2 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 18 HOUR, 38.00, 0,  'ENCERRADA'),
(17, 9, DATE_SUB(NOW(), INTERVAL 2 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 20 HOUR, 60.00, 0,  'ENCERRADA'),
(18, 7, DATE_SUB(NOW(), INTERVAL 2 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 16 HOUR, 22.00, 0,  'ENCERRADA'),
-- ── ontem ───────────────────────────────────────────────────
(1,  1, DATE_SUB(NOW(), INTERVAL 1 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 14 HOUR, 45.00, 0,  'ENCERRADA'),
(2,  2, DATE_SUB(NOW(), INTERVAL 1 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 14 HOUR, 55.00, 0,  'ENCERRADA'),
(3,  3, DATE_SUB(NOW(), INTERVAL 1 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 16 HOUR, 38.00, 0,  'ENCERRADA'),
(8,  4, DATE_SUB(NOW(), INTERVAL 1 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 16 HOUR, 32.00, 0,  'ENCERRADA'),
(9,  5, DATE_SUB(NOW(), INTERVAL 1 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 18 HOUR, 32.00, 0,  'ENCERRADA'),
(10, 6, DATE_SUB(NOW(), INTERVAL 1 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 18 HOUR, 28.00, 0,  'ENCERRADA'),
(11, 7, DATE_SUB(NOW(), INTERVAL 1 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 19 HOUR, 22.00, 0,  'ENCERRADA'),
(17, 9, DATE_SUB(NOW(), INTERVAL 1 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 20 HOUR, 60.00, 0,  'ENCERRADA'),
(12, 8, DATE_SUB(NOW(), INTERVAL 1 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 20 HOUR, 32.00, 0,  'ENCERRADA'),
(13, 1, DATE_SUB(NOW(), INTERVAL 1 DAY) - INTERVAL MOD(HOUR(NOW()),24)*60+MINUTE(NOW()) MINUTE + INTERVAL 21 HOUR, 45.00, 0,  'ENCERRADA'),
-- ── HOJE ────────────────────────────────────────────────────
(1,  2, CURDATE() + INTERVAL 14 HOUR, 55.00, 200, 'PROGRAMADA'),
(2,  1, CURDATE() + INTERVAL 14 HOUR, 45.00,  80, 'PROGRAMADA'),
(3,  3, CURDATE() + INTERVAL 14 HOUR, 38.00, 120, 'PROGRAMADA'),
(17, 9, CURDATE() + INTERVAL 15 HOUR, 60.00,  50, 'PROGRAMADA'),
(4,  4, CURDATE() + INTERVAL 16 HOUR, 32.00, 100, 'PROGRAMADA'),
(5,  5, CURDATE() + INTERVAL 16 HOUR, 32.00, 100, 'PROGRAMADA'),
(18, 7, CURDATE() + INTERVAL 16 HOUR, 22.00,  60, 'PROGRAMADA'),
(6,  6, CURDATE() + INTERVAL 17 HOUR, 28.00,  90, 'PROGRAMADA'),
(1,  1, CURDATE() + INTERVAL 17 HOUR, 45.00,  80, 'PROGRAMADA'),
(7,  8, CURDATE() + INTERVAL 17 HOUR, 32.00, 100, 'PROGRAMADA'),
(8,  2, CURDATE() + INTERVAL 19 HOUR, 55.00, 200, 'PROGRAMADA'),
(9,  3, CURDATE() + INTERVAL 19 HOUR, 38.00, 120, 'PROGRAMADA'),
(10, 4, CURDATE() + INTERVAL 19 HOUR, 32.00, 100, 'PROGRAMADA'),
(11, 5, CURDATE() + INTERVAL 19 HOUR, 32.00, 100, 'PROGRAMADA'),
(17, 9, CURDATE() + INTERVAL 19 HOUR, 60.00,  50, 'PROGRAMADA'),
(12, 6, CURDATE() + INTERVAL 20 HOUR, 28.00,  90, 'PROGRAMADA'),
(13, 1, CURDATE() + INTERVAL 20 HOUR, 45.00,  80, 'PROGRAMADA'),
(14, 7, CURDATE() + INTERVAL 20 HOUR, 22.00,  60, 'PROGRAMADA'),
(3,  2, CURDATE() + INTERVAL 21 HOUR, 55.00, 200, 'PROGRAMADA'),
(15, 8, CURDATE() + INTERVAL 21 HOUR, 32.00, 100, 'PROGRAMADA'),
(16, 3, CURDATE() + INTERVAL 21 HOUR, 38.00, 120, 'PROGRAMADA'),
(2,  4, CURDATE() + INTERVAL 22 HOUR, 32.00, 100, 'PROGRAMADA'),
-- ── amanhã ──────────────────────────────────────────────────
(1,  2, CURDATE() + INTERVAL 1 DAY + INTERVAL 14 HOUR, 55.00, 200, 'PROGRAMADA'),
(3,  3, CURDATE() + INTERVAL 1 DAY + INTERVAL 15 HOUR, 38.00, 120, 'PROGRAMADA'),
(5,  4, CURDATE() + INTERVAL 1 DAY + INTERVAL 15 HOUR, 32.00, 100, 'PROGRAMADA'),
(17, 9, CURDATE() + INTERVAL 1 DAY + INTERVAL 16 HOUR, 60.00,  50, 'PROGRAMADA'),
(7,  1, CURDATE() + INTERVAL 1 DAY + INTERVAL 17 HOUR, 45.00,  80, 'PROGRAMADA'),
(8,  5, CURDATE() + INTERVAL 1 DAY + INTERVAL 17 HOUR, 32.00, 100, 'PROGRAMADA'),
(18, 7, CURDATE() + INTERVAL 1 DAY + INTERVAL 17 HOUR, 22.00,  60, 'PROGRAMADA'),
(10, 2, CURDATE() + INTERVAL 1 DAY + INTERVAL 19 HOUR, 55.00, 200, 'PROGRAMADA'),
(11, 6, CURDATE() + INTERVAL 1 DAY + INTERVAL 19 HOUR, 28.00,  90, 'PROGRAMADA'),
(13, 3, CURDATE() + INTERVAL 1 DAY + INTERVAL 20 HOUR, 38.00, 120, 'PROGRAMADA'),
(16, 9, CURDATE() + INTERVAL 1 DAY + INTERVAL 20 HOUR, 60.00,  50, 'PROGRAMADA'),
(4,  4, CURDATE() + INTERVAL 1 DAY + INTERVAL 21 HOUR, 32.00, 100, 'PROGRAMADA'),
(6,  8, CURDATE() + INTERVAL 1 DAY + INTERVAL 21 HOUR, 32.00, 100, 'PROGRAMADA'),
-- ── +2 dias ─────────────────────────────────────────────────
(2,  2, CURDATE() + INTERVAL 2 DAY + INTERVAL 14 HOUR, 55.00, 200, 'PROGRAMADA'),
(12, 1, CURDATE() + INTERVAL 2 DAY + INTERVAL 16 HOUR, 45.00,  80, 'PROGRAMADA'),
(14, 3, CURDATE() + INTERVAL 2 DAY + INTERVAL 18 HOUR, 38.00, 120, 'PROGRAMADA'),
(1,  9, CURDATE() + INTERVAL 2 DAY + INTERVAL 19 HOUR, 60.00,  50, 'PROGRAMADA'),
(15, 4, CURDATE() + INTERVAL 2 DAY + INTERVAL 20 HOUR, 32.00, 100, 'PROGRAMADA'),
(17, 5, CURDATE() + INTERVAL 2 DAY + INTERVAL 20 HOUR, 32.00, 100, 'PROGRAMADA'),
(9,  6, CURDATE() + INTERVAL 2 DAY + INTERVAL 21 HOUR, 28.00,  90, 'PROGRAMADA'),
-- ── +3 dias ─────────────────────────────────────────────────
(3,  2, CURDATE() + INTERVAL 3 DAY + INTERVAL 15 HOUR, 55.00, 200, 'PROGRAMADA'),
(5,  1, CURDATE() + INTERVAL 3 DAY + INTERVAL 17 HOUR, 45.00,  80, 'PROGRAMADA'),
(7,  3, CURDATE() + INTERVAL 3 DAY + INTERVAL 18 HOUR, 38.00, 120, 'PROGRAMADA'),
(8,  9, CURDATE() + INTERVAL 3 DAY + INTERVAL 19 HOUR, 60.00,  50, 'PROGRAMADA'),
(10, 4, CURDATE() + INTERVAL 3 DAY + INTERVAL 20 HOUR, 32.00, 100, 'PROGRAMADA'),
(11, 7, CURDATE() + INTERVAL 3 DAY + INTERVAL 20 HOUR, 22.00,  60, 'PROGRAMADA'),
(16, 8, CURDATE() + INTERVAL 3 DAY + INTERVAL 21 HOUR, 32.00, 100, 'PROGRAMADA'),
-- ── +4 a +7 dias (fim de semana) ────────────────────────────
(1,  2, CURDATE() + INTERVAL 4 DAY + INTERVAL 14 HOUR, 55.00, 200, 'PROGRAMADA'),
(2,  3, CURDATE() + INTERVAL 4 DAY + INTERVAL 16 HOUR, 38.00, 120, 'PROGRAMADA'),
(3,  9, CURDATE() + INTERVAL 4 DAY + INTERVAL 18 HOUR, 60.00,  50, 'PROGRAMADA'),
(13, 1, CURDATE() + INTERVAL 4 DAY + INTERVAL 19 HOUR, 45.00,  80, 'PROGRAMADA'),
(17, 4, CURDATE() + INTERVAL 4 DAY + INTERVAL 20 HOUR, 32.00, 100, 'PROGRAMADA'),
(4,  5, CURDATE() + INTERVAL 5 DAY + INTERVAL 14 HOUR, 32.00, 100, 'PROGRAMADA'),
(6,  2, CURDATE() + INTERVAL 5 DAY + INTERVAL 15 HOUR, 55.00, 200, 'PROGRAMADA'),
(8,  3, CURDATE() + INTERVAL 5 DAY + INTERVAL 17 HOUR, 38.00, 120, 'PROGRAMADA'),
(18, 7, CURDATE() + INTERVAL 5 DAY + INTERVAL 17 HOUR, 22.00,  60, 'PROGRAMADA'),
(10, 9, CURDATE() + INTERVAL 5 DAY + INTERVAL 19 HOUR, 60.00,  50, 'PROGRAMADA'),
(12, 1, CURDATE() + INTERVAL 5 DAY + INTERVAL 20 HOUR, 45.00,  80, 'PROGRAMADA'),
(14, 6, CURDATE() + INTERVAL 5 DAY + INTERVAL 20 HOUR, 28.00,  90, 'PROGRAMADA'),
(1,  2, CURDATE() + INTERVAL 6 DAY + INTERVAL 14 HOUR, 55.00, 200, 'PROGRAMADA'),
(3,  3, CURDATE() + INTERVAL 6 DAY + INTERVAL 16 HOUR, 38.00, 120, 'PROGRAMADA'),
(5,  9, CURDATE() + INTERVAL 6 DAY + INTERVAL 18 HOUR, 60.00,  50, 'PROGRAMADA'),
(15, 4, CURDATE() + INTERVAL 6 DAY + INTERVAL 19 HOUR, 32.00, 100, 'PROGRAMADA'),
(16, 5, CURDATE() + INTERVAL 6 DAY + INTERVAL 20 HOUR, 32.00, 100, 'PROGRAMADA'),
(17, 1, CURDATE() + INTERVAL 6 DAY + INTERVAL 20 HOUR, 45.00,  80, 'PROGRAMADA'),
(2,  2, CURDATE() + INTERVAL 7 DAY + INTERVAL 15 HOUR, 55.00, 200, 'PROGRAMADA'),
(7,  3, CURDATE() + INTERVAL 7 DAY + INTERVAL 17 HOUR, 38.00, 120, 'PROGRAMADA'),
(9,  9, CURDATE() + INTERVAL 7 DAY + INTERVAL 19 HOUR, 60.00,  50, 'PROGRAMADA'),
(11, 4, CURDATE() + INTERVAL 7 DAY + INTERVAL 20 HOUR, 32.00, 100, 'PROGRAMADA'),
(13, 5, CURDATE() + INTERVAL 7 DAY + INTERVAL 20 HOUR, 32.00, 100, 'PROGRAMADA');

-- ══════════════════════════════════════════════════════════════
-- RESERVAS — para sessões passadas (encerradas) e algumas de hoje
-- ══════════════════════════════════════════════════════════════

-- Reservas para sessões encerradas (ids 1-35)
INSERT INTO reserva (id_cliente, id_sessao, quantidade, data_reserva, situacao)
SELECT
    (MOD(s.id_sessao + c.n, 35) + 1)                          AS id_cliente,
    s.id_sessao,
    1 + MOD(s.id_sessao + c.n, 4)                             AS quantidade,
    s.inicio - INTERVAL (1 + MOD(c.n, 72)) HOUR               AS data_reserva,
    CASE WHEN MOD(s.id_sessao + c.n, 12) = 0
         THEN 'CANCELADA' ELSE 'CONFIRMADA' END                AS situacao
FROM sessao s
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
      UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8) c
WHERE s.situacao = 'ENCERRADA'
  AND (MOD(s.id_sessao + c.n, 35) + 1) IN (SELECT id_usuario FROM cliente);

-- Reservas para sessões de hoje (confirmadas, sem lotar)
INSERT INTO reserva (id_cliente, id_sessao, quantidade, data_reserva, situacao)
SELECT
    (MOD(s.id_sessao * 3 + c.n, 35) + 1)                     AS id_cliente,
    s.id_sessao,
    1 + MOD(c.n, 3)                                           AS quantidade,
    NOW() - INTERVAL (c.n * 30) MINUTE                        AS data_reserva,
    'CONFIRMADA'
FROM sessao s
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c
WHERE DATE(s.inicio) = CURDATE()
  AND (MOD(s.id_sessao * 3 + c.n, 35) + 1) IN (SELECT id_usuario FROM cliente);

-- ══════════════════════════════════════════════════════════════
-- ATUALIZA ingressos_disponiveis conforme reservas confirmadas
-- ══════════════════════════════════════════════════════════════
UPDATE sessao s
SET ingressos_disponiveis = GREATEST(0,
    s.ingressos_disponiveis - COALESCE((
        SELECT SUM(r.quantidade)
        FROM reserva r
        WHERE r.id_sessao = s.id_sessao AND r.situacao = 'CONFIRMADA'
    ), 0)
)
WHERE DATE(s.inicio) = CURDATE();

-- ══════════════════════════════════════════════════════════════
-- HISTÓRICO DE SITUAÇÃO DOS FILMES
-- ══════════════════════════════════════════════════════════════
INSERT INTO historico_situacao_filme (id_filme, sequencia, situacao, inicio, fim)
SELECT id_filme, 1, 'FUTURO',
       data_lancamento - INTERVAL 30 DAY,
       data_lancamento
FROM filme WHERE data_lancamento >= '2026-09-01' AND id_filme <= 18;

INSERT INTO historico_situacao_filme (id_filme, sequencia, situacao, inicio, fim)
SELECT id_filme, 2, 'EM_CARTAZ', data_lancamento, NULL
FROM filme WHERE id_filme <= 18;

INSERT INTO historico_situacao_filme (id_filme, sequencia, situacao, inicio, fim)
VALUES
(23, 1, 'FUTURO',    '2026-05-01', '2026-06-01'),
(23, 2, 'EM_CARTAZ', '2026-06-01', '2026-09-30'),
(23, 3, 'ENCERRADO', '2026-09-30', NULL),
(24, 1, 'FUTURO',    '2026-06-10', '2026-07-10'),
(24, 2, 'EM_CARTAZ', '2026-07-10', '2026-10-10'),
(24, 3, 'ENCERRADO', '2026-10-10', NULL),
(25, 1, 'FUTURO',    '2026-07-05', '2026-08-05'),
(25, 2, 'EM_CARTAZ', '2026-08-05', '2026-10-15'),
(25, 3, 'ENCERRADO', '2026-10-15', NULL),
(19, 1, 'FUTURO',    '2026-10-10', NULL),
(20, 1, 'FUTURO',    '2026-10-15', NULL),
(21, 1, 'FUTURO',    '2026-10-20', NULL),
(22, 1, 'FUTURO',    '2026-11-05', NULL);

-- ══════════════════════════════════════════════════════════════
-- VERIFICAÇÃO FINAL
-- ══════════════════════════════════════════════════════════════
SELECT 'usuario'                  AS tabela, COUNT(*) AS linhas FROM usuario
UNION ALL SELECT 'cliente',                  COUNT(*) FROM cliente
UNION ALL SELECT 'administrador',            COUNT(*) FROM administrador
UNION ALL SELECT 'filme',                    COUNT(*) FROM filme
UNION ALL SELECT 'genero',                   COUNT(*) FROM genero
UNION ALL SELECT 'filme_genero',             COUNT(*) FROM filme_genero
UNION ALL SELECT 'ator',                     COUNT(*) FROM ator
UNION ALL SELECT 'filme_ator',               COUNT(*) FROM filme_ator
UNION ALL SELECT 'sala',                     COUNT(*) FROM sala
UNION ALL SELECT 'assento',                  COUNT(*) FROM assento
UNION ALL SELECT 'sessao',                   COUNT(*) FROM sessao
UNION ALL SELECT 'reserva',                  COUNT(*) FROM reserva
UNION ALL SELECT 'historico_situacao_filme', COUNT(*) FROM historico_situacao_filme;
