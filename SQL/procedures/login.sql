CREATE OR REPLACE FUNCTION login (
arg_cpi VARCHAR2,
arg_password VARCHAR2) 
RETURN VARCHAR2
AS 
    e_password_incorrect EXCEPTION;
    v_password users.password%TYPE;
    v_cargo lider.cargo%TYPE;
    hashed_password VARCHAR2(32);
BEGIN

    SELECT u.password, l.cargo INTO v_password, v_cargo
    FROM users u
    JOIN lider l ON l.cpi = u.id_lider 
    WHERE u.id_lider = arg_cpi;
    
    SELECT standard_hash(arg_password, 'MD5') INTO hashed_password FROM dual;

    IF v_password = hashed_password THEN
        RETURN v_cargo;
    ELSE
        RAISE e_password_incorrect;
    END IF;

EXCEPTION
    WHEN e_password_incorrect THEN RETURN 'Senha Incorreta!';
    WHEN NO_DATA_FOUND THEN RETURN 'Usuario nao existe!';
END login;


select * from lider

-- TESTANDO O CODIGO ACIMA
DECLARE
    resposta VARCHAR2(100);
BEGIN
    resposta := login('123.456.789-10','senhaPadrao123');
    dbms_output.put_line(resposta);
    
    resposta := login('123.456.789-10','fqwfewqfqw');
    dbms_output.put_line(resposta);
    
    resposta := login('123.456.789-10','senhaPadrao123');
    dbms_output.put_line(resposta);
END;