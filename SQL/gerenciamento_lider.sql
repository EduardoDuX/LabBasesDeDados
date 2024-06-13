CREATE OR REPLACE VIEW v_lider_faccao AS
    SELECT F.Lider, F.Nome AS FACCAO, NF.Nacao, D.Planeta, H.Especie, H.Comunidade, 
            (CASE WHEN (P.Comunidade = H.Comunidade AND P.Especie = H.Especie) THEN 1
              ELSE 0
             END) AS CREDENCIADA
        FROM Faccao F
        LEFT JOIN Nacao_Faccao NF
        ON F.nome = NF.faccao
        LEFT JOIN Dominancia D
        ON NF.nacao = D.nacao AND (D.data_fim IS NULL OR D.data_fim > SYSDATE)
        LEFT JOIN Habitacao H
        ON D.planeta = H.planeta AND (H.data_fim IS NULL OR H.data_fim > SYSDATE)
        LEFT JOIN Participa P
        ON H.comunidade = P.comunidade AND H.especie = P.especie;

CREATE OR REPLACE TRIGGER t_lider_faccoes
INSTEAD OF UPDATE
ON v_lider_faccao
FOR EACH ROW
BEGIN
    IF :new.credenciada = 1 THEN
        INSERT INTO PARTICIPA VALUES (:old.faccao, :old.especie, :old.comunidade);
    ELSIF :new.credenciada = 0 THEN
        DELETE FROM PARTICIPA 
            WHERE Faccao = :old.faccao
                AND Especie = :old.especie
                AND Comunidade = :old.comunidade;
    END IF;
END;        
            
CREATE OR REPLACE PACKAGE gerenciamento_lider AS
    PROCEDURE remove_nacao_faccao (
        p_nacao nacao.nome%type
    );
    PROCEDURE inicia_faccao (
        p_cpi lider.cpi%type
    );
    PROCEDURE alterar_nome_faccao (
        p_cpi           LIDER.CPI%type,
        p_faccao_old    FACCAO.NOME%type,
        p_faccao_new    FACCAO.NOME%type
    );
    PROCEDURE indicar_novo_lider (
        p_lider_atual   LIDER.CPI%type,
        p_lider_novo    FACCAO.NOME%type,
        p_faccao        FACCAO.NOME%type
    );
END gerenciamento_lider;
   
/

CREATE OR REPLACE PACKAGE BODY gerenciamento_lider AS 
    v_faccao faccao.nome%type; -- Variável privada com a faccao do lider, preenchida com o procedure 'inicia_faccao'
    
        
    -- Procedimento deve ser executado imediatamente após o login
    -- Descobre, dado o lider, qual sua faccao
    PROCEDURE inicia_faccao (
        p_cpi lider.cpi%type
    )
    IS
    BEGIN
        SELECT faccao INTO v_faccao FROM v_lider_faccao where lider = p_cpi;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002,'Lider nao tem faccao');
    END inicia_faccao;
    
    -- PROCEDURE PARA REMOVER A NACAO DA FACCAO
    PROCEDURE remove_nacao_faccao (
        p_nacao nacao.nome%type
    ) IS 
    BEGIN
        DELETE FROM nacao_faccao nf WHERE nf.nacao = p_nacao and nf.faccao = v_faccao;
        commit;
    END remove_nacao_faccao;
    
    -- TODO: ATUALIZAR TABELAS FILHAS
    -- PROCEDURE PARA ALTERAR NOME DA FACCAO
    PROCEDURE alterar_nome_faccao (
        p_cpi           LIDER.CPI%type,
        p_faccao_old    FACCAO.NOME%type,
        p_faccao_new    FACCAO.NOME%type
    ) AS
    BEGIN
        UPDATE Faccao 
            SET Nome = p_faccao_new
            WHERE Nome = p_faccao_old;
        commit;
    END alterar_nome_faccao;
    
    -- PROCEDURE PARA INDICAR NOVO LIDER
    PROCEDURE indicar_novo_lider (
        p_lider_atual   LIDER.CPI%type,
        p_lider_novo    FACCAO.NOME%type,
        p_faccao        FACCAO.NOME%type
    ) AS
    BEGIN
        UPDATE Faccao 
            SET Lider = p_lider_novo
            WHERE Nome = p_faccao;
        commit;
    END indicar_novo_lider;

    
END gerenciamento_lider;

