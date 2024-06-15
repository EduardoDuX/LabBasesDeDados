import streamlit as st
import time
from datetime import date
from oracledb import DatabaseError

def lider():
    st.title('Gerencie sua facção')

    # Alterar o nome da facção
    with st.container(border=True):
        st.subheader('Alterar nome da facção')
        st.text_input(label='Nome da facção', placeholder='Insira o novo nome da facção', key='new_fac_name')        
        if st.button('Alterar'):
            with st.session_state.connection.cursor() as cursor:
                cursor.callproc('gerenciamento_lider.alterar_nome_faccao', [st.session_state.cpi, st.session_state.faccao, st.session_state.new_fac_name])
                st.session_state.faccao = st.session_state.new_fac_name

            st.text('Nome da facção alterado com sucesso!')

    # Indicar um novo líder
    with st.container(border=True):
        st.subheader('Indicar um novo líder')
        st.markdown("<h5 color: white;'>Cuidado! Você será desconectado ao indicar um novo líder</h5>", unsafe_allow_html=True)
        
        st.text_input(label='CPI do novo líder', placeholder='Digite o CPI no formato XXX.XXX.XXX-XX', key='new_ldr_fac')
        if st.button('Indicar'):
            with st.session_state.connection.cursor() as cursor:
                cursor.callproc("gerenciamento_lider.indicar_novo_lider", [st.session_state.new_ldr_fac])

            # Ao dar o privilégio de líder da facção para o novo líder, o líder anterior é desconectado
            st.text('Novo líder indicado com sucesso! Você será desconectado em breve...')
            time.sleep(5)
            st.switch_page('login_page.py')
    
    # Credenciar uma nova comunidade
    with st.container(border=True):
        st.subheader('Credenciar nova comunidade')
        sub_col1, sub_col2 = st.columns(2)
        with sub_col1:
            st.text_input(label='Nome da comunidade', placeholder='Insira o nome da comunidade')
        with sub_col2:
            st.text_input(label='Espécie da comunidade', placeholder='Insira a espécide da comunidade')
        st.button('Credenciar')
    
    # Remover facção da Nação
    with st.container(border=True):
        st.subheader('Remover facção da Nação')
        st.text_input(label='Nome da nação', placeholder='Insira o nome da nação', key='rmv_nac')
        if st.button('Remover'):
            with st.session_state.connection.cursor() as cursor:
                cursor.callproc("gerenciamento_lider.remove_nacao_faccao", [st.session_state.rmv_nac])

def cientista():
    # Gerencia CRUD de estrelas
    st.title('Gerencie estrelas')

    # Criar
    with st.container(border=True):
        st.subheader('Criar estrela')
        st.text_input(label='ID', placeholder='Insira o ID da nova estrela', key='id_new_star')
        st.text_input(label='Nome', placeholder='Insira o nome da nova estrela', key='name_new_star')
        st.text_input(label='Classificação', placeholder='Insira a classificação da nova estrela', key='class_new_star')
        st.text_input(label='Massa', placeholder='Insira a massa da nova estrela', key='mass_new_star')
        st.text('Insira as coordenadas da nova estrela')

        sub_col1, sub_col2, sub_col3 = st.columns(3)

        with sub_col1:
            st.text_input(label='X', placeholder='Insira a coordenada X', key='x_new_star')

        with sub_col2:
            st.text_input(label='Y', placeholder='Insira a coordenada Y', key='y_new_star')

        with sub_col3:
            st.text_input(label='Z', placeholder='Insira a coordenada Z', key='z_new_star')

        if st.button('Criar nova estrela'):
            with st.session_state.connection.cursor() as cursor:
                cursor.callproc('gerenciamento_cientista.cria_estrela', [st.session_state.id_new_star,
                                                                         st.session_state.name_new_star,
                                                                         st.session_state.class_new_star,
                                                                         st.session_state.mass_new_star,
                                                                         st.session_state.x_new_star,
                                                                         st.session_state.y_new_star,
                                                                         st.session_state.z_new_star])
                
            st.text('Estrela criada com sucesso!')

    # Ler (Read)
    with st.container(border=True):
        st.subheader('Visualize os dados de estrelas')
        selected_option_read = st.multiselect('Selecione o filtro para visualização', ['Sem filtros', 'ID da estrela', 'Nome', 'Classificação', 'Massa'], max_selections=1, placeholder='Selecione uma opção')
        
        if selected_option_read:
            opt_read = selected_option_read[0]
            match opt_read:
                case 'Sem filtros':
                    pass
                case 'ID':
                    st.text_input(label='Atributo', placeholder=f'Insira o ID da estrela', label_visibility='collapsed', key='id_read')
                case 'Massa':
                    st.text_input(label='Atributo', placeholder=f'Insira a massa', label_visibility='collapsed', key='mass_read')
                case 'Classificação':
                    st.text_input(label='Atributo', placeholder=f'Insira a classificação', label_visibility='collapsed', key='class_read')

            st.button('Buscar dados')

    # Atualizar
    with st.container(border=True):
        st.subheader('Altere as informações de uma estrela')
        st.text_input('Insira o ID da estrela', key='update_star')
        selected_option_update = st.multiselect('Selecione o atributo que deseja alterar', ['Nome', 'Classificação', 'Massa', 'Coordenadas'], max_selections=1, placeholder='Selecione uma opção')
        if selected_option_update:
            opt_update = selected_option_update[0]
            match opt_update:
                case 'Nome':
                    st.text_input(label='Atributo', placeholder='Insira o nome', label_visibility='collapsed')
                case 'Coordenadas':
                    sub_col1, sub_col2, sub_col3 = st.columns(3)

                    with sub_col1:
                        st.text_input(label='X', placeholder='Insira a coordenada X')

                    with sub_col2:
                        st.text_input(label='Y', placeholder='Insira a coordenada Y')

                    with sub_col3:
                        st.text_input(label='Z', placeholder='Insira a coordenada Z')
                case 'Massa':
                    st.text_input(label='Atributo', placeholder=f'Insira a massa', label_visibility='collapsed')
                case 'Classificação':
                    st.text_input(label='Atributo', placeholder=f'Insira a classificação', label_visibility='collapsed')

            st.button('Atualizar estrela')

    # Remover
    with st.container(border=True):
        st.subheader('Remova uma estrela')
        st.text_input('Insira o ID da estrela', key='delete_star')
        st.button('Remover estrela')


def comandante():
    st.title('Gerencie sua nação e suas dominâncias')

    # Inclui nação em uma federação
    with st.container(border=True):

        st.subheader('Inclua sua nação em uma federação existente/Crie uma federação para sua Nação')
        federacao = st.text_input(label='Nome da federação', placeholder='Insira o nome da federação')
        if st.button('Incluir nação'):
            with st.session_state.connection.cursor() as cursor:
                try:
                    cursor.callproc('gerenciamento_comandante.incluir_nacao_federacao', [st.session_state.nacao,federacao])
                    st.text(f'Nacão {st.session_state.nacao} incluída com sucesso na federacao {federacao}!')

                except DatabaseError as e:
                        if 'NACAO JA POSSUI FEDERACAO' in str(e):
                            st.text('Sua Nação já possui federação, favor remover para fazer a troca.')


    # Remove a Federação Atual
    with st.container(border=True):
        st.subheader('Remova a sua nação da federação atual')
        if st.button('Remover Federação'):
            with st.session_state.connection.cursor() as cursor:
                cursor.callproc('gerenciamento_comandante.excluir_nacao_federacao', [st.session_state.nacao])
                st.text('Federação removida com sucesso!')

    # Registrar dominância
    with st.container(border=True):
        st.subheader('Registre uma nova dominância')
        planeta = st.text_input(label='Nome do planeta', placeholder='Insira o nome do planeta')
        if st.button('Registrar dominância'):
            with st.session_state.connection.cursor() as cursor:
                try:
                    cursor.callproc('gerenciamento_comandante.registrar_dominancia', [st.session_state.nacao, planeta])
                    st.text('Planeta dominado com sucesso!')
                except DatabaseError as e:
                    if 'Planeta ja esta sob dominacao uma nacao' in str(e):
                        st.text('Planeta já está sob dominação uma nação!')


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
        case 'COMANDANTE':
            comandante()
        case 'CIENTISTA':
            cientista()

            
    if st.button('Voltar', type='primary', key='v2'):
        st.switch_page('pages/main_page.py')

if __name__ == '__main__':
    management_page()