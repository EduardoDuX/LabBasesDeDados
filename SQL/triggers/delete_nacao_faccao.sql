-- TRIGGER PARA IMPEDIR A DELECAO DA ULTIMA NACAO DE UMA FEDERACAO
CREATE OR REPLACE TRIGGER delete_nacao_federacao
FOR DELETE OR UPDATE ON NACAO
COMPOUND TRIGGER

    TYPE federacoes_nomes_t IS TABLE OF federacao.nome%TYPE;
    federacoes_nomes federacoes_nomes_t;
    TYPE federacoes_numero_t IS TABLE OF NUMBER;
    federacoes_numero federacoes_numero_t;

    TYPE t_nacoes_federacao IS TABLE OF NUMBER INDEX BY federacao.nome%type;
    n_nacoes_federacao t_nacoes_federacao;

BEFORE STATEMENT IS
BEGIN
    SELECT
        FEDERACAO,
        COUNT(*)
    BULK COLLECT INTO
        federacoes_nomes,
        federacoes_numero
    FROM NACAO GROUP BY FEDERACAO;
    
    FOR j IN 1..federacoes_nomes.COUNT() LOOP
      n_nacoes_federacao(federacoes_nomes(j)) := federacoes_numero(j);
    END LOOP;
    
END BEFORE STATEMENT;

AFTER EACH ROW IS 
BEGIN 
    IF n_nacoes_federacao(:old.federacao) = 1 THEN
        n_nacoes_federacao(:old.federacao) := n_nacoes_federacao(:old.federacao) - 1;
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
BEGIN
    FOR j IN 1..federacoes_nomes.COUNT() LOOP
        IF n_nacoes_federacao(federacoes_nomes(j)) = 0 THEN
            RAISE_APPLICATION_ERROR(-20000, 'DELETE INVÁLIDO POIS A FEDERACAO '||federacoes_nomes(j)||' FICARIA SEM NACOES');
        END IF;
    END LOOP;
END AFTER STATEMENT;
END delete_nacao_federacao;