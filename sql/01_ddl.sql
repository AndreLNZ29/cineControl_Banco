-- CineControl | Etapa 1 | 01_ddl.sql
-- SGBD: MySQL 8.0+
DROP DATABASE IF EXISTS cinecontrol;
CREATE DATABASE cinecontrol CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cinecontrol;

CREATE TABLE usuario (
    id_usuario BIGINT AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(100) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (email)
) ENGINE=InnoDB;

CREATE TABLE cliente (
    id_usuario BIGINT NOT NULL,
    data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT pk_cliente PRIMARY KEY (id_usuario),
    CONSTRAINT fk_cliente_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE administrador (
    id_usuario BIGINT NOT NULL,
    nivel_acesso VARCHAR(20) NOT NULL DEFAULT 'OPERACIONAL',
    CONSTRAINT pk_administrador PRIMARY KEY (id_usuario),
    CONSTRAINT fk_administrador_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_administrador_nivel CHECK (nivel_acesso IN ('OPERACIONAL','GESTOR'))
) ENGINE=InnoDB;

CREATE TABLE genero (
    id_genero BIGINT AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    CONSTRAINT pk_genero PRIMARY KEY (id_genero),
    CONSTRAINT uq_genero_nome UNIQUE (nome)
) ENGINE=InnoDB;

CREATE TABLE ator (
    id_ator BIGINT AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL,
    data_nascimento DATE,
    CONSTRAINT pk_ator PRIMARY KEY (id_ator)
) ENGINE=InnoDB;

CREATE TABLE filme (
    id_filme BIGINT AUTO_INCREMENT,
    id_filme_origem BIGINT,
    titulo VARCHAR(180) NOT NULL,
    descricao TEXT,
    duracao_min INTEGER NOT NULL,
    classificacao VARCHAR(10) NOT NULL,
    data_lancamento DATE,
    situacao VARCHAR(20) NOT NULL DEFAULT 'EM_CARTAZ',
    CONSTRAINT pk_filme PRIMARY KEY (id_filme),
    CONSTRAINT fk_filme_origem FOREIGN KEY (id_filme_origem)
        REFERENCES filme(id_filme) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_filme_duracao CHECK (duracao_min > 0 AND duracao_min <= 500),
    CONSTRAINT ck_filme_classificacao CHECK (classificacao IN ('L','10','12','14','16','18')),
    CONSTRAINT ck_filme_situacao CHECK (situacao IN ('EM_CARTAZ','PAUSADO','ENCERRADO','FUTURO'))
) ENGINE=InnoDB;

CREATE TABLE filme_genero (
    id_filme BIGINT NOT NULL,
    id_genero BIGINT NOT NULL,
    principal BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_filme_genero PRIMARY KEY (id_filme, id_genero),
    CONSTRAINT fk_filme_genero_filme FOREIGN KEY (id_filme)
        REFERENCES filme(id_filme) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_filme_genero_genero FOREIGN KEY (id_genero)
        REFERENCES genero(id_genero) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE filme_ator (
    id_filme BIGINT NOT NULL,
    id_ator BIGINT NOT NULL,
    personagem VARCHAR(120) NOT NULL,
    ordem_credito SMALLINT NOT NULL,
    CONSTRAINT pk_filme_ator PRIMARY KEY (id_filme, id_ator),
    CONSTRAINT fk_filme_ator_filme FOREIGN KEY (id_filme)
        REFERENCES filme(id_filme) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_filme_ator_ator FOREIGN KEY (id_ator)
        REFERENCES ator(id_ator) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_filme_ator_ordem CHECK (ordem_credito > 0)
) ENGINE=InnoDB;

CREATE TABLE sala (
    id_sala BIGINT AUTO_INCREMENT,
    nome_numero VARCHAR(40) NOT NULL,
    capacidade INTEGER NOT NULL,
    situacao VARCHAR(20) NOT NULL DEFAULT 'ATIVA',
    CONSTRAINT pk_sala PRIMARY KEY (id_sala),
    CONSTRAINT uq_sala_nome UNIQUE (nome_numero),
    CONSTRAINT ck_sala_capacidade CHECK (capacidade > 0 AND capacidade <= 1000),
    CONSTRAINT ck_sala_situacao CHECK (situacao IN ('ATIVA','MANUTENCAO','INATIVA'))
) ENGINE=InnoDB;

-- Entidade fraca: Assento é identificado pela sala + número.
CREATE TABLE assento (
    id_sala BIGINT NOT NULL,
    numero SMALLINT NOT NULL,
    fileira CHAR(1) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_assento PRIMARY KEY (id_sala, numero),
    CONSTRAINT fk_assento_sala FOREIGN KEY (id_sala)
        REFERENCES sala(id_sala) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_assento_numero CHECK (numero > 0),
    CONSTRAINT ck_assento_fileira CHECK (fileira REGEXP '^[A-Z]$')
) ENGINE=InnoDB;

CREATE TABLE sessao (
    id_sessao BIGINT AUTO_INCREMENT,
    id_filme BIGINT NOT NULL,
    id_sala BIGINT NOT NULL,
    inicio TIMESTAMP NOT NULL,
    preco NUMERIC(8,2) NOT NULL,
    ingressos_disponiveis INTEGER NOT NULL,
    situacao VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADA',
    CONSTRAINT pk_sessao PRIMARY KEY (id_sessao),
    CONSTRAINT fk_sessao_filme FOREIGN KEY (id_filme)
        REFERENCES filme(id_filme) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_sessao_sala FOREIGN KEY (id_sala)
        REFERENCES sala(id_sala) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_sessao_preco CHECK (preco >= 0),
    CONSTRAINT ck_sessao_disponibilidade CHECK (ingressos_disponiveis >= 0),
    CONSTRAINT ck_sessao_situacao CHECK (situacao IN ('PROGRAMADA','EM_EXIBICAO','ENCERRADA','CANCELADA')),
    CONSTRAINT uq_sessao_sala_inicio UNIQUE (id_sala, inicio)
) ENGINE=InnoDB;

CREATE TABLE reserva (
    id_reserva BIGINT AUTO_INCREMENT,
    id_cliente BIGINT NOT NULL,
    id_sessao BIGINT NOT NULL,
    quantidade SMALLINT NOT NULL,
    data_reserva TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    situacao VARCHAR(20) NOT NULL DEFAULT 'CONFIRMADA',
    CONSTRAINT pk_reserva PRIMARY KEY (id_reserva),
    CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_reserva_sessao FOREIGN KEY (id_sessao)
        REFERENCES sessao(id_sessao) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_reserva_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_reserva_situacao CHECK (situacao IN ('CONFIRMADA','CANCELADA'))
) ENGINE=InnoDB;

-- Atributo temporal: histórico de situação de cada filme.
CREATE TABLE historico_situacao_filme (
    id_filme BIGINT NOT NULL,
    sequencia INTEGER NOT NULL,
    situacao VARCHAR(20) NOT NULL,
    inicio TIMESTAMP NOT NULL,
    fim TIMESTAMP NULL,
    CONSTRAINT pk_historico_situacao_filme PRIMARY KEY (id_filme, sequencia),
    CONSTRAINT fk_historico_filme FOREIGN KEY (id_filme)
        REFERENCES filme(id_filme) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_historico_situacao CHECK (situacao IN ('EM_CARTAZ','PAUSADO','ENCERRADO','FUTURO')),
    CONSTRAINT ck_historico_periodo CHECK (fim IS NULL OR fim > inicio)
) ENGINE=InnoDB;

CREATE INDEX idx_sessao_filme_inicio ON sessao (id_filme, inicio);
CREATE INDEX idx_sessao_sala_inicio ON sessao (id_sala, inicio);
CREATE INDEX idx_reserva_sessao_situacao ON reserva (id_sessao, situacao);
CREATE INDEX idx_reserva_cliente_data ON reserva (id_cliente, data_reserva);
CREATE INDEX idx_filme_titulo ON filme (titulo);

-- MySQL não suporta índice único parcial (CREATE UNIQUE INDEX ... WHERE ...).
-- (Uma coluna gerada com esse cálculo também não é opção aqui: o MySQL proíbe
-- colunas geradas baseadas em colunas de FK com ON UPDATE/DELETE CASCADE, que
-- é o caso de id_filme.) Solução equivalente: triggers que impedem mais de um
-- gênero principal por filme.
DELIMITER $$
CREATE TRIGGER trg_filme_genero_principal_ins
BEFORE INSERT ON filme_genero
FOR EACH ROW
BEGIN
    IF NEW.principal = TRUE AND EXISTS (
        SELECT 1 FROM filme_genero
        WHERE id_filme = NEW.id_filme AND principal = TRUE
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Já existe um gênero principal cadastrado para este filme';
    END IF;
END$$

CREATE TRIGGER trg_filme_genero_principal_upd
BEFORE UPDATE ON filme_genero
FOR EACH ROW
BEGIN
    IF NEW.principal = TRUE AND EXISTS (
        SELECT 1 FROM filme_genero
        WHERE id_filme = NEW.id_filme AND principal = TRUE
          AND id_genero <> NEW.id_genero
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Já existe um gênero principal cadastrado para este filme';
    END IF;
END$$
DELIMITER ;
