import streamlit as st


def main_page():
    '''
    Funcao da pagina principal da aplicacao, exibe os menus de navegacao

    '''

    if 'user_type' not in st.session_state.keys():
        st.session_state['user_type'] = None
    
    if 'report_type' not in st.session_state.keys():
        st.session_state['report_type'] = None

    # Confiracoes da pagina
    st.set_page_config(
        page_title="Página principal",
        layout="wide",
        initial_sidebar_state="collapsed",
    )

    match st.session_state.user_type:
        # Menu do comandante
        case 'COMANDANTE':
            st.header('Seja bem-vindo comandante! Aqui você pode administrar sua nação.')
            st.session_state['report_type'] = ['nação']

        # Menu do oficial
        case 'OFICIAL':
            st.header('Seja bem-vindo oficial! Aqui você pode administrar suas habitações.')
            st.session_state['report_type'] = ['habitações']

        # Menu do cientista
        case 'CIENTISTA':
            st.header('Seja bem-vindo cientista! Aqui você pode administrar os registros de estrelas.')
            st.session_state['report_type'] = ['estrelas']

    # Caso o líder também seja líder de alguma facção
    if st.session_state.faccao:
        st.session_state['report_type'].append('facções')
    
    # Exibindo informações do usuário
    name = 'Placeholder'
    st.markdown(f"<h6 color: white;'>Usuário autenticado: ***{st.session_state.cpi[3:11]}-**</h6>", unsafe_allow_html=True)
    st.markdown(f"<h6 color: white;'>Nome: {name}</h6>", unsafe_allow_html=True)
        
    # Botões da página
    st.container(height=5, border=False)
    col1, col2, col3, col4 = st.columns(4)
    # Botao de gerar relatorio
    with col1:
        if st.button('Gerar relatórios'):
            st.switch_page('pages/reports_page.py')

    # Botao de gerenciamento
    with col2:
        if st.session_state.user_type == 'OFICIAL':
            disabled=True
        else:
            disabled=False
            
        if st.button(f'Gerenciar {st.session_state.report_type[0]}', disabled=disabled):
            st.switch_page('pages/management_page.py')

    # Botao de gerar relatorios específico para líderes de facção
    with col3:
        if len(st.session_state.report_type) == 2:
            disabled=True
        else:
            disabled=False

        if st.button(f'Gerar relatórios de facção', disabled=disabled):
            st.switch_page('pages/reports_leader.py')

    # Botao de gerenciamento específico para líderes de facção
    with col4:
        if len(st.session_state.report_type) == 2:
            disabled=True
        else:
            disabled=False

        if st.button(f'Gerenciar facção', disabled=disabled):
            st.switch_page('pages/management_leader.py')
    
    # Botao de sair do aplicativo
    st.container(height=50, border=False)
    if st.button('Sair', type='primary'):
            st.switch_page('login_page.py')

if __name__ == '__main__':

    # Acessa a pagina principal
    main_page()