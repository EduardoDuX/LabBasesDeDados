CREATE OR REPLACE TRIGGER t_lider_faccoes
INSTEAD OF UPDATE
ON v_lider_faccao
FOR EACH ROW
BEGIN
    IF :new.credenciada = 1 THEN
        INSERT INTO PARTICIPA VALUES (:old.faccao, :old.especie, :old.comunidade);
    ELSIF :new.credenciada = 0 THEN
        DELETE FROM PARTICIPA 
            WHERE Faccao = :old.faccao
                AND Especie = :old.especie
                AND Comunidade = :old.comunidade;
    END IF;
END;        
