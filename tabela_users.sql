CREATE TABLE USERS
(
    USERID NUMBER,
    PASSWORD VARCHAR(32), -- TAMANHO DO HASH MD5
    ID_LIDER CHAR(14 BYTE) UNIQUE,
    CONSTRAINT PK_USERS PRIMARY KEY (USERID),
    CONSTRAINT FK_USERS FOREIGN KEY (ID_LIDER) REFERENCES LIDER(CPI)
)

-- Pedir para os monitores se o ideal � usar o hash em um procedimento de inser��o
-- ou h� como fazer na defini��o da tabela
insert into users values (0, standard_hash('sehna', 'MD5'), '123.456.789-10');
select * from users;