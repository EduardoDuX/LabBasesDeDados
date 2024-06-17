-- View utilizada para ser acessada pelo líder de uma facção
-- para que ele possa gerenciar melhor as comunidades que são
-- credenciadas à sua facção.
CREATE OR REPLACE VIEW v_lider_faccao AS
    SELECT F.Lider, F.Nome AS FACCAO, NF.Nacao, D.Planeta, H.Especie, H.Comunidade, 
            (CASE WHEN (P.Comunidade = H.Comunidade AND P.Especie = H.Especie) THEN 1
              ELSE 0
             END) AS CREDENCIADA
        FROM Faccao F
        LEFT JOIN Nacao_Faccao NF
        ON F.nome = NF.faccao
        LEFT JOIN Dominancia D
        ON NF.nacao = D.nacao AND (D.data_fim IS NULL OR D.data_fim > SYSDATE)
        LEFT JOIN Habitacao H
        ON D.planeta = H.planeta AND (H.data_fim IS NULL OR H.data_fim > SYSDATE)
        LEFT JOIN Participa P
        ON H.comunidade = P.comunidade AND H.especie = P.especie;
