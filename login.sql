CREATE OR REPLACE FUNCTION login (
arg_userid VARCHAR2,
arg_password VARCHAR2) 
RETURN VARCHAR2
AS 
    e_password_incorrect EXCEPTION;
    v_password users.password%TYPE;
    hashed_password VARCHAR2(32);
BEGIN

    SELECT u.password INTO v_password FROM users u
    WHERE u.userid = arg_userid;
    
    SELECT standard_hash(arg_password, 'MD5') INTO hashed_password FROM dual;

    IF v_password = hashed_password THEN
        RETURN 'Sucesso!';
    ELSE
        RAISE e_password_incorrect;
    END IF;

EXCEPTION
    WHEN e_password_incorrect THEN RETURN 'Senha Incorreta!';
    WHEN NO_DATA_FOUND THEN RETURN 'Usuario nao existe!';
END login;


-- TESTANDO O CODIGO ACIMA
DECLARE
    resposta VARCHAR2(100);
BEGIN
    resposta := login(1,'senhaPadrao123');
    dbms_output.put_line(resposta);
    
    resposta := login(1,'fqwfewqfqw');
    dbms_output.put_line(resposta);
    
    resposta := login(11,'senhaPadrao123');
    dbms_output.put_line(resposta);
END;