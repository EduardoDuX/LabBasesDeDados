# UNIVERSIDADE DE SÃO PAULO
## INSTITUTO DE CIÊNCIAS MATEMÁTICAS E CIÊNCIAS COMPUTACIONAIS


### [SCC0241 - Laboratório de Bases de Dados](https://uspdigital.usp.br/jupiterweb/obterDisciplina?nomdis=&sgldis=SCC0241) - 2024/1

### Integrantes do grupo:
- Alexandre Eduardo de Souza - 12559506
- Eduardo Zaffari Monteiro - 12559490
- Guilherme Sousa Panza - 12543519
- Gustavo Siqueira Barbosa - 10728122
  
### Listagem de Softwares utilizados no projeto:
- [Python – 3.12.3](https://www.python.org/)
- [StreamLit – 1.35.0](https://streamlit.io/)
- [OracleDB – 2.2.1](https://pypi.org/project/oracledb/)
- [SQL Developer 23.1.10](https://www.oracle.com/database/sqldeveloper/technologies/download/)

### Estrutura de Arquivos:

### SQL
Pasta contendo os arquivos SQL utilizados para criar tabelas, triggers, views e outras estruturas no banco de dados. Esse diretório está organizado com subpastas para cada tipo de estrutura utilizada:
#### pacotes:


##### procedures_funcoes:
- insere_users.sql: Código para definição do procedure que cadastra os líderes na tabela `USERS`.
- log_message.sql: Código para definição do procedure para manter log de atividades na aplicação.
- login.sql: Código para definição da função que realiza login do usuário na aplicação.


##### tabelas:
- tabela_users.sql: Código para definição da tabela `USERS`
- tabela_log_table.sql: Código para definição da tabela `LOG_USERS`


##### triggers:
- lider_faccao_nacao.sql: Código para definição de um trigger que associa uma federação à nação do lider quando criada.
- nro_nacoes.sql: Código para definição de um trigger que mantém o campo qtd_nacoes da tabela faccao atualizado.
- nro_planetas.sql: Código para definição de um trigger que mantém o campo qtd_planetas da tabela nação atualizado.
- tr_comunidade.sql: Código para definição de um trigger para garantir que só é possível criar comunidades de nações inteligentes.
- tr_participa.sql: Código para definição de um trigger para garantir que a comunidade só possa se filiar à facções presentes na sua nação.


##### views:
- view_lider_faccao.sql: Código para definição da view `v_lider_faccao`


### application:
Pasta contendo os arquivos .py que definem as páginas da aplicação

##### login_page.py
Arquivo de login, esse arquivo contém o código python com a chamda da função `login` do banco, para acessar a aplicação, além de funções auxiliares para obter a nação e facção do líder. A aplicação deve ser executada utilizando o seguinte comando, a partir do diretório raiz do projeto:  
    
`python -m streamlit run application/login_page.py`

##### pages
- main_page.py: Arquivo .py que contém a página de navegação, faz a navegação para as páginas de relatório e gerenciamento.
- management_page.py: Arquivo para realizar os gerenciamentos, possui uma função definida para cada tipo de líder, que é executada conforme o usuário que está utilizando o banco.
- reports_page.py: Arquivo para acessar os relatórios, possui uma função definida para cada tipo de líder, que é executada conforme o usuário que está utilizando o banco.
