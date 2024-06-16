-- FEDERACAO
insert into federacao values ('FEDERACAO 1', SYSDATE);
insert into federacao values ('FEDERACAO 2', SYSDATE);
insert into federacao values ('FEDERACAO 3', SYSDATE);
insert into federacao values ('FEDERACAO 4', SYSDATE);
insert into federacao values ('FEDERACAO 5', SYSDATE);
insert into federacao values ('FEDERACAO 6', SYSDATE);

-- NACAO
insert into nacao values ('Humanidade', 0, NULL);
insert into nacao values ('NACAO 1', 0, 'FEDERACAO 1');
insert into nacao values ('NACAO 2', 0, 'FEDERACAO 2');
insert into nacao values ('NACAO 3', 0, 'FEDERACAO 3');
insert into nacao values ('NACAO 5', 0, 'FEDERACAO 4');
insert into nacao values ('NACAO 6', 0, 'FEDERACAO 5');
insert into nacao values ('NACAO 42', 0, 'FEDERACAO 42');

-- PLANETA
insert into planeta values ('Terra', 5.9722, 6.371, 'Rochoso');
insert into planeta values ('Marte', 3.9322, 2.371, 'Rochoso');
insert into planeta values ('Venus', 5.9722, 1.371, 'Rochoso');
insert into planeta values ('Mercurio', 1.9722, 2.371, 'Rochoso');
insert into planeta values ('Jupiter', 5.9722, 3.371, 'Rochoso');
insert into planeta values ('Saturno', 2.9722, 4.371, 'Rochoso');
insert into planeta values ('Urano', 19.9722, 5.371, 'Rochoso');
insert into planeta values ('Netuno', 5.9722, 6.371, 'Rochoso');

-- ESTRELA
insert into estrela values ('Sol','Sol', 'Amarela', 59722, 0,0,0);
insert into estrela values ('Sol 1',NULL, 'Amarela', 4567, 1,0,0);
insert into estrela values ('Sol 2','Sola', 'Verde', 3245, 2,0,0);
insert into estrela values ('Sol 3','Solu', 'Amarela', 2435, 3,0,0);
insert into estrela values ('Sol 4','Solo', 'Verde', 86758, 4,0,0);
insert into estrela values ('Sol 5','Soli', 'Azul', 2345, 5,0,0);
insert into estrela values ('Sol 6','Solar', 'Vermelha', 67547, 6,0,0);

-- DOMINANCIA
insert into dominancia values ('Terra', 'Humanidade', SYSDATE, NULL);
insert into dominancia values ('Mercurio', 'Humanidade', SYSDATE, NULL);
insert into dominancia values ('Venus', 'Humanidade', SYSDATE, NULL);
insert into dominancia values ('Marte', 'Humanidade', SYSDATE, NULL);
insert into dominancia values ('Saturno', 'Humanidade', SYSDATE, NULL);
insert into dominancia values ('Jupiter', 'Humanidade', SYSDATE, NULL);
insert into dominancia values ('Urano', 'Humanidade', SYSDATE, NULL);
insert into dominancia values ('Netuno', 'Humanidade', SYSDATE, NULL);

-- FACCAO
insert into faccao values ('FACCAO 1', '123.456.789-10',	'TOTALITARIA',	1);
insert into faccao values ('FACCAO 2',	'223.456.789-10',	'TRADICIONALISTA',	1);
insert into faccao values ('FACCAO 3',	'323.456.789-10',	'TOTALITARIA',	1);
insert into faccao values ('FACCAO 4',	'423.456.789-10',	'TRADICIONALISTA',	1);
insert into faccao values ('FACCAO 5',	'523.456.789-10',	'TOTALITARIA',	1);
insert into faccao values ('FACCAO 6',	'623.456.789-10',	'TRADICIONALISTA',	1);
insert into faccao values ('FACCAO 7',	'723.456.789-10',	'TRADICIONALISTA',	1);

-- PARTICIPA
insert into nacao_faccao values ('Humanidade', 'FACCAO 1');
insert into nacao_faccao values ('Humanidade', 'FACCAO 2');
insert into nacao_faccao values ('Humanidade', 'FACCAO 3');
insert into nacao_faccao values ('Humanidade', 'FACCAO 4');
insert into nacao_faccao values ('Humanidade', 'FACCAO 5');
insert into nacao_faccao values ('Humanidade', 'FACCAO 6');

-- ESPECIE
insert into especie values ('Humano', 'Terra', 'V');
insert into especie values ('Rato', 'Terra', 'F');
insert into especie values ('Avestruz', 'Terra', 'F');
insert into especie values ('Rinoceronte', 'Terra', 'F');
insert into especie values ('Elefante', 'Terra', 'F');
insert into especie values ('Efalante', 'Marte', 'V');

-- COMUNIDADE
insert into comunidade values ('Humano','Brasil',1);
insert into comunidade values ('Humano','EUA',1);
insert into comunidade values ('Humano','Japao',1);
insert into comunidade values ('Humano','Russia',1);
insert into comunidade values ('Humano','Cuba',1);
insert into comunidade values ('Humano','Argelia',1);
insert into comunidade values ('Humano','Australia',1);

-- HABITACAO
insert into habitacao values ('Terra','Humano','Brasil',SYSDATE,NULL);
insert into habitacao values ('Terra','Humano','EUA',SYSDATE,NULL);
insert into habitacao values ('Terra','Humano','Japao',SYSDATE,NULL);
insert into habitacao values ('Terra','Humano','Russia',SYSDATE,NULL);
insert into habitacao values ('Terra','Humano','Cuba',SYSDATE,NULL);
insert into habitacao values ('Terra','Humano','Argelia',SYSDATE,NULL);

-- PARTICIPA
insert into participa values ('FACCAO 1', 'Humano','Brasil');
insert into participa values ('FACCAO 1', 'Humano','EUA');
insert into participa values ('FACCAO 1', 'Humano','Australia');
insert into participa values ('FACCAO 1', 'Humano','Russia');
insert into participa values ('FACCAO 1', 'Humano','Cuba');
insert into participa values ('FACCAO 1', 'Humano','Argelia');

-- ORBITA_PLANETA
insert into orbita_planeta values ('Terra','Sol', 1,2,3);
insert into orbita_planeta values ('Marte','Sol', 1,2,3);
insert into orbita_planeta values ('Jupiter','Sol', 1,2,3);
insert into orbita_planeta values ('Saturno','Sol', 1,2,3);
insert into orbita_planeta values ('Netuno','Sol', 1,2,3);
insert into orbita_planeta values ('Mercurio','Sol', 1,2,3);
insert into orbita_planeta values ('Venus','Sol', 1,2,3);

-- ORBITA_ESTRELA
insert into orbita_estrela values ('Sol 1','Sol', 1,2,3);
insert into orbita_estrela values ('Sol 2','Sol', 1,2,3);
insert into orbita_estrela values ('Sol 3','Sol', 1,2,3);
insert into orbita_estrela values ('Sol 4','Sol', 1,2,3);
insert into orbita_estrela values ('Sol 5','Sol', 1,2,3);
insert into orbita_estrela values ('Sol 6','Sol', 1,2,3);

-- SISTEMA
insert into sistema values ('Sol', 'Sistema Solar');

commit;