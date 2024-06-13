import streamlit as st
import re
import oracledb
import json

# Padrao do CPI do lider
CPI_PATTERN = re.compile(r'\d{3}\.\d{3}\.\d{3}-\d{2}')

def login(connection):
    '''
    Funcao inical da aplicacao, abre a pagina de login no navegador
    Args:
        connection -> conexao com o banco ja inicializada

    '''


    if 'user_type' not in st.session_state.keys():
        st.session_state['user_type'] = None

    # Configuracoes da pagina
    st.set_page_config(
        page_title="Login",
        layout="centered",
        initial_sidebar_state="collapsed",
    )

    # Texto apresentado ao usuario
    st.markdown("<h1 style='text-align: center; color: white;'>Seja bem-vindo!</h1>", unsafe_allow_html=True)
    st.markdown("<h5 style='text-align: center; color: white;'>Faça o login para continuar</h5>", unsafe_allow_html=True)
    

    # Div do login
    with st.container(border=True):

        # Inputs de cpi e senha
        username = st.text_input("Digite seu CPI no formato XXX.XXX.XXX-XX", key='username')
        password = st.text_input("Senha", key='passoword', type='password')

        # Procedimento de login
        if username and password:

            # Verifica o tipo do cpi entrado
            if not CPI_PATTERN.search(username):
                st.text('CPI inválido. Tente novamente')
            else:

                # Chama a funcao `login` da base de dados
                with connection.cursor() as cursor:
                    login_result = cursor.callfunc('login', str, [username, password])

                # Verifica se o login foi bem sucedido
                if login_result == 'Senha Incorreta!' or login_result == 'Usuario nao existe!':
                    st.text(login_result)

                # Armazena o tipo de lider retornado
                elif login_result == 'COMANDANTE' or  login_result == 'OFICIAL' or login_result == 'CIENTISTA':
                    st.session_state['user_type'] = login_result

                # Avança para proxima pagina
                _, col2, _ = st.columns([10, 3.8, 10])
                with col2:
                    if st.button("Continuar"):
                        st.switch_page('pages/main_page.py')


if __name__ == '__main__':

    # Busca as credenciais da base de dados
    with open('credenciais.json', 'r') as f:
        cred = json.load(f)
        cs = cred['cs']
        un = cred['un']
        pw = cred['passwd']

    # Cria conexao com o banco
    connection = oracledb.connect(user=un, password=pw, dsn=cs)
    
    # Acessa a pagina de login
    login(connection)