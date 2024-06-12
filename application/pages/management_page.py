import streamlit as st

def lider():
    st.title('Gerencie sua facção')

    with st.container():
        st.subheader('Alterar nome da facção')
        st.text_input(label='Nome facção', placeholder='Insira o novo nome da facção', label_visibility='collapsed')
        st.button('Concluído', key='c1')
        
    with st.container():
        st.subheader('Indicar um novo líder')
        st.text_input(label='Nome líder', placeholder='Digite o CPI do novo líder no formato XXX.XXX.XXX-XX', label_visibility='collapsed')
        st.button('Concluído', key='c2')
        
    with st.container():
        st.subheader('Credenciar nova comunidade')
        sub_col1, sub_col2 = st.columns(2)
        with sub_col1:
            st.text_input(label='Nome comunidade', placeholder='Insira o nome da comunidade', label_visibility='collapsed')
        with sub_col2:
            st.text_input(label='Espécie comunidade', placeholder='Insira a espécide da comunidade', label_visibility='collapsed')
        st.button('Concluído', key='c3')
        
    with st.container():
        st.subheader('Remover facção da Nação')
        st.text_input(label='Nome nação', placeholder='Insira o nome da nação', label_visibility='collapsed')
        st.button('Concluído', key='c4')


def management_page():
    st.set_page_config(
    page_title="Gerenciamento",
    layout="wide",
    initial_sidebar_state="collapsed",
    )

    if st.button('Voltar', type='primary', key='v1'):
        st.switch_page('pages/main_page.py')

    match st.session_state.user_type:
        case 'LIDER':
            lider()
        case 'OFICIAL':
            pass
        case 'COMANDANTE':
            pass
        case 'CIENTISTA':
            pass
            
    if st.button('Voltar', type='primary', key='v2'):
        st.switch_page('pages/main_page.py')

if __name__ == '__main__':
    management_page()