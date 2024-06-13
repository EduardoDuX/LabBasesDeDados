-- TRIGGER PARA MANTER A QUANTIDADE DE PLANETAS ATUALIZADA NA TABELA NACAO
CREATE OR REPLACE TRIGGER NRO_PLANETAS
AFTER INSERT OR DELETE OR UPDATE ON Dominancia
FOR EACH ROW
DECLARE
    v_update NUMBER := 0;
    v_nacao NACAO.Nome%type;
BEGIN
    
    /*  As insercoes e remocoes devem afetar a quantidade de planetas apenas se
        estiverem relacionadas com dominacoes atuais. */
    IF INSERTING AND (:new.data_fim IS NULL OR :new.data_fim > SYSDATE) THEN
        v_update := 1;
        v_nacao := :new.nacao;
    ELSIF DELETING AND (:old.data_fim IS NULL OR :old.data_fim > SYSDATE) THEN 
        v_update := -1;
        v_nacao := :old.nacao;
    END IF;
    
    /*  Se estiver atualizando a data de uma dominacao, pode ser necesssario 
        atualizar a tabela nacao */
    IF UPDATING AND (:old.data_fim != :new.data_fim OR
                      (:old.data_fim IS NULL AND :new.data_fim IS NOT NULL) OR
                      (:old.data_fim IS NOT NULL AND :new.data_fim IS NULL)     
                     ) THEN
        v_nacao := :old.nacao;
        IF (:old.data_fim > SYSDATE OR :old.data_fim IS NULL) AND :new.data_fim < SYSDATE THEN
            v_update := -1;
        ELSIF :old.data_fim < SYSDATE AND (:new.data_fim > SYSDATE OR :new.data_fim IS NULL) THEN
            v_update := 1;
        END IF;
    END IF;

    UPDATE Nacao
        SET qtd_planetas = qtd_planetas + v_update
        WHERE nome = v_nacao;
        
END NRO_PLANETAS;