-- Indíce para otimização da busca de estrelas por nome
CREATE INDEX IDX_ESTRELA_NOME ON ESTRELA(NOME);

-- Indíce para otimização de buscas em nação com critério por qtd_planetas
CREATE INDEX IDX_QTD_PLANETAS_NACAO ON NACAO(QTD_PLANETAS);