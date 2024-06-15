CREATE OR REPLACE PACKAGE gerenciamento_comandante AS
    FUNCTION inicia_nacao (
        p_cpi lider.cpi%type
    )RETURN VARCHAR2;
    
    PROCEDURE cria_federacao (
        p_nome_federacao federacao.nome%type,
        p_data_fund federacao.data_fund%type DEFAULT SYSDATE()
    );
    PROCEDURE incluir_nacao_federacao (
        p_nacao     NACAO.NOME%type,
        p_federacao FEDERACAO.NOME%type
    );
    PROCEDURE excluir_nacao_federacao (
        p_nacao     NACAO.NOME%type
    );
    PROCEDURE registrar_dominancia (
        p_nacao     NACAO.NOME%type,
        p_planeta   DOMINANCIA.PLANETA%type
    );
END gerenciamento_comandante;
    
/

CREATE OR REPLACE PACKAGE BODY gerenciamento_comandante AS
    v_nacao nacao.nome%type; -- Variável privada com a nacao do lider, preenchida com o procedure 'inicia_nacao'
    
    -- Procedimento deve ser executado imediatamente após o login
    -- Descobre, dado o lider, qual sua nacao
    FUNCTION inicia_nacao (
        p_cpi lider.cpi%type
    )
    RETURN VARCHAR2
    IS
    BEGIN
        SELECT nacao INTO v_nacao FROM lider where lider.cpi= p_cpi;
        return v_nacao;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002,'Lider invalido');
            -- Lider sem nacao não existe, portanto um erro aqui seria um problema de aplicação
    END inicia_nacao;
    
    -- PROCEDURE PARA CRIAR FEDERACAO
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
    
    -- PROCEDURE PARA INCLUIR NACAO EM UMA FEDERACAO
    PROCEDURE incluir_nacao_federacao (
        p_nacao     NACAO.NOME%type,
        p_federacao FEDERACAO.NOME%type
    ) AS
        e_federacao_inexistente EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_federacao_inexistente, -02291);
    BEGIN
        
        UPDATE Nacao
            SET Federacao = p_federacao
            WHERE Nome = p_nacao AND Federacao IS NULL;
        IF SQL%NOTFOUND THEN
            RAISE_APPLICATION_ERROR(-20500,'NACAO JA POSSUI FEDERACAO!');
        END IF;
        commit;
        EXCEPTION
            WHEN e_federacao_inexistente THEN
                gerenciamento_comandante.cria_federacao(p_federacao);
                UPDATE Nacao
                    SET Federacao = p_federacao
                    WHERE Nome = p_nacao;
                    commit;
                
    END incluir_nacao_federacao;
    
    -- PROCEDURE PARA EXCLUIR NACAO DE UMA FEDERACAO
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
        
        SELECT Federacao INTO v_federacao
            FROM Nacao
            WHERE Nome = p_nacao;
        
        SELECT COUNT(*) INTO v_count
            FROM Nacao
            WHERE Federacao = v_federacao;
            
        IF v_count = 1 THEN
            DELETE FROM Federacao WHERE Nome = v_federacao;
        END IF;
        
        UPDATE Nacao
            SET Federacao = NULL
            WHERE Nome = p_nacao;
        IF SQL%NOTFOUND THEN
            RAISE_APPLICATION_ERROR(-20500,'Nacao invalida!');
        END IF;
        
        commit;
                    
    END excluir_nacao_federacao;
    
    -- PROCEDURE PARA REGISTRAR NOVA DOMINANCIA
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
        
        SELECT COUNT(*) INTO v_count
            FROM Dominancia
            WHERE planeta = p_planeta
              AND (data_fim IS NULL OR data_fim < SYSDATE());
            
        IF v_count = 0 THEN
            INSERT INTO Dominancia VALUES (p_planeta, p_nacao, SYSDATE(), NULL);
        ELSE 
            RAISE_APPLICATION_ERROR(-20600,'Planeta ja esta sob dominacao uma nacao.'); 
        END IF;
        
        commit;        
                    
    END registrar_dominancia;
    
END gerenciamento_comandante;
