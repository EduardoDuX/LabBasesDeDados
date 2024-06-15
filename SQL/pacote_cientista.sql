CREATE OR REPLACE PACKAGE cientista AS

    PROCEDURE cria_estrela_com_sistema (
        p_id IN ESTRELA.ID_ESTRELA%type,
        p_sistema IN SISTEMA.NOME%type,
        p_nome IN ESTRELA.NOME%type,
        p_classificacao IN ESTRELA.CLASSIFICACAO%type,
        p_massa IN ESTRELA.MASSA%type,
        p_x IN ESTRELA.X%type,
        p_y IN ESTRELA.Y%type,
        p_z IN ESTRELA.Z%type
    );
    PROCEDURE cria_estrela_orbitante (
        p_id IN ESTRELA.ID_ESTRELA%type,
        p_nome IN ESTRELA.NOME%type,
        p_classificacao IN ESTRELA.CLASSIFICACAO%type,
        p_massa IN ESTRELA.MASSA%type,
        p_x IN ESTRELA.X%type,
        p_y IN ESTRELA.Y%type,
        p_z IN ESTRELA.Z%type,
        p_orbitada IN ESTRELA.ID_ESTRELA%type,
        p_dist_min IN ORBITA_ESTRELA.DIST_MIN%type,
        p_dist_max IN ORBITA_ESTRELA.DIST_MAX%type,
        p_periodo  IN ORBITA_ESTRELA.PERIODO%type
    );
    PROCEDURE le_estrela (
        p_conjunto_estrelas OUT SYS_REFCURSOR
    );
    PROCEDURE le_estrela_id (
        p_id IN ESTRELA.ID_ESTRELA%type,
        return_refcursor OUT SYS_REFCURSOR
    );
    PROCEDURE le_estrela_nome (
        p_nome IN ESTRELA.NOME%type,
        p_conjunto_estrelas OUT SYS_REFCURSOR
    );
    PROCEDURE le_estrela_classificacao (
        p_classificacao IN ESTRELA.CLASSIFICACAO%type,
        p_conjunto_estrelas OUT SYS_REFCURSOR
    );
    PROCEDURE le_estrela_massa (
        mass_roof  IN ESTRELA.MASSA%type,
        return_refcursor OUT SYS_REFCURSOR,
        mass_floor IN ESTRELA.MASSA%type DEFAULT 0
    );
    PROCEDURE atualiza_estrela_nome (
        p_id    IN  ESTRELA.ID_ESTRELA%type,
        p_nome  IN  ESTRELA.NOME%type
    );
    PROCEDURE atualiza_estrela_massa (
        p_id    IN  ESTRELA.ID_ESTRELA%type,
        p_massa IN  ESTRELA.NOME%type
    );
    PROCEDURE atualiza_estrela_classificacao (
        p_id    IN  ESTRELA.ID_ESTRELA%type,
        p_class IN  ESTRELA.NOME%type
    );
    PROCEDURE atualiza_estrela_coordenadas (
        p_id    IN  ESTRELA.ID_ESTRELA%type,
        p_x     IN  ESTRELA.X%type,
        p_y     IN  ESTRELA.Y%type,
        p_z     IN  ESTRELA.Z%type
    );
    PROCEDURE remove_estrela (
        p_id IN ESTRELA.ID_ESTRELA%type
    ); 
    
    PROCEDURE report_estrela(
        id estrela.id_estrela%TYPE DEFAULT NULL,
        p_com_refcursor IN OUT SYS_REFCURSOR
    );
        
    PROCEDURE report_planeta(
        id planeta.id_astro%TYPE DEFAULT NULL,
        p_com_refcursor IN OUT SYS_REFCURSOR
    );
    PROCEDURE report_sistema(
        e sistema.estrela%TYPE DEFAULT NULL,
        p_com_refcursor IN OUT SYS_REFCURSOR
    );
    
    
END gerenciamento_cientista;

/

CREATE OR REPLACE PACKAGE BODY gerenciamento_cientista AS

    PROCEDURE cria_estrela_com_sistema (
        p_id IN ESTRELA.ID_ESTRELA%type,
        p_sistema IN SISTEMA.NOME%type,
        p_nome IN ESTRELA.NOME%type,
        p_classificacao IN ESTRELA.CLASSIFICACAO%type,
        p_massa IN ESTRELA.MASSA%type,
        p_x IN ESTRELA.X%type,
        p_y IN ESTRELA.Y%type,
        p_z IN ESTRELA.Z%type
    ) AS
        e_atributo_nao_nulo EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_atributo_nao_nulo, -01400); 
    
    BEGIN
        INSERT INTO ESTRELA
            VALUES (p_id, p_nome, p_classificacao, p_massa, p_x, p_y, p_z);

        INSERT INTO SISTEMA
            VALUES (p_id, p_sistema);
    
        COMMIT;
        
        EXCEPTION
            WHEN e_atributo_nao_nulo THEN
                RAISE_APPLICATION_ERROR(-20004, 'Atributo com valor obrigatorio!');
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20006, 'Estrela ja existente!');
                --   Como sistema é sempre associado a uma Estrela, podemos utilizar esta mensagem de erro,
                -- pois a chave duplicada sempre acontecerá primeiro em Estrela.
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro numero: ' || SQLCODE 
                                        || '. Mensagem: ' || SQLERRM);
    END cria_estrela_com_sistema;
    
    PROCEDURE cria_estrela_orbitante (
        p_id IN ESTRELA.ID_ESTRELA%type,
        p_nome IN ESTRELA.NOME%type,
        p_classificacao IN ESTRELA.CLASSIFICACAO%type,
        p_massa IN ESTRELA.MASSA%type,
        p_x IN ESTRELA.X%type,
        p_y IN ESTRELA.Y%type,
        p_z IN ESTRELA.Z%type,
        p_orbitada IN ESTRELA.ID_ESTRELA%type,
        p_dist_min IN ORBITA_ESTRELA.DIST_MIN%type,
        p_dist_max IN ORBITA_ESTRELA.DIST_MAX%type,
        p_periodo  IN ORBITA_ESTRELA.PERIODO%type
    ) AS
        e_atributo_nao_nulo EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_atributo_nao_nulo, -01400); 
    BEGIN

        INSERT INTO ESTRELA
            VALUES (p_id, p_nome, p_classificacao, p_massa, p_x, p_y, p_z);

        INSERT INTO ORBITA_ESTRELA
            VALUES (p_id, p_orbitada, p_dist_min, p_dist_max, p_periodo);
    
        COMMIT;
        
        EXCEPTION
            WHEN e_atributo_nao_nulo THEN
                RAISE_APPLICATION_ERROR(-20004, 'Atributo com valor obrigatorio!');
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20006, 'Estrela ja existente!');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro numero: ' || SQLCODE 
                                        || '. Mensagem: ' || SQLERRM);
    END cria_estrela_orbitante;

    PROCEDURE le_estrela (
        p_conjunto_estrelas OUT SYS_REFCURSOR
    ) AS
    BEGIN
        OPEN p_conjunto_estrelas FOR
            SELECT * FROM ESTRELA;
    END le_estrela;
    
    PROCEDURE le_estrela_id (
        p_id IN ESTRELA.ID_ESTRELA%type,
        return_refcursor OUT SYS_REFCURSOR
    ) AS
    BEGIN
        OPEN return_refcursor FOR 
            SELECT *
                FROM ESTRELA
                WHERE ID_ESTRELA = p_id;
    END le_estrela_id;
    
    PROCEDURE le_estrela_nome (
        p_nome IN ESTRELA.NOME%type,
        p_conjunto_estrelas OUT SYS_REFCURSOR
    ) AS
    BEGIN
        OPEN p_conjunto_estrelas FOR
            SELECT * FROM ESTRELA
                WHERE NOME = p_nome;
    END le_estrela_nome;
    
    PROCEDURE le_estrela_classificacao (
        p_classificacao IN ESTRELA.CLASSIFICACAO%type,
        p_conjunto_estrelas OUT SYS_REFCURSOR
    ) AS
    BEGIN
        OPEN p_conjunto_estrelas FOR
            SELECT * FROM ESTRELA
                WHERE CLASSIFICACAO = p_classificacao;
    END le_estrela_classificacao;
    
    PROCEDURE le_estrela_massa (
        mass_roof  IN ESTRELA.MASSA%type,
        return_refcursor OUT SYS_REFCURSOR,
        mass_floor IN ESTRELA.MASSA%type DEFAULT 0
    ) AS
    BEGIN
        OPEN return_refcursor FOR 
            SELECT *
                FROM ESTRELA
                WHERE Massa > mass_floor
                  AND Massa <= mass_roof;
    END le_estrela_massa;
    
    PROCEDURE atualiza_estrela_nome (
        p_id    IN  ESTRELA.ID_ESTRELA%type,
        p_nome  IN  ESTRELA.NOME%type
    ) AS
    BEGIN
        UPDATE ESTRELA SET Nome = p_nome
            WHERE Id_estrela = p_id;
    END atualiza_estrela_nome;
    
    PROCEDURE atualiza_estrela_massa (
        p_id    IN  ESTRELA.ID_ESTRELA%type,
        p_massa IN  ESTRELA.NOME%type
    ) AS
        e_massa_negativa EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_massa_negativa, -02290);
    BEGIN
        UPDATE ESTRELA SET Massa = p_massa
            WHERE Id_estrela = p_id;
        EXCEPTION
            WHEN e_massa_negativa THEN
                RAISE_APPLICATION_ERROR(-20100, 'Massa deve ser maior que 0!');
    END atualiza_estrela_massa;
    
    PROCEDURE atualiza_estrela_classificacao (
        p_id    IN  ESTRELA.ID_ESTRELA%type,
        p_class IN  ESTRELA.NOME%type
    ) AS
    BEGIN
        UPDATE ESTRELA SET Classificacao = p_class
            WHERE Id_estrela = p_id;
    END atualiza_estrela_classificacao;
    
    PROCEDURE atualiza_estrela_coordenadas (
        p_id    IN  ESTRELA.ID_ESTRELA%type,
        p_x     IN  ESTRELA.X%type,
        p_y     IN  ESTRELA.Y%type,
        p_z     IN  ESTRELA.Z%type
    ) AS
    BEGIN
        UPDATE ESTRELA 
            SET X = p_x,
                Y = p_y,
                Z = p_z
            WHERE Id_estrela = p_id;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20101, 'Coordenadas conflitantes com outra estrela.');
    END atualiza_estrela_coordenadas;
    
    PROCEDURE remove_estrela (
        p_id IN ESTRELA.ID_ESTRELA%type
    ) AS
    BEGIN
        DELETE FROM ESTRELA WHERE ID_ESTRELA = p_id;
    
        COMMIT;
    
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro numero: ' || SQLCODE 
                                        || '. Mensagem: ' || SQLERRM);
    END remove_estrela;
    
    
    PROCEDURE report_estrela(
        id estrela.id_estrela%TYPE DEFAULT NULL,
        p_com_refcursor IN OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF id IS NOT NULL
        THEN
            OPEN p_com_refcursor FOR
            SELECT 
                id_estrela,
                x,
                y,
                z,
                nome,
                classificacao,
                massa
            FROM ESTRELA e WHERE e.id_estrela = id;
        ELSE
            OPEN p_com_refcursor FOR
            SELECT 
                id_estrela,
                x,
                y,
                z,
                nome,
                classificacao,
                massa
            FROM ESTRELA;
        END IF;
    END report_estrela;


    PROCEDURE report_planeta(
        id planeta.id_astro%TYPE DEFAULT NULL,
        p_com_refcursor IN OUT SYS_REFCURSOR
        ) IS
    BEGIN
        IF id IS NOT NULL THEN
            OPEN p_com_refcursor FOR
            SELECT 
                id_astro,
                massa,
                raio,
                classificacao
            FROM planeta p WHERE p.id_astro= id;
        ELSE
            OPEN p_com_refcursor FOR
            SELECT 
                    id_astro,
                    massa,
                    raio,
                    classificacao
            FROM planeta;
        END IF;
    END report_planeta;
        
    PROCEDURE report_sistema(
        e sistema.estrela%TYPE DEFAULT NULL,
        p_com_refcursor IN OUT SYS_REFCURSO)
        IS
    BEGIN
        IF e IS NOT NULL THEN
            OPEN p_com_refcursor FOR
            SELECT 
                estrela,
                nome
            FROM sistema s WHERE s.estrela = e;
        ELSE
            OPEN p_com_refcursor FOR
            SELECT 
                estrela,
                nome
            FROM sistema;
        END IF;
    END report_sistema;
    
END cientista;
