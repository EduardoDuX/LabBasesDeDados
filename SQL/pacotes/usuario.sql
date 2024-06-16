CREATE OR REPLACE PACKAGE USUARIO AS

    FUNCTION inicia_nacao (
        p_cpi lider.cpi%type
    )RETURN VARCHAR2;

    PROCEDURE LOG_MESSAGE(
        cpi lider.cpi%TYPE,
        message LOG_TABLE.MESSAGE%TYPE
    );

    FUNCTION login (
        arg_cpi VARCHAR2,
        arg_password VARCHAR2) 
    RETURN VARCHAR2;

END USUARIO;


/

CREATE OR REPLACE PACKAGE BODY USUARIO AS

    FUNCTION inicia_nacao (
        p_cpi lider.cpi%type
    )
    RETURN VARCHAR2
    IS
    v_nacao nacao.nome%type;
    BEGIN
        SELECT nacao INTO v_nacao FROM lider where lider.cpi= p_cpi;
        return v_nacao;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002,'Lider invalido');
    END inicia_nacao;


    PROCEDURE LOG_MESSAGE(
        cpi lider.cpi%TYPE,
        message LOG_TABLE.MESSAGE%TYPE
    ) IS
        v_user LOG_TABLE.USERID%TYPE;
    BEGIN
        SELECT userid into v_user from users where id_lider = cpi;
        INSERT INTO LOG_TABLE VALUES (v_user, SYSDATE(), message);
        COMMIT;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN    
            RAISE_APPLICATION_ERROR(-20001, 'Usuario nao cadastrado!');
    END;
    
    FUNCTION login (
        arg_cpi VARCHAR2,
        arg_password VARCHAR2) 
    RETURN VARCHAR2
    IS 
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

END USUARIO;