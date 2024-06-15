CREATE OR REPLACE PROCEDURE LOG_MESSAGE(
    cpi lider.cpi%TYPE,
    message LOG_TABLE.MESSAGE%TYPE
) AS
    v_user LOG_TABLE.USERID%TYPE;
BEGIN

    SELECT userid into v_user from users where id_lider = cpi;
    INSERT INTO LOG_TABLE VALUES (v_user, SYSDATE(), message);
    COMMIT;
    
EXCEPTION 
    WHEN NO_DATA_FOUND THEN    
        RAISE_APPLICATION_ERROR(-20001, 'Usuario nao cadastrado!');
END;