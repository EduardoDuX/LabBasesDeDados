import streamlit as st


def main_page():
    '''
    Funcao da pagina principal da aplicacao, exibe os menus de navegacao

    '''

    if 'user_type' not in st.session_state.keys():
        st.session_state['user_type'] = None

    # Confiracoes da pagina
    st.set_page_config(
        page_title="Página principal",
        layout="centered",
        initial_sidebar_state="collapsed",
    )
    st.title('Essa é a página principal!')

    # Menu principal para os lideres
    with st.container(border=True):
        match st.session_state.user_type:

            # Menu do comandante
            case 'COMANDANTE':
                st.header('Seja bem-vindo comandante! Aqui você pode administrar suas comunidades.')
                st.session_state['report_type'] = 'comunidades'

            # Menu do oficial
            case 'OFICIAL':
                st.header('Seja bem-vindo oficial! Aqui você pode administrar suas habitações.')
                st.session_state['report_type'] = 'habitações'

            # Menu do cientista
            case 'CIENTISTA':
                st.header('Seja bem-vindo cientista! Aqui você pode administrar os registros de estrelas.')
                st.session_state['report_type'] = 'estrelas'

        _, col2, _, col4, _ = st.columns([8, 10, 5, 10, 8])


        # Botao de gerar relatorio
        with col2:
            if st.button('Gerar relatórios'):
                st.switch_page('pages/reports_page.py')

        # Botao de gerenciamento
        with col4:
            if st.session_state.user_type == 'OFICIAL':
                disabled=True
            else:
                disabled=False
                
            if st.button('Gerenciar facção', disabled=disabled):
                st.switch_page('pages/management_page.py')

    _, col2, _ = st.columns([20, 5, 20])

    # Botao de sair do aplicativo
    with col2:
        if st.button('Sair', type='primary'):
            st.switch_page('login_page.py')

if __name__ == '__main__':

    # Acessa a pagina principal
    main_page()