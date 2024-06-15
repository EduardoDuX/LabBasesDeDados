CREATE OR REPLACE TRIGGER TR_CREDENCIAR_COMUNIDADE
BEFORE INSERT OR UPDATE ON Participa
FOR EACH ROW
DECLARE
    v_aux_count INT
BEGIN

    -- Sempre haverá um resultado, já que se trata de um count
    SELECT COUNT(*) INTO v_aux_count
        FROM Comunidade C
        JOIN Habitacao H
        ON (C.Especie = H.Especie AND C.Nome = H.Comunidade)
        JOIN Dominancia D
        ON (D.Planeta = H.Planeta)
        JOIN Nacao_Faccao NF
        ON NF.Nacao = D.Nacao
        WHERE NF.Faccao = :new.faccao
          AND C.Especie = :new.especie
          AND C.Nome = :new.comunidade;

    IF v_aux_count == 0 THEN
        RAISE_APPLICATION_ERROR('Nao e possivel se credenciar a uma faccao que nao seja filiada a nacao de seu planeta.');

END NRO_NACOES;
