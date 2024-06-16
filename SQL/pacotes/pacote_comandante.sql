/*
Pacote para implementar as funcionalidades de gerenciamento de relatorio do comandante
*/
CREATE OR REPLACE PACKAGE COMANDANTE AS

    -- Procedure para incluir a nacao em uma federacao existente ou nova
    PROCEDURE incluir_nacao_federacao (
        p_nacao     NACAO.NOME%type,
        p_federacao FEDERACAO.NOME%type
    );

    -- Procedure para remover a federacao de uma nacao
    PROCEDURE excluir_nacao_federacao (
        p_nacao     NACAO.NOME%type
    );

    -- Procedure para registrar uma nova dominancia de uma nacao
    PROCEDURE registrar_dominancia (
        p_nacao     NACAO.NOME%type,
        p_planeta   DOMINANCIA.PLANETA%type
    );


    TYPE planeta_expansao IS RECORD (
        id_astro planeta.id_astro%type,
        classificacao planeta.classificacao%type,
        distancia_nacao NUMBER
    );


    TYPE planetas_expansao IS TABLE OF planeta_expansao;

    -- Procedure para gerar o relatorio do comandante
    PROCEDURE relatorio_comandante (
        p_nacao nacao.nome%type,
        p_com_dominancia_atual_refcur OUT SYS_REFCURSOR,
        p_com_ultima_dominancia_refcur OUT SYS_REFCURSOR,
        p_com_planetas_refcur OUT SYS_REFCURSOR,
        p_com_info_estrategica_refcur OUT SYS_REFCURSOR,
        p_com_planetas_expansao OUT planetas_expansao
    );


END COMANDANTE;

/

CREATE OR REPLACE PACKAGE BODY COMANDANTE AS
    
    -- Excecao comum, a estrela nao existe - private
    e_estrela_n_existe EXCEPTION;

    TYPE territorio IS TABLE OF estrela.id_estrela%type;
    v_territorio_nacao territorio := territorio();

    TYPE info_planetas_nao_errantes IS TABLE OF orbita_planeta%rowtype; 
    v_info_planetas info_planetas_nao_errantes := info_planetas_nao_errantes();

    TYPE distancias IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
    v_distancias distancias;


    FUNCTION distancia_estrelas (
        p_estrela1 IN estrela.id_estrela%type,
        p_estrela2 IN estrela.id_estrela%type
    )
    RETURN NUMBER 
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

        -- Busca as coordenadas da estrela 1
        SELECT
            x, y, z
        INTO
            coords_e1.x, coords_e1.y, coords_e1.z
        FROM
            estrela
        WHERE
            id_estrela = p_estrela1;

        -- Busca as coordenadas da estrela 2
        SELECT
            x, y, z
        INTO
            coords_e2.x, coords_e2.y, coords_e2.z
        FROM
            estrela
        WHERE
            id_estrela = p_estrela2;

        -- Calcula distancia entre as duas estrelas
        v_distancia := SQRT(POWER((coords_e2.x - coords_e1.x), 2) +
                POWER((coords_e2.y - coords_e1.y), 2) +
                POWER((coords_e2.z - coords_e1.z), 2));

        RETURN v_distancia;      
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE e_estrela_n_existe;
    END distancia_estrelas;


    PROCEDURE inicia_territorio_nacao (
        p_nacao nacao.nome%type
    )
    IS
    BEGIN
         -- Estrelas/sistemas que compoem o territorio de uma nacao
        SELECT 
            DISTINCT E.ID_ESTRELA 
        BULK COLLECT INTO
            v_territorio_nacao
        FROM
            DOMINANCIA D
            INNER JOIN ORBITA_PLANETA OP ON D.PLANETA = OP.PLANETA AND D.NACAO = p_nacao
            INNER JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
            INNER JOIN SISTEMA S ON E.ID_ESTRELA = S.ESTRELA;

    END inicia_territorio_nacao;


    PROCEDURE inicia_planetas_nao_errantes
    IS
    BEGIN
        -- Orbita dos planetas nao errantes
        SELECT  
            OP.PLANETA,
            OP.ESTRELA,
            OP.DIST_MIN,
            OP.DIST_MAX,
            OP.PERIODO
        BULK COLLECT INTO
            v_info_planetas
        FROM
            ORBITA_PLANETA OP
            INNER JOIN PLANETA P ON OP.PLANETA = P.ID_ASTRO
            LEFT JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA AND D.PLANETA IS NULL;

    END inicia_planetas_nao_errantes;


    PROCEDURE inicia_distancias_nacao_planetas (
        p_nacao nacao.nome%type,
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
        p_nacao nacao.nome%type,
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
            FROM
                DOMINANCIA D RIGHT JOIN PLANETA P ON P.ID_ASTRO = D.PLANETA
            WHERE
                D.DATA_FIM IS NULL
            ORDER BY
                ID_ASTRO;
        
        -- Ultima dominancia
        OPEN p_com_ultima_dominancia_refcur FOR
            SELECT 
                MAX(D.DATA_INI) AS DATA_INI,
                MAX(D.DATA_FIM) AS DATA_FIM
            FROM
                DOMINANCIA D RIGHT JOIN PLANETA P ON D.PLANETA = P.ID_ASTRO AND DATA_FIM IS NOT NULL
            GROUP BY
                P.ID_ASTRO
            ORDER BY
                P.ID_ASTRO;
        
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
            FROM
                PLANETA P LEFT JOIN HABITACAO H ON H.PLANETA = P.ID_ASTRO AND H.DATA_FIM IS NULL
                LEFT JOIN COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
                LEFT JOIN PARTICIPA PC ON PC.ESPECIE = C.ESPECIE AND PC.COMUNIDADE = C.NOME
                LEFT JOIN ESPECIE E ON E.PLANETA_OR = P.ID_ASTRO
            GROUP BY
                P.ID_ASTRO;
        
        --  Info estrategica
        OPEN p_com_info_estrategica_refcur FOR
            SELECT
                N.NOME,
                N.QTD_PLANETAS,
                N.FEDERACAO,
                COUNT(NF.FACCAO) AS QTD_FACCOES,
                COUNT(L.CPI) AS QTD_LIDERES
            FROM
                NACAO N LEFT JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
                LEFT JOIN LIDER L ON N.NOME = L.NACAO
            WHERE
                N.QTD_PLANETAS < (
                    SELECT 
                        QTD_PLANETAS
                    FROM NACAO
                    WHERE NACAO.NOME = p_nacao
                )
            GROUP BY
                N.NOME, N.QTD_PLANETAS, N.FEDERACAO
            ORDER BY
                N.QTD_PLANETAS, QTD_FACCOES DESC, QTD_LIDERES DESC;

        -- Info de planetas para expansao
        inicia_territorio_nacao(p_nacao);
        inicia_planetas_nao_errantes;
        inicia_distancias_nacao_planetas(p_nacao, v_territorio_nacao, v_info_planetas);

        v_count := 1;
        p_com_planetas_expansao := planetas_expansao();

        FOR i IN v_info_planetas.first .. v_info_planetas.last
        LOOP
            p_com_planetas_expansao.extend(1);
            p_com_planetas_expansao(v_count).id_astro := v_info_planetas(i).planeta;

            SELECT
                P.CLASSIFICACAO 
            INTO
                p_com_planetas_expansao(v_count).classificacao
            FROM
                PLANETA P
            WHERE
                P.ID_ASTRO = v_info_planetas(i).planeta;

            p_com_planetas_expansao(v_count).distancia_nacao := v_distancias(v_info_planetas(i).planeta);
            v_count := v_count + 1;
        END LOOP;

    END relatorio_comandante;

    
    PROCEDURE cria_federacao (
        p_nome_federacao federacao.nome%type,
        p_data_fund federacao.data_fund%type DEFAULT SYSDATE()
    ) IS 
    BEGIN
        INSERT INTO federacao VALUES (p_nome_federacao, p_data_fund);
        commit;
    
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR (-20001, 'federacao ja existe');

    END cria_federacao;
    

    PROCEDURE incluir_nacao_federacao (
        p_nacao     NACAO.NOME%type,
        p_federacao FEDERACAO.NOME%type
    ) AS
        e_federacao_inexistente EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_federacao_inexistente, -02291);
    BEGIN
        
        UPDATE Nacao SET Federacao = p_federacao
            WHERE Nome = p_nacao AND Federacao IS NULL;
        IF SQL%NOTFOUND THEN
            RAISE_APPLICATION_ERROR(-20500,'NACAO JA POSSUI FEDERACAO!');
        END IF;
        commit;
        EXCEPTION
            WHEN e_federacao_inexistente THEN
                comandante.cria_federacao(p_federacao);
                UPDATE
                    Nacao
                SET
                    Federacao = p_federacao
                WHERE
                    Nome = p_nacao;
                commit;
                
    END incluir_nacao_federacao;
    

    PROCEDURE excluir_nacao_federacao (
        p_nacao     NACAO.NOME%type
    ) AS
        e_federacao_inexistente EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_federacao_inexistente, -02291);
        
        e_nacao_inexistente EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_nacao_inexistente, -20500);
        
        v_count     INT;
        v_federacao FEDERACAO.NOME%type;
    BEGIN
        
        SELECT
            Federacao
        INTO
            v_federacao
        FROM
            Nacao
        WHERE
            Nome = p_nacao;
        
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            Nacao
        WHERE Federacao = v_federacao;
            
        IF v_count = 1 THEN
            DELETE FROM Federacao WHERE Nome = v_federacao;
        END IF;
        
        UPDATE
            Nacao
        SET
            Federacao = NULL
        WHERE
            Nome = p_nacao;

        IF SQL%NOTFOUND THEN
            RAISE_APPLICATION_ERROR(-20500,'Nacao invalida!');
        END IF;
        
        commit;
                    
    END excluir_nacao_federacao;
    

    PROCEDURE registrar_dominancia (
        p_nacao     NACAO.NOME%type,
        p_planeta   DOMINANCIA.PLANETA%type
    ) AS
        e_federacao_inexistente EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_federacao_inexistente, -02291);
        
        e_nacao_inexistente EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_nacao_inexistente, -20500);
        
        v_count     INT;
    BEGIN
        
        SELECT
            COUNT(*)
        INTO
            v_count
        FROM
            Dominancia
        WHERE
            planeta = p_planeta
            AND (data_fim IS NULL OR data_fim < SYSDATE());
            
        IF v_count = 0 THEN
            INSERT INTO Dominancia VALUES (p_planeta, p_nacao, SYSDATE(), NULL);
        ELSE 
            RAISE_APPLICATION_ERROR(-20600,'Planeta ja esta sob dominacao uma nacao.'); 
        END IF;
        
        commit;        
                    
    END registrar_dominancia;

END COMANDANTE;