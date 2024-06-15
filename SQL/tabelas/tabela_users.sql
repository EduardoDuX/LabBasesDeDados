CREATE TABLE USERS
(
    USERID NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    PASSWORD VARCHAR(32), -- TAMANHO DO HASH MD5
    ID_LIDER CHAR(14 BYTE) UNIQUE,
    CONSTRAINT PK_USERS PRIMARY KEY (USERID),
    CONSTRAINT FK_USERS FOREIGN KEY (ID_LIDER) REFERENCES LIDER(CPI)
);


-- Pedir para os monitores se o ideal é usar o hash em um procedimento de inserção
-- ou há como fazer na definição da tabela
insert into users (PASSWORD,ID_LIDER) values (standard_hash('sehna', 'MD5'), '223.456.789-10');
select * from users;
