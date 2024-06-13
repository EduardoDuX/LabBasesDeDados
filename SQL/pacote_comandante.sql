CREATE OR REPLACE PACKAGE COMANDANTE AS
    PROCEDURE RELATORIO_COMANDANTE(
        p_com_dominancia_atual_refcur OUT SYS_REFCURSOR,
        p_com_ultima_dominancia_refcur OUT SYS_REFCURSOR,
        p_com_planetas_refcur OUT SYS_REFCURSOR,
        p_com_planetas_expansao_refcur OUT SYS_REFCURSOR
    );

END COMANDANTE;

/

CREATE OR REPLACE PACKAGE BODY COMANDANTE AS
    PROCEDURE RELATORIO_COMANDANTE (
        p_com_dominancia_atual_refcur OUT SYS_REFCURSOR,
        p_com_ultima_dominancia_refcur OUT SYS_REFCURSOR,
        p_com_planetas_refcur OUT SYS_REFCURSOR,
        p_com_planetas_expansao_refcur OUT SYS_REFCURSOR
    )
    IS
        BEGIN
            -- Dominancias atuais
            OPEN p_com_dominancia_atual_refcur FOR
                SELECT 
                    D.NACAO 
                FROM DOMINANCIA D RIGHT JOIN PLANETA P
                ON P.ID_ASTRO = D.PLANETA
                WHERE D.DATA_FIM IS NULL
                ORDER BY ID_ASTRO;
            
            -- Ultima dominancia
            OPEN p_com_ultima_dominancia_refcur FOR
                SELECT 
                    MAX(D.DATA_INI) AS DATA_INI,
                    MAX(D.DATA_FIM) AS DATA_FIM
                FROM DOMINANCIA D RIGHT JOIN PLANETA P
                ON D.PLANETA = P.ID_ASTRO AND DATA_FIM IS NOT NULL
                GROUP BY P.ID_ASTRO
                ORDER BY P.ID_ASTRO;
            
            -- Info dos planetas
            OPEN p_com_planetas_refcur FOR
                SELECT 
                    P.ID_ASTRO, 
                    COUNT(C.NOME) AS QTD_COMUNIDADES, 
                    COUNT(DISTINCT C.ESPECIE) AS QTD_ESPECIES, 
                    NVL(SUM(C.QTD_HABITANTES), 0) AS QTD_HABITANTES, 
                    COUNT(DISTINCT PC.FACCAO) AS QTD_FACCOES, 
                    STATS_MODE(PC.FACCAO) AS FACCAO_MAJORITARIA, 
                    COUNT(DISTINCT E.NOME) AS QTD_ESPECIES_ORIGINARIAS
                FROM PLANETA P
                LEFT JOIN HABITACAO H
                ON H.PLANETA = P.ID_ASTRO AND H.DATA_FIM IS NULL
                LEFT JOIN COMUNIDADE C 
                ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
                LEFT JOIN PARTICIPA PC  
                ON PC.ESPECIE = C.ESPECIE AND PC.COMUNIDADE = C.NOME
                LEFT JOIN ESPECIE E 
                ON E.PLANETA_OR = P.ID_ASTRO
                GROUP BY P.ID_ASTRO;
            
            -- Info dos planetas para expansao
            OPEN p_com_planetas_expansao_refcur FOR
                SELECT 
                    P.ID_ASTRO, 
                    P.MASSA, 
                    P.RAIO, 
                    P.CLASSIFICACAO
                FROM ORBITA_PLANETA OP INNER JOIN PLANETA P
                ON OP.PLANETA = P.ID_ASTRO
                LEFT JOIN DOMINANCIA D
                ON P.ID_ASTRO = D.PLANETA
                WHERE D.PLANETA IS NULL;

        END RELATORIO_COMANDANTE;
END COMANDANTE;