-- TRIGGER PARA MANTER A QUANTIDADE DE NACOES ATUALIZADA NA TABELA FACCAO
--NRO_NACOES
CREATE OR REPLACE TRIGGER NRO_NACOES
AFTER INSERT OR DELETE OR UPDATE ON Nacao_Faccao
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE Faccao
            SET qtd_nacoes = COALESCE(qtd_nacoes, 0) + 1
            WHERE nome = :new.faccao;
    ELSIF DELETING THEN
        UPDATE Faccao
            SET qtd_nacoes = COALESCE(qtd_nacoes, 0) - 1
            WHERE nome = :old.faccao;   
    ELSE
    	IF :old.faccao != :new.faccao THEN
            UPDATE Faccao
                SET qtd_nacoes = COALESCE(qtd_nacoes, 0) - 1
                WHERE nome = :old.faccao;
            UPDATE Faccao
                    SET qtd_nacoes = COALESCE(qtd_nacoes, 0) + 1
                WHERE nome = :new.faccao;
        END IF;
    END IF;
END NRO_NACOES;