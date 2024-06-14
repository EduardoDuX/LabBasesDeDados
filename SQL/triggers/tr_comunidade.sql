CREATE OR REPLACE TRIGGER TR_COMUNIDADE_CHECAGEM_INTELIGENTE
BEFORE INSERT OR UPDATE ON Comunidade
FOR EACH ROW
DECLARE
    v_inteligente ESPECIE.Inteligente%type
BEGIN

    -- Sempre haverá um resultado, já que se trata de chave estrangeira
    SELECT inteligente INTO v_inteligente
        FROM Especie
        WHERE Nome = :new.especie;

    IF v_inteligente = 'F' THEN
        RAISE_APPLICATION_ERROR(-20700,'Espécies não inteligentes não podem compor uma comunidade.');

END NRO_NACOES;
