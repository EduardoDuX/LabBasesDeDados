CREATE OR REPLACE PACKAGE LIDER_FACCAO AS
    PROCEDURE GET_NACAO(p_cpi LIDER.CPI%TYPE);
    PROCEDURE RELATORIO_COMUNIDADE(
        p_filtro VARCHAR2, 
        p_com_refcur IN OUT SYS_REFCURSOR
    );
END LIDER_FACCAO;

/

CREATE OR REPLACE PACKAGE BODY LIDER_FACCAO AS
    -- Variável local para armazenar nação do líder (usuário)
    v_nacao NACAO.NOME%TYPE;

    -- Procedimento para recuperar a nacão do usuário
    PROCEDURE GET_NACAO(p_cpi LIDER.CPI%TYPE) IS
        BEGIN 
            SELECT NACAO INTO v_nacao FROM LIDER WHERE CPI = p_cpi;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                RAISE_APPLICATION_ERROR(-20002, 'Líder inválido');
    END GET_NACAO;
    
    -- Procedimento que gera os relatórios
    PROCEDURE RELATORIO_COMUNIDADE(
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
                    FROM DOMINANCIA D INNER JOIN HABITACAO H
                    ON D.PLANETA = H.PLANETA
                    WHERE D.NACAO = v_nacao AND H.DATA_FIM IS NULL
                    GROUP BY D.NACAO
                    ORDER BY QTD_COMUNIDADES DESC;
            
            ELSIF p_filtro = 'ESPECIE' THEN
                OPEN p_com_refcur FOR 
                    SELECT 
                        H.ESPECIE, 
                        COUNT(DISTINCT H.ESPECIE || H.COMUNIDADE) AS QTD_COMUNIDADES 
                    FROM DOMINANCIA D INNER JOIN HABITACAO H
                    ON D.PLANETA = H.PLANETA
                    WHERE D.NACAO = v_nacao AND H.DATA_FIM IS NULL
                    GROUP BY H.ESPECIE
                    ORDER BY QTD_COMUNIDADES DESC;
            
            ELSIF p_filtro = 'PLANETA' THEN
                OPEN p_com_refcur FOR 
                    SELECT 
                        D.PLANETA, 
                        COUNT(DISTINCT H.ESPECIE || H.COMUNIDADE) AS QTD_COMUNIDADES 
                    FROM DOMINANCIA D INNER JOIN HABITACAO H
                    ON D.PLANETA = H.PLANETA
                    WHERE D.NACAO = v_nacao
                    GROUP BY D.PLANETA
                    ORDER BY QTD_COMUNIDADES DESC;
            
            ELSIF p_filtro = 'SISTEMA' THEN
                OPEN p_com_refcur FOR 
                    SELECT 
                        S.NOME AS NOME_SISTEMA,
                        COUNT(DISTINCT H.ESPECIE || H.COMUNIDADE) AS QTD_COMUNIDADES 
                    FROM DOMINANCIA D INNER JOIN HABITACAO H
                    ON D.PLANETA = H.PLANETA
                    INNER JOIN ORBITA_PLANETA OP ON
                    OP.PLANETA = D.PLANETA
                    INNER JOIN SISTEMA S ON
                    S.ESTRELA = OP.ESTRELA
                    WHERE D.NACAO = v_nacao
                    GROUP BY S.NOME
                    ORDER BY QTD_COMUNIDADES DESC;
            
            ELSE
                OPEN p_com_refcur FOR 
                    SELECT 
                        'TOTAL COMUNIDADES',
                        COUNT(DISTINCT H.ESPECIE || H.COMUNIDADE) AS QTD_COMUNIDADES
                    FROM DOMINANCIA D INNER JOIN HABITACAO H
                    ON D.PLANETA = H.PLANETA
                    WHERE D.NACAO = v_nacao
                    ORDER BY QTD_COMUNIDADES DESC;
            
            END IF;
        END RELATORIO_COMUNIDADE;    
END LIDER_FACCAO;            

-- Testando os procedimentos acima
DECLARE 
    v_com_refcur SYS_REFCURSOR;
    v_filtro VARCHAR2(31);
    v_qtd_comunidades NUMBER;
BEGIN
    LIDER_FACCAO.GET_NACAO('876.563.876-90');
    LIDER_FACCAO.RELATORIO_COMUNIDADE('PLANETA', v_com_refcur);
    
    LOOP 
        FETCH v_com_refcur INTO v_filtro, v_qtd_comunidades;
        EXIT WHEN v_com_refcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_filtro || '      ' || v_qtd_comunidades);
    END LOOP;
    CLOSE v_com_refcur;
END;    