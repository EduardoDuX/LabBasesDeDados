### Geral

### Gustavo
* Trigger em **Comunidade** para checar se espécie é inteligente ou não.
    * Justificativa: "_Conjuntos substanciais de membros da mesma espécie inteligente podem formar Comunidades_"
* Tentativa de cumprir _Uma federação só pode existir se estiver associada a pelo menos 1 nação._:
    * Criar um trigger de update e delete em **Nacao** que, quando envolver alteração de _federacao_, executar um procedure para manter a base consistente.
* Critério: "_As comunidades dos planetas também podem se filiar a uma facção, **sendo esta capaz de atender várias comunidades em nações que a abrigam**._"
    * As comunidades apenas podem participar de Faccoes que dominam o planeta?
* Como resolver este problema de consistência:
    *  _Cada facção deve ter um único líder para comandá-la, este sendo associado a uma nação onde a facção está presente, e um líder pode participar de apenas de uma facção._
