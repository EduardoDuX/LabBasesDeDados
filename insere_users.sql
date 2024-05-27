CREATE OR REPLACE PROCEDURE INSERE_USERS
AS
    TYPE t_users IS TABLE OF USERS.ID_LIDER%TYPE;
    v_users t_users;
BEGIN
    SELECT 
    L.CPI
    BULK COLLECT INTO v_users
    FROM LIDER L
    LEFT JOIN USERS U
    ON L.CPI = U.ID_LIDER
    WHERE USERID IS NULL; -- busca os lideres sem entrada na tabela users

    -- itera os lideres sem entrada e os insere em users com a senha `senhaPadrao123`
    FOR j IN 1..v_users.COUNT() LOOP
        INSERT INTO USERS (PASSWORD,ID_LIDER) VALUES (standard_hash('senhaPadrao123', 'MD5'), v_users(j));
    END LOOP;
END;


-- Execucao do procedure
BEGIN
    INSERE_USERS;
END;