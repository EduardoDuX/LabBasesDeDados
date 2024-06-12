import streamlit as st
import re

CPI_PATTERN = re.compile(r'\d{3}\.\d{3}\.\d{3}-\d{2}')

def login():
    if 'user_type' not in st.session_state.keys():
        st.session_state['user_type'] = None

    st.set_page_config(
    page_title="Login",
    layout="centered",
    initial_sidebar_state="collapsed",
    )

    st.markdown("<h1 style='text-align: center; color: white;'>Seja bem-vindo!</h1>", unsafe_allow_html=True)
    st.markdown("<h5 style='text-align: center; color: white;'>Faça o login para continuar</h5>", unsafe_allow_html=True)
    
    with st.container(border=True):

        username = st.text_input("Digite seu CPI no formato XXX.XXX.XXX-XX", key='username')
        password = st.text_input("Senha", key='passoword', type='password')

        if username and password:
            if not CPI_PATTERN.search(username):
                st.text('CPI inválido. Tente novamente')
            else:
                if username == "123.456.789-00":
                    st.session_state['user_type'] = 'LIDER'
                else:
                    st.session_state['user_type'] = 'OFICIAL'
                
                _, col2, _ = st.columns([10, 3.8, 10])

                with col2:
                    if st.button("Continuar"):
                        st.switch_page('pages/main_page.py')

if __name__ == '__main__':
    login()