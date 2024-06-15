CREATE OR REPLACE PACKAGE oficial AS
    PROCEDURE inicia_nacao (
        p_cpi lider.cpi%type
    );
    PROCEDURE relatorio_habitacao(agrupamento VARCHAR2);
    
    END oficial;
    
/

CREATE OR REPLACE PACKAGE BODY oficial AS
    v_nacao nacao.nome%type; -- Variável privada com a nacao do lider, preenchida com o procedure 'inicia_nacao'
    
    -- Procedimento deve ser executado imediatamente após o login
    -- Descobre, dado o lider, qual sua nacao
    PROCEDURE inicia_nacao (
        p_cpi lider.cpi%type
    )
    IS
    BEGIN
        SELECT nacao INTO v_nacao FROM lider where lider.cpi= p_cpi;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002,'Lider invalido');
            -- Lider sem nacao não existe, portanto um erro aqui seria um problema de aplicação
    END inicia_nacao;
    
    PROCEDURE relatorio_habitacao(
        agrupamento VARCHAR2
    )
    IS
        TYPE resultado IS RECORD (
            agrupamento VARCHAR2(31), -- TAMANHO DO MAIOR NOME POSSIVEL (SISTEMA)
            habitantes NUMBER
        );
        TYPE t_resultado IS TABLE OF resultado;
        v_resultado t_resultado;
    BEGIN
        IF agrupamento = 'ESPECIE'
            THEN
            -- AGRUPADO POR ESPECIE
            SELECT
                H.ESPECIE,
                SUM(QTD_HABITANTES) AS QTD_HABITANTES
                BULK COLLECT INTO v_resultado
            FROM
            HABITACAO H
            JOIN DOMINANCIA D ON D.PLANETA = H.PLANETA -- DOMINANCIA PARA ESCOLHER A NACAO DO LIDER
            JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE -- COMUNIDADE PARA PEGAR A QUANTIDADE DE HABITANTES
            WHERE 
            D.NACAO = v_nacao
            GROUP BY
            H.ESPECIE;
        ELSIF agrupamento = 'PLANETA'
            THEN
            -- AGRUPADO POR PLANETA
            SELECT
                H.PLANETA,
                SUM(QTD_HABITANTES) AS QTD_HABITANTES
                BULK COLLECT INTO v_resultado
            FROM
            HABITACAO H
            JOIN DOMINANCIA D ON D.PLANETA = H.PLANETA -- DOMINANCIA PARA ESCOLHER A NACAO DO LIDER
            JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE -- COMUNIDADE PARA PEGAR A QUANTIDADE DE HABITANTES
            WHERE 
            D.NACAO = v_nacao
            GROUP BY
            H.PLANETA;
        ELSIF agrupamento = 'FACCAO'
            THEN
            -- AGRUPADO POR FACCAO
            SELECT
                P.FACCAO,
                SUM(QTD_HABITANTES) AS QTD_HABITANTES
                BULK COLLECT INTO v_resultado
            FROM
            HABITACAO H
            JOIN DOMINANCIA D ON D.PLANETA = H.PLANETA -- DOMINANCIA PARA ESCOLHER A NACAO DO LIDER
            JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE -- COMUNIDADE PARA PEGAR A QUANTIDADE DE HABITANTES
            LEFT JOIN PARTICIPA P ON P.ESPECIE = C.ESPECIE AND P.COMUNIDADE = C.NOME -- PARTICIPA PARA AGRUPAR POR FACCAO
            WHERE 
            D.NACAO = v_nacao
            GROUP BY
            P.FACCAO;
        ELSIF agrupamento = 'SISTEMA'
            THEN
            -- AGRUPADO POR SISTEMA
            SELECT
                S.NOME,
                SUM(QTD_HABITANTES) AS QTD_HABITANTES
                BULK COLLECT INTO v_resultado
            FROM
            HABITACAO H
            JOIN DOMINANCIA D ON D.PLANETA = H.PLANETA
            JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
            LEFT JOIN ORBITA_PLANETA OP ON OP.PLANETA = H.PLANETA 
            LEFT JOIN SISTEMA S ON S.ESTRELA = OP.ESTRELA
            WHERE 
            D.NACAO = v_nacao
            GROUP BY
            S.NOME;
        ELSE 
            SELECT
                'TOTAL HABITANTES',
                SUM(QTD_HABITANTES) AS QTD_HABITANTES
                BULK COLLECT INTO v_resultado
            FROM
            HABITACAO H
            JOIN DOMINANCIA D ON D.PLANETA = H.PLANETA
            JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
            WHERE 
            D.NACAO = v_nacao;
        END IF;
    
    -- DEVOLVE O RESULTADO
    IF v_resultado.first IS NULL
        THEN
            dbms_output.put_line('TOTAL HABITANTES: 0');
    ELSE
        FOR ITEM IN v_resultado.first .. v_resultado.last
        LOOP
            IF v_resultado(ITEM).agrupamento IS NULL
                THEN v_resultado(ITEM).agrupamento := 'OUTROS HABITANTES';
            END IF;
            IF v_resultado(ITEM).habitantes IS NULL
                THEN v_resultado(ITEM).habitantes := 0;
            END IF;
            dbms_output.put_line(v_resultado(ITEM).agrupamento || ': ' ||v_resultado(ITEM).habitantes);
        END LOOP;
    END IF;
    END relatorio_habitacao;
END oficial;


-- TESTANDO O CODIGO ACIMA
BEGIN
oficial.inicia_nacao('123.456.789-10');
oficial.relatorio_habitacao('');
--oficial.relatorio_habitacao('PLANETA');
--oficial.relatorio_habitacao('SISTEMA');
--oficial.relatorio_habitacao('ESPECIE');
--oficial.relatorio_habitacao('FACCAO');
END;

