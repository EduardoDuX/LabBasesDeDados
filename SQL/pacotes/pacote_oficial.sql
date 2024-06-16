/*
Pacote para implementar as funcionalidades de relatorio do oficial
*/

CREATE OR REPLACE PACKAGE oficial AS

    -- Relatorio das habitacoes da nacao do oficial
    PROCEDURE relatorio_habitacao(
        p_nacao NACAO.NOME%TYPE,
        p_agrupamento VARCHAR2,
        p_com_refcursor IN OUT SYS_REFCURSOR
    );
    
END oficial;
    
/

CREATE OR REPLACE PACKAGE BODY oficial AS
    

    PROCEDURE relatorio_habitacao(
        p_nacao NACAO.NOME%TYPE,
        p_agrupamento VARCHAR2,
        p_com_refcursor IN OUT SYS_REFCURSOR
    )
    IS
    BEGIN
        -- AGRUPADO POR ESPECIE
        IF p_agrupamento = 'ESPECIE' THEN
            OPEN p_com_refcursor FOR
            SELECT
                H.ESPECIE,
                SUM(QTD_HABITANTES) AS QTD_HABITANTES
            FROM
                HABITACAO H
                JOIN DOMINANCIA D ON D.PLANETA = H.PLANETA -- DOMINANCIA PARA ESCOLHER A NACAO DO LIDER
                JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE -- COMUNIDADE PARA PEGAR A QUANTIDADE DE HABITANTES
            WHERE 
                D.NACAO = p_nacao
            GROUP BY
                H.ESPECIE;
        
        -- AGRUPADO POR PLANETA
        ELSIF p_agrupamento = 'PLANETA' THEN
            OPEN p_com_refcursor FOR
            SELECT
                H.PLANETA,
                SUM(QTD_HABITANTES) AS QTD_HABITANTES
            FROM
                HABITACAO H
                JOIN DOMINANCIA D ON D.PLANETA = H.PLANETA -- DOMINANCIA PARA ESCOLHER A NACAO DO LIDER
                JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE -- COMUNIDADE PARA PEGAR A QUANTIDADE DE HABITANTES
            WHERE 
                D.NACAO = p_nacao
            GROUP BY
                H.PLANETA;

        -- AGRUPADO POR FACCAO
        ELSIF p_agrupamento = 'FACCAO' THEN
            OPEN p_com_refcursor FOR
            SELECT
                P.FACCAO,
                SUM(QTD_HABITANTES) AS QTD_HABITANTES
            FROM
            HABITACAO H
                JOIN DOMINANCIA D ON D.PLANETA = H.PLANETA -- DOMINANCIA PARA ESCOLHER A NACAO DO LIDER
                JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE -- COMUNIDADE PARA PEGAR A QUANTIDADE DE HABITANTES
                LEFT JOIN PARTICIPA P ON P.ESPECIE = C.ESPECIE AND P.COMUNIDADE = C.NOME -- PARTICIPA PARA AGRUPAR POR FACCAO
            WHERE 
                D.NACAO = p_nacao
            GROUP BY
                P.FACCAO;

        -- AGRUPADO POR SISTEMA
        ELSIF p_agrupamento = 'SISTEMA' THEN
            OPEN p_com_refcursor FOR
            SELECT
                S.NOME,
                SUM(QTD_HABITANTES) AS QTD_HABITANTES
            FROM
                HABITACAO H
                JOIN DOMINANCIA D ON D.PLANETA = H.PLANETA
                JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                LEFT JOIN ORBITA_PLANETA OP ON OP.PLANETA = H.PLANETA 
                LEFT JOIN SISTEMA S ON S.ESTRELA = OP.ESTRELA
            WHERE 
                D.NACAO = p_nacao
            GROUP BY
                S.NOME;
        
        -- SEM AGRUPAMENTO
        ELSE 
            OPEN p_com_refcursor FOR
            SELECT
                'TOTAL HABITANTES',
                SUM(QTD_HABITANTES) AS QTD_HABITANTES
            FROM
                HABITACAO H
                JOIN DOMINANCIA D ON D.PLANETA = H.PLANETA
                JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
            WHERE 
                D.NACAO = p_nacao;

        END IF;

    END relatorio_habitacao;
    
END oficial;
