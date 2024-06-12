import streamlit as st

def main_page():
    if 'user_type' not in st.session_state.keys():
        st.session_state['user_type'] = None

    st.set_page_config(
        page_title="Página principal",
        layout="centered",
        initial_sidebar_state="collapsed",
    )

    st.title('Essa é a página principal!')

    with st.container(border=True):
        match st.session_state.user_type:
            case 'LIDER':
                st.header(f'Seja bem-vindo líder. Aqui você pode administrar suas comunidades.')
                st.session_state['report_type'] = 'comunidades'
            case 'OFICIAL':
                st.header(f'Seja bem-vindo oficial. Aqui você pode administrar suas habitações.')
                st.session_state['report_type'] = 'habitações'

        _, col2, _, col4, _ = st.columns([8, 10, 5, 10, 8])

        with col2:
            if st.button('Gerar relatórios'):
                st.switch_page('pages/reports_page.py')

        with col4:
            if st.session_state.user_type == 'OFICIAL':
                disabled=True
            else:
                disabled=False
                
            if st.button('Gerenciar facção', disabled=disabled):
                st.switch_page('pages/management_page.py')

    _, col2, _ = st.columns([20, 5, 20])
    with col2:
        if st.button('Sair', type='primary'):
            st.switch_page('login_page.py')

if __name__ == '__main__':
    main_page()