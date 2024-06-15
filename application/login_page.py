import streamlit as st
import re
import oracledb
import json

# Padrao do CPI do lider
CPI_PATTERN = re.compile(r'\d{3}\.\d{3}\.\d{3}-\d{2}')

def login():
    '''
    Funcao inical da aplicacao, abre a pagina de login no navegador

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
        cpi = st.text_input("Digite seu CPI no formato XXX.XXX.XXX-XX", key='cpi_login')
        password = st.text_input("Senha", key='password', type='password')

        # Procedimento de login
        if cpi and password:

            # Verifica o tipo do cpi entrado
            if not CPI_PATTERN.search(cpi):
                st.text('CPI inválido. Tente novamente')
            else:
                # Chama a funcao `login` da base de dados
                with st.session_state.connection.cursor() as cursor:
                    login_result = cursor.callfunc('login', str, [cpi, password])

                # Verifica se o login foi bem sucedido
                if login_result == 'Senha Incorreta!' or login_result == 'Usuario nao existe!':
                    st.text(login_result)

                # Armazena o tipo de lider retornado
                elif 'COMANDANTE' in login_result or 'OFICIAL' in login_result or 'CIENTISTA' in login_result:
                    
                    
                    
                    with st.session_state.connection.cursor() as cursor:
                        cursor.callproc('log_message', [cpi, 'LOGIN'])

                    login_result = login_result.replace(" ", "")

                    # Coletando o tipo do usuário
                    st.session_state.user_type = login_result

                    # Registra cpi do lider
                    st.session_state['cpi'] = cpi

                    # Coletando a faccao do usuário
                    with st.session_state.connection.cursor() as cursor:
                        faccao = cursor.callfunc('gerenciamento_lider.inicia_faccao', str,[st.session_state.cpi])
                        st.session_state['faccao'] = faccao

                    if 'COMANDANTE' in login_result:
                        with st.session_state.connection.cursor() as cursor:
                            nacao = cursor.callfunc('gerenciamento_comandante.inicia_nacao', str,[st.session_state.cpi])
                            st.session_state['nacao'] = nacao

                    # Avança para proxima pagina
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
    st.session_state['connection'] = connection
    
    # Acessa a pagina de login
    login()