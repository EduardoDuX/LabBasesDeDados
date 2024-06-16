import streamlit as st
from oracledb import DatabaseError
import time
import re

# Padrao do CPI do lider
CPI_PATTERN = re.compile(r'\d{3}\.\d{3}\.\d{3}-\d{2}')

# Função que organiza as opções de gerenciamento de líder
def lider():
    st.title('Gerencie sua facção')

    # Alterar o nome da facção
    with st.container(border=True):
        st.subheader('Alterar nome da facção')
        st.text_input(
            label='Nome da facção',
            placeholder='Insira o novo nome da facção',
            key='new_fac_name'
        )        
        if st.button('Alterar'):
            if len(st.session_state.new_fac_name) > 15:
                st.text(f'Nome da Facção deve ter até 15 dígitos.')
            else:
                with st.session_state.connection.cursor() as cursor:
                    cursor.callproc('usuario.log_message', [st.session_state.cpi, f'ALTERA LIDER DA FACCAO {st.session_state.faccao} PARA {st.session_state.new_fac_name}'])
                    cursor.callproc(
                        'lider_faccao.alterar_nome_faccao',
                        [st.session_state.cpi, st.session_state.faccao, st.session_state.new_fac_name]
                    )
                    st.session_state.faccao = st.session_state.new_fac_name

            st.text('Nome da facção alterado com sucesso!')

    # Indicar um novo líder
    with st.container(border=True):
        st.subheader('Indicar um novo líder')
        st.markdown("<h5 color: white;'>Cuidado! Você será desconectado ao indicar um novo líder</h5>", unsafe_allow_html=True)
        
        st.text_input(label='CPI do novo líder', placeholder='Digite o CPI no formato XXX.XXX.XXX-XX', key='new_ldr_fac')
        if st.button('Indicar'):
            try:
                if not CPI_PATTERN.search(st.session_state.cpi):
                    st.text('CPI inválido. Tente novamente')
                else:
                    with st.session_state.connection.cursor() as cursor:
                        cursor.callproc('usuario.log_message', [st.session_state.cpi, f'INDICA {st.session_state.new_ldr_fac} COMO NOVO LIDER DA FACCAO {st.session_state.faccao}'])
                        cursor.callproc('lider_faccao.indicar_novo_lider', [st.session_state.new_ldr_fac, st.session_state.faccao])

                # Ao dar o privilégio de líder da facção para o novo líder, o líder anterior é desconectado
                st.text('Novo líder indicado com sucesso! Você será desconectado em breve...')
                time.sleep(8)
                st.switch_page('login_page.py')
            except DatabaseError as e:
                if 'Este usuario ja lidera outra faccao' in str(e):
                    st.text('Este usuário já lidera outra facção.')

    
    # Remover facção da Nação
    with st.container(border=True):
        st.subheader('Remover facção da Nação')
        st.text_input(label='Nome da nação', placeholder='Insira o nome da nação', key='rmv_nac')
        if st.button('Remover'):

            if len(st.session_state.rmv_nac) > 15:
                st.text(f'Nome da Nação deve ter até 15 dígitos.')
            else:
                try:
                    with st.session_state.connection.cursor() as cursor:
                        cursor.callproc('usuario.log_message', [st.session_state.cpi, f'REMOVE FACCAO {st.session_state.faccao} DA NACAO {st.session_state.rmv_nac}'])
                        cursor.callproc("lider_faccao.remove_nacao_faccao", [st.session_state.cpi, st.session_state.rmv_nac, st.session_state.faccao])
                except DatabaseError as e:
                    if 'Nao pode excluir a propria nacao de sua faccao' in str(e):
                        st.text('Você não pode remover a sua facção da sua nação!')
                


# Função geral que organiza a página
def management_leader():
    st.set_page_config(
    page_title="Gerenciamento",
    layout="wide",
    initial_sidebar_state="collapsed",
    )

    if st.button('Voltar', type='primary', key='v7'):
        st.switch_page('pages/main_page.py')

    lider()
            
    if st.button('Voltar', type='primary', key='v8'):
        st.switch_page('pages/main_page.py')

if __name__ == '__main__':
    management_leader()
