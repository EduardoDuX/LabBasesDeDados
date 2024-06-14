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
        p_cpi	  IN 	lider.cpi%type
        p_refcur  OUT	SYS_REFCURSOR
    )
    IS
    BEGIN
	OPEN p_refcur FOR
	    SELECT faccao INTO v_faccao 
			FROM v_lider_faccao 
			WHERE lider = p_cpi;
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
    
    -- PROCEDURE PARA ALTERAR NOME DA FACCAO
    PROCEDURE alterar_nome_faccao (
        p_cpi           LIDER.CPI%type,
        p_faccao_old    FACCAO.NOME%type,
        p_faccao_new    FACCAO.NOME%type
    ) AS    
        TYPE tb_nacoes_associadas IS TABLE OF Nacao_Faccao.Nacao%type;
        v_nacoes_associadas tb_nacoes_associadas := tb_nacoes_associadas();
        
        TYPE tb_participa IS RECORD (
            tb_especie  Participa.Especie%type,
            tb_comunidade  Participa.Comunidade%type
            
        );
        TYPE tb_comunidades_associadas IS TABLE OF tb_participa;
        v_comunidades_associadas tb_comunidades_associadas := tb_comunidades_associadas();
        
    BEGIN
        -- Armazenas as tuplas de PARTICIPA referentes em uma coleção e as deleta
        SELECT Especie, Comunidade BULK COLLECT INTO v_comunidades_associadas
            FROM Participa 
            WHERE Faccao = p_faccao_old;
        DELETE FROM Participa WHERE Faccao = p_faccao_old; 
        
        -- Armazenas as tuplas de NACAO_FACCAO referentes em uma coleção e as deleta
        SELECT Nacao BULK COLLECT INTO v_nacoes_associadas
            FROM Nacao_Faccao 
            WHERE Faccao = p_faccao_old;    
        DELETE FROM Nacao_Faccao WHERE Faccao = p_faccao_old;  
        
        -- Atualiza o nome da Faccao
        UPDATE Faccao 
            SET Nome = p_faccao_new
            WHERE Nome = p_faccao_old;
    
        -- Reinsere os valores removidos anteriormente com o nome atualizado
        FOR i IN v_comunidades_associadas.FIRST .. v_comunidades_associadas.LAST 
        LOOP
            INSERT INTO Participa 
                VALUES (p_faccao_new, v_comunidades_associadas(i).tb_especie, v_comunidades_associadas(i).tb_comunidade);
        END LOOP;
        
        FOR i IN v_nacoes_associadas.FIRST .. v_nacoes_associadas.LAST 
        LOOP
            INSERT INTO Nacao_Faccao 
                VALUES (v_nacoes_associadas(i), p_faccao_new);    
        END LOOP;
        
        COMMIT;
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

