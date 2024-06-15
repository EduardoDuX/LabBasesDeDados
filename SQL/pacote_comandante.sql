CREATE OR REPLACE PACKAGE COMANDANTE AS
    TYPE planeta_expansao IS RECORD (
        id_astro planeta.id_astro%type,
        classificacao planeta.classificacao%type,
        distancia_nacao NUMBER
    );

    TYPE planetas_expansao IS TABLE OF planeta_expansao;

    PROCEDURE inicia_nacao (
        p_cpi lider.cpi%type
    );

    PROCEDURE relatorio_comandante (
        p_com_dominancia_atual_refcur OUT SYS_REFCURSOR,
        p_com_ultima_dominancia_refcur OUT SYS_REFCURSOR,
        p_com_planetas_refcur OUT SYS_REFCURSOR,
        p_com_info_estrategica_refcur OUT SYS_REFCURSOR,
        p_com_planetas_expansao OUT planetas_expansao
    );

END COMANDANTE;

/

CREATE OR REPLACE PACKAGE BODY COMANDANTE AS
    -- Exceção privada
    e_estrela_n_existe EXCEPTION;

    /*  Variável privada com a nacao do lider, preenchida com o procedure
        'inicia_nacao' */
    v_nacao nacao.nome%type; 

    TYPE territorio IS TABLE OF estrela.id_estrela%type;
    v_territorio_nacao territorio := territorio();

    TYPE info_planetas_nao_errantes IS TABLE OF orbita_planeta%rowtype; 
    v_info_planetas info_planetas_nao_errantes := info_planetas_nao_errantes();

    TYPE distancias IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
    v_distancias distancias;
    
    /*  Procedimento deve ser executado imediatamente apos o login
        Descobre, dado o lider, qual sua nação */
    PROCEDURE inicia_nacao (
        p_cpi IN lider.cpi%type
    )
    IS
    BEGIN
        SELECT nacao INTO v_nacao FROM lider WHERE  lider.cpi = p_cpi;
    EXCEPTION
        /* Lider sem nação não existe, portanto um erro aqui seria um problema 
            de aplicação */
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Lider invalido');
    END inicia_nacao;

    FUNCTION distancia_estrelas (
        p_estrela1 IN estrela.id_estrela%type,
        p_estrela2 IN estrela.id_estrela%type
    ) RETURN NUMBER 
    IS
        TYPE coords IS RECORD (
            x estrela.x%type,
            y estrela.y%type,
            z estrela.z%type
        );
        
        coords_e1 coords;
        coords_e2 coords;
        v_distancia NUMBER;    
    BEGIN
        SELECT x, y, z INTO coords_e1.x, coords_e1.y, coords_e1.z
        FROM estrela WHERE id_estrela = p_estrela1;
        SELECT x,y,z INTO coords_e2.x, coords_e2.y, coords_e2.z
        FROM estrela WHERE id_estrela = p_estrela2;
        v_distancia := SQRT(POWER((coords_e2.x - coords_e1.x), 2) +
                POWER((coords_e2.y - coords_e1.y), 2) +
                POWER((coords_e2.z - coords_e1.z), 2));

        RETURN v_distancia;      
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE e_estrela_n_existe;
    END;

    PROCEDURE inicia_territorio_nacao
    IS
    BEGIN
         -- Estrelas/Sistemas que compõem o território de uma nação
        SELECT 
            DISTINCT E.ID_ESTRELA 
        BULK COLLECT INTO v_territorio_nacao
        FROM DOMINANCIA D INNER JOIN ORBITA_PLANETA OP
        ON D.PLANETA = OP.PLANETA AND D.NACAO = v_nacao
        INNER JOIN ESTRELA E
        ON OP.ESTRELA = E.ID_ESTRELA
        INNER JOIN SISTEMA S
        ON E.ID_ESTRELA = S.ESTRELA;
    END inicia_territorio_nacao;

    PROCEDURE inicia_planetas_nao_errantes
    IS
    BEGIN
        -- Orbita dos planetas não errantes
        SELECT  
            OP.PLANETA,
            OP.ESTRELA,
            OP.DIST_MIN,
            OP.DIST_MAX,
            OP.PERIODO
        BULK COLLECT INTO v_info_planetas
        FROM ORBITA_PLANETA OP INNER JOIN PLANETA P
        ON OP.PLANETA = P.ID_ASTRO
        LEFT JOIN DOMINANCIA D
        ON P.ID_ASTRO = D.PLANETA AND D.PLANETA IS NULL;
    END inicia_planetas_nao_errantes;

    PROCEDURE inicia_distancias_nacao_planetas (
        p_territorio_nacao IN territorio,
        p_planetas IN info_planetas_nao_errantes
    ) 
    IS 
        v_distancia NUMBER;
        v_count NUMBER;
    BEGIN
        -- Calculo das distancias
        FOR i IN p_planetas.first .. p_planetas.last
        LOOP
            FOR j in p_territorio_nacao.first .. p_territorio_nacao.last
            LOOP
                v_distancia := distancia_estrelas(
                    p_planetas(i).estrela,
                    p_territorio_nacao(j)
                ) + (
                    p_planetas(i).dist_min + 
                    p_planetas(i).dist_max
                ) / 2;

                IF j = 1 AND NOT v_distancias.exists(p_planetas(i).planeta) THEN 
                    v_distancias(p_planetas(i).planeta) := v_distancia;
                ELSIF v_distancia < v_distancias(p_planetas(i).planeta) THEN
                    v_distancias(p_planetas(i).planeta) := v_distancia;
                END IF;
            END LOOP;
        END LOOP;
    END inicia_distancias_nacao_planetas;

    PROCEDURE relatorio_comandante (
        p_com_dominancia_atual_refcur OUT SYS_REFCURSOR,
        p_com_ultima_dominancia_refcur OUT SYS_REFCURSOR,
        p_com_planetas_refcur OUT SYS_REFCURSOR,
        p_com_info_estrategica_refcur OUT SYS_REFCURSOR,
        p_com_planetas_expansao OUT planetas_expansao
    )
    IS
        v_count NUMBER;
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
            FROM PLANETA P LEFT JOIN HABITACAO H
            ON H.PLANETA = P.ID_ASTRO AND H.DATA_FIM IS NULL
            LEFT JOIN COMUNIDADE C 
            ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
            LEFT JOIN PARTICIPA PC  
            ON PC.ESPECIE = C.ESPECIE AND PC.COMUNIDADE = C.NOME
            LEFT JOIN ESPECIE E 
            ON E.PLANETA_OR = P.ID_ASTRO
            GROUP BY P.ID_ASTRO;
        
        --  Info estrategica
        OPEN p_com_info_estrategica_refcur FOR
            SELECT
                N.NOME,
                N.QTD_PLANETAS,
                N.FEDERACAO,
                COUNT(NF.FACCAO) AS QTD_FACCOES,
                COUNT(L.CPI) AS QTD_LIDERES
            FROM NACAO N LEFT JOIN NACAO_FACCAO NF
            ON N.NOME = NF.NACAO
            LEFT JOIN LIDER L
            ON N.NOME = L.NACAO
            WHERE N.QTD_PLANETAS < (
                SELECT 
                    QTD_PLANETAS
                FROM NACAO
                WHERE NACAO.NOME = v_nacao
            )
            GROUP BY N.NOME, N.QTD_PLANETAS, N.FEDERACAO
            ORDER BY N.QTD_PLANETAS, QTD_FACCOES DESC, QTD_LIDERES DESC;

        -- Info de planetas para expansao
        inicia_territorio_nacao;
        inicia_planetas_nao_errantes;
        inicia_distancias_nacao_planetas(v_territorio_nacao, v_info_planetas);

        v_count := 1;
        p_com_planetas_expansao := planetas_expansao();
        FOR i IN v_info_planetas.first .. v_info_planetas.last
        LOOP
            p_com_planetas_expansao.extend(1);
            p_com_planetas_expansao(v_count).id_astro := v_info_planetas(i).planeta;
            SELECT P.CLASSIFICACAO 
                INTO p_com_planetas_expansao(v_count).classificacao
            FROM PLANETA P
            WHERE P.ID_ASTRO = v_info_planetas(i).planeta;
            p_com_planetas_expansao(v_count).distancia_nacao := v_distancias(v_info_planetas(i).planeta);
            v_count := v_count + 1;
        END LOOP;

    END relatorio_comandante;
END COMANDANTE;