/*
Pacote para implementar as funcionalidades de gerenciamento do lider de faccao
*/

CREATE OR REPLACE PACKAGE LIDER_FACCAO AS

    -- Relatorio das comunidades da faccao
    PROCEDURE RELATORIO_COMUNIDADE(
        p_nacao NACAO.NOME%TYPE,
        p_filtro VARCHAR2, 
        p_com_refcur IN OUT SYS_REFCURSOR
    );

    -- Remover a faccao de uma nacao
    PROCEDURE remove_nacao_faccao (
        p_nacao nacao.nome%type,
        p_faccao faccao.nome%type
    );

    -- Retorna o nome da faccao para a aplicacao
    FUNCTION inicia_faccao (
        p_cpi lider.cpi%type
    )
    RETURN VARCHAR2;
    
    -- Procedure para alterar o nome da faccao
    PROCEDURE alterar_nome_faccao (
        p_cpi           LIDER.CPI%type,
        p_faccao_old    FACCAO.NOME%type,
        p_faccao_new    FACCAO.NOME%type
    );

    -- Indica um novo lider para a faccao
    PROCEDURE indicar_novo_lider (
        p_lider_atual   LIDER.CPI%type,
        p_lider_novo    FACCAO.NOME%type,
        p_faccao        FACCAO.NOME%type
    );

END LIDER_FACCAO;

/

CREATE OR REPLACE PACKAGE BODY LIDER_FACCAO AS

    PROCEDURE RELATORIO_COMUNIDADE(
        p_nacao NACAO.NOME%TYPE,
        p_filtro VARCHAR2, 
        p_com_refcur IN OUT SYS_REFCURSOR
    ) 
    IS
    BEGIN
        IF p_filtro = 'NACAO' THEN
            OPEN p_com_refcur FOR
                SELECT 
                    D.NACAO, 
                    COUNT(DISTINCT H.ESPECIE || H.COMUNIDADE) AS QTD_COMUNIDADES 
                FROM
                    DOMINANCIA D
                    INNER JOIN HABITACAO H ON D.PLANETA = H.PLANETA
                WHERE
                    D.NACAO = p_nacao
                    AND H.DATA_FIM IS NULL
                GROUP BY
                    D.NACAO
                ORDER BY
                    QTD_COMUNIDADES DESC;
        
        ELSIF p_filtro = 'ESPECIE' THEN
            OPEN p_com_refcur FOR 
            SELECT 
                H.ESPECIE, 
                COUNT(DISTINCT H.ESPECIE || H.COMUNIDADE) AS QTD_COMUNIDADES 
            FROM
                DOMINANCIA D
                INNER JOIN HABITACAO H ON D.PLANETA = H.PLANETA
            WHERE
                D.NACAO = p_nacao
                AND H.DATA_FIM IS NULL
            GROUP BY
                H.ESPECIE
            ORDER BY
                QTD_COMUNIDADES DESC;
        
        ELSIF p_filtro = 'PLANETA' THEN
            OPEN p_com_refcur FOR 
                SELECT 
                    D.PLANETA, 
                    COUNT(DISTINCT H.ESPECIE || H.COMUNIDADE) AS QTD_COMUNIDADES 
                FROM
                    DOMINANCIA D
                    INNER JOIN HABITACAO H ON D.PLANETA = H.PLANETA
                WHERE
                    D.NACAO = p_nacao
                GROUP BY
                    D.PLANETA
                ORDER BY
                    QTD_COMUNIDADES DESC;
        
        ELSIF p_filtro = 'SISTEMA' THEN
            OPEN p_com_refcur FOR 
            SELECT 
                S.NOME AS NOME_SISTEMA,
                COUNT(DISTINCT H.ESPECIE || H.COMUNIDADE) AS QTD_COMUNIDADES 
            FROM
                DOMINANCIA D
                INNER JOIN HABITACAO H ON D.PLANETA = H.PLANETA
                INNER JOIN ORBITA_PLANETA OP ON OP.PLANETA = D.PLANETA
                INNER JOIN SISTEMA S ON S.ESTRELA = OP.ESTRELA
            WHERE
                D.NACAO = p_nacao
            GROUP BY
                S.NOME
            ORDER BY
                QTD_COMUNIDADES DESC;
        
        ELSE
            OPEN p_com_refcur FOR 
            SELECT 
                'TOTAL COMUNIDADES',
                COUNT(DISTINCT H.ESPECIE || H.COMUNIDADE) AS QTD_COMUNIDADES
            FROM
                DOMINANCIA D INNER JOIN HABITACAO H ON D.PLANETA = H.PLANETA
            WHERE
                D.NACAO = p_nacao
            ORDER BY
                QTD_COMUNIDADES DESC;
        
        END IF;

    END RELATORIO_COMUNIDADE;    
           

    FUNCTION inicia_faccao (
        p_cpi lider.cpi%type
    )
    RETURN VARCHAR2
    IS
    v_faccao faccao.nome%type;
    BEGIN
	    SELECT
            nome
        INTO
            v_faccao 
		FROM
            faccao 
		WHERE
            lider = p_cpi;

        RETURN v_faccao;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002,'Lider nao tem faccao');

    END inicia_faccao;
    

    PROCEDURE remove_nacao_faccao (
        p_cpi lider.cpi%type,
        p_nacao nacao.nome%type,
        p_faccao faccao.nome%type
    ) IS 
        v_nacao_lider NACAO.NOME%type;
    BEGIN
            
        SELECT Nacao INTO v_nacao_lider
            FROM Lider
            WHERE CPI = p_cpi;
            
        IF v_nacao_lider = p_nacao THEN
            RAISE_APPLICATION_ERROR('Nao pode excluir a propria nacao de sua faccao');
        END IF;
    
        DELETE FROM
            nacao_faccao nf
        WHERE
            nf.nacao = p_nacao
            AND nf.faccao = p_faccao;

        commit;

    END remove_nacao_faccao;


    PROCEDURE alterar_nome_faccao (
        p_cpi           LIDER.CPI%type,
        p_faccao_old    FACCAO.NOME%type,
        p_faccao_new    FACCAO.NOME%type
    )
    IS
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
        SELECT
            Especie,
            Comunidade
        BULK COLLECT INTO
            v_comunidades_associadas
        FROM
            Participa 
        WHERE
            Faccao = p_faccao_old;

        DELETE FROM
            Participa
        WHERE
            Faccao = p_faccao_old; 
        
        -- Armazenas as tuplas de NACAO_FACCAO referentes em uma coleção e as deleta
        SELECT
            Nacao
        BULK COLLECT INTO
            v_nacoes_associadas
        FROM
            Nacao_Faccao 
        WHERE
            Faccao = p_faccao_old;

        DELETE FROM
            Nacao_Faccao
        WHERE
            Faccao = p_faccao_old;  
        
        -- Atualiza o nome da Faccao
        UPDATE Faccao SET Nome = p_faccao_new WHERE Nome = p_faccao_old;
    
        -- Reinsere os valores removidos anteriormente com o nome atualizado
        FOR i IN v_comunidades_associadas.FIRST .. v_comunidades_associadas.LAST 
        LOOP
            INSERT INTO
                Participa 
            VALUES (
                p_faccao_new,
                v_comunidades_associadas(i).tb_especie,
                v_comunidades_associadas(i).tb_comunidade
            );
        END LOOP;
        
        FOR i IN v_nacoes_associadas.FIRST .. v_nacoes_associadas.LAST 
        LOOP
            INSERT INTO
                Nacao_Faccao 
            VALUES (
                v_nacoes_associadas(i),
                p_faccao_new
            );    
        END LOOP;
        
        COMMIT;

    END alterar_nome_faccao;
    

    PROCEDURE indicar_novo_lider (
        p_lider_atual   LIDER.CPI%type,
        p_lider_novo    FACCAO.NOME%type,
        p_faccao        FACCAO.NOME%type
    ) AS
    BEGIN
        UPDATE Faccao SET
            Lider = p_lider_novo
        WHERE
            Nome = p_faccao;
        
        commit;

    END indicar_novo_lider;

END LIDER_FACCAO; 
