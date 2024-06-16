/*
Pacote para implementar as funcionalidades gerais de um usuario
*/
CREATE OR REPLACE PACKAGE USUARIO AS

    -- Funcao que retorna para a aplicacao a nacao do usuario
    FUNCTION inicia_nacao (
        p_cpi lider.cpi%type
    )
    RETURN VARCHAR2;

    -- Funcao que retorna para a aplicacao o nome do usuario
    FUNCTION inicia_nome (
        p_cpi_nome lider.cpi%type
    )
    RETURN VARCHAR2;

    -- Procedure que faz o log de uma acao do usuario
    PROCEDURE LOG_MESSAGE(
        cpi lider.cpi%TYPE,
        message LOG_TABLE.MESSAGE%TYPE
    );

    -- Funcao que verifica credenciais e faz login do usuario
    FUNCTION login (
        arg_cpi VARCHAR2,
        arg_password VARCHAR2
    )
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
        SELECT
            nacao
        INTO
            v_nacao
        FROM
            lider
        WHERE
            lider.cpi= p_cpi;
        RETURN v_nacao;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002,'Lider invalido');

    END inicia_nacao;

    FUNCTION inicia_nome (
        p_cpi_nome lider.cpi%type
    )
    RETURN VARCHAR2
    IS
        v_nome lider.nome%type;
    BEGIN 
        SELECT
            nome
        INTO
            v_nome
        FROM
            lider
        WHERE
            lider.cpi = p_cpi_nome;   
        RETURN v_nome;
    
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            RETURN ' '

    END inicia_nome;

    PROCEDURE LOG_MESSAGE(
        cpi lider.cpi%TYPE,
        message LOG_TABLE.MESSAGE%TYPE
    ) IS
        v_user LOG_TABLE.USERID%TYPE;
    BEGIN
        SELECT
            userid
        INTO
            v_user
        FROM
            users
        WHERE
            id_lider = cpi;
        
        INSERT INTO LOG_TABLE
            VALUES (v_user, SYSDATE(), message);

        COMMIT;

    EXCEPTION 
        WHEN NO_DATA_FOUND THEN    
            RAISE_APPLICATION_ERROR(-20001, 'Usuario nao cadastrado!');

    END LOG_MESSAGE;
    
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

        -- Busca senha e usuario na tentativa de login
        SELECT
            u.password,
            l.cargo
        INTO
            v_password,
            v_cargo
        FROM
            users u
            JOIN lider l ON l.cpi = u.id_lider 
        WHERE
            u.id_lider = arg_cpi;
    
        -- Select para aplicar criptografia na senha
        SELECT
            standard_hash(arg_password, 'MD5')
        INTO
            hashed_password
        FROM dual;
    
        -- Compara as senhas e retorna o cargo do lider se sucesso
        IF v_password = hashed_password THEN
            RETURN v_cargo;
        ELSE
            RAISE e_password_incorrect;
        END IF;
    
    EXCEPTION
        WHEN e_password_incorrect THEN
            RETURN 'Senha Incorreta!';
        WHEN NO_DATA_FOUND THEN
            RETURN 'Usuario nao existe!';
            
    END login;

END USUARIO;