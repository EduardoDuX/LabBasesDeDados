import streamlit as st
import csv
import pandas as pd
import os
from datetime import date
from oracledb import DatabaseError


# Função que organiza as opções de gerenciamento de cientista
def cientista():
    # Gerencia CRUD de estrelas
    st.title('Gerencie estrelas')

    # Criar
    with st.container(border=True):
        st.subheader('Criar estrela')
        selected_option_create = st.multiselect(
            'Selecione a opção para criação',
            ['Estrela com Sistema', 'Estrela orbitante'],
            max_selections=1,
            placeholder='Selecione uma opção'
        )

        if selected_option_create:
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

            opt_create = selected_option_create[0]
            match opt_create:
                case 'Estrela com Sistema':
                    st.text_input(label='Sistema', placeholder='Insira o nome do novo sistema', key='name_new_system')
                    
                    with st.session_state.connection.cursor() as cursor:
                        if len(st.session_state.id_new_star) > 31:
                            st.text('O ID da estrela deve ter no máximo 31 caracteres')
                        elif len(st.session_state.name_new_star) > 31:
                            st.text('O nome da estrela deve ter no máximo 31 caracteres')
                        elif len(st.session_state.name_new_system) > 31:
                            st.text('O nome do sistema deve ter no máximo 31 caracteres')
                        elif len(st.session_state.class_new_star) > 31:
                            st.text('A classe da estrela deve ter no máximo 31 caracteres')
                        else:
                            try:
                                cursor.callproc('usuario.log_message', [st.session_state.cpi, f'CRIA ESTRELA {st.session_state.id_new_star}'])
                                cursor.callproc('cientista.cria_estrela_com_sistema', [
                                    st.session_state.id_new_star,
                                    st.session_state.name_new_system,
                                    st.session_state.name_new_star,
                                    st.session_state.class_new_star,
                                    float(st.session_state.mass_new_star),
                                    float(st.session_state.x_new_star),
                                    float(st.session_state.y_new_star),
                                    float(st.session_state.z_new_star)
                                ])
                                st.text('Estrela criada com sucesso!')
                            except DatabaseError as e:
                                if 'Atributo com valor obrigatorio!' in str(e):
                                    st.text('Algum atributo da estrela não foi preenchdio e ele é necessário, favor preencher!')
                                elif 'Estrela ja existente!' in str(e):
                                    st.text('Estrela já existente!')
                                else:
                                    st.text(e)
                            except ValueError as e:
                                st.text('Verifique se as coordenadas e massa são números!')

                case 'Estrela orbitante':
                    st.text_input(label='Estrela orbitada', placeholder='Insira o ID da estrela orbitada', key='id_orbited_star')
                    st.text_input(
                        label='Distância mínima da órbita',
                        placeholder='Insira a distância mínima da nova órbita',
                        key='min_dist_new_orbit'
                    )
                    st.text_input(
                        label='Distância máxima da órbita',
                        placeholder='Insira a distância máxima da nova órbita',
                        key='max_dist_new_orbit'
                    )
                    st.text_input(label='Período da órbita', placeholder='Insira o período da nova órbita', key='period_new_orbit')

                    with st.session_state.connection.cursor() as cursor:
                        if len(st.session_state.id_new_star) > 31:
                            st.text('O ID da estrela deve ter no máximo 31 caracteres')
                        elif len(st.session_state.name_new_star) > 31:
                            st.text('O nome da estrela deve ter no máximo 31 caracteres')
                        elif len(st.session_state.id_orbited_star) > 31:
                            st.text('O ID da estrela orbitante deve ter no máximo 31 caracteres')
                        elif len(st.session_state.class_new_star) > 31:
                            st.text('A classe da estrela deve ter no máximo 31 caracteres')
                        else:
                            try:
                                st.text('tetes')
                                cursor.callproc('usuario.log_message', [st.session_state.cpi, f'CRIA ESTRELA {st.session_state.id_new_star}'])
                                cursor.callproc('cientista.cria_estrela_orbitante', [
                                    st.session_state.id_new_star,
                                    st.session_state.name_new_star,
                                    st.session_state.class_new_star,
                                    float(st.session_state.mass_new_star),
                                    float(st.session_state.x_new_star),
                                    float(st.session_state.y_new_star),
                                    float(st.session_state.z_new_star),
                                    st.session_state.id_orbited_star,
                                    st.session_state.min_dist_new_orbit,
                                    st.session_state.max_dist_new_orbit,
                                    st.session_state.period_new_orbit
                                ])
                                st.text('Estrela criada com sucesso!')
                            except DatabaseError as e:
                                if 'Atributo com valor obrigatorio!' in str(e):
                                    st.text('Algum atributo da estrela não foi preenchdio e ele é necessário, favor preencher!')
                                elif 'Estrela ja existente!' in str(e):
                                    st.text('Estrela já existente!')
                                elif 'parent key not found' in str(e):
                                    st.text('Estrela ORbitada não existe')
                            except ValueError as e:
                                st.text('Verifique se as coordenadas, massa, distancias e periodo são números!')
                            except Exception as e:
                                st.text(e)
                        

    # Ler (Read)
    with st.container(border=True):
        st.subheader('Visualize os dados de estrelas')
        selected_option_read = st.multiselect(
            'Selecione o filtro para visualização',
            ['Sem filtros', 'ID da estrela', 'Nome', 'Classificação', 'Massa'],
            max_selections=1,
            placeholder='Selecione uma opção'
        )
        
        if selected_option_read:
            opt_read = selected_option_read[0]
            match opt_read:
                case 'Sem filtros':
                    pass
                case 'ID da estrela':
                    st.text_input(label='Atributo', placeholder=f'Insira o ID da estrela', label_visibility='collapsed', key='id_read')
                case 'Nome':
                    st.text_input(label='Atributo', placeholder=f'Insira o nome da estrela', label_visibility='collapsed', key='name_read')
                case 'Massa':
                    st.text_input(label='Atributo', placeholder=f'Insira a massa da estrela', label_visibility='collapsed', key='mass_read')
                case 'Classificação':
                    st.text_input(
                        label='Atributo',
                        placeholder=f'Insira a classificação da estrela',
                        label_visibility='collapsed',
                        key='class_read'
                    )

            if st.button('Buscar dados'):
                match opt_read:
                    case 'Sem filtros':
                        with st.session_state.connection.cursor() as cursor:
                            ref = st.session_state.connection.cursor()

                            cursor.callproc('cientista.le_estrela', [ref])

                            with open("le_estrela.csv", "w", encoding='utf-8') as outputfile:
                                writer = csv.writer(outputfile, lineterminator="\n")
                                writer.writerows(ref)

                            columns = ['id_estrela', 'nome', 'classificacao', 'massa', 'coordenada_x', 'coordenada_y', 'coordenada_z']

                            result = pd.read_csv('le_estrela.csv', names=columns, header=None)

                            st.dataframe(result)

                            os.remove('le_estrela.csv')

                    case 'ID da estrela':
                        with st.session_state.connection.cursor() as cursor:
                            ref = st.session_state.connection.cursor()

                            cursor.callproc('cientista.le_estrela_id', [st.session_state.id_read, ref])

                            with open("le_estrela_id.csv", "w", encoding='utf-8') as outputfile:
                                writer = csv.writer(outputfile, lineterminator="\n")
                                writer.writerows(ref)

                            columns = ['id_estrela', 'nome', 'classificacao', 'massa', 'coordenada_x', 'coordenada_y', 'coordenada_z']

                            result = pd.read_csv('le_estrela_id.csv', names=columns, header=None)

                            st.dataframe(result)

                            os.remove('le_estrela_id.csv')

                    case 'Nome':
                        with st.session_state.connection.cursor() as cursor:
                            ref = st.session_state.connection.cursor()

                            cursor.callproc('cientista.le_estrela_nome', [st.session_state.name_read, ref])

                            with open("le_estrela_nome.csv", "w", encoding='utf-8') as outputfile:
                                writer = csv.writer(outputfile, lineterminator="\n")
                                writer.writerows(ref)

                            columns = ['id_estrela', 'nome', 'classificacao', 'massa', 'coordenada_x', 'coordenada_y', 'coordenada_z']

                            result = pd.read_csv('le_estrela_nome.csv', names=columns, header=None)

                            st.dataframe(result)

                            os.remove('le_estrela_nome.csv')

                    case 'Massa':
                        with st.session_state.connection.cursor() as cursor:
                            ref = st.session_state.connection.cursor()

                            cursor.callproc('cientista.le_estrela_massa', [st.session_state.mass_read, ref])

                            with open("le_estrela_massa.csv", "w", encoding='utf-8') as outputfile:
                                writer = csv.writer(outputfile, lineterminator="\n")
                                writer.writerows(ref)

                            columns = ['id_estrela', 'nome', 'classificacao', 'massa', 'coordenada_x', 'coordenada_y', 'coordenada_z']

                            result = pd.read_csv('le_estrela_massa.csv', names=columns, header=None)

                            st.dataframe(result)

                            os.remove('le_estrela_massa.csv')
                    case 'Classificação':
                        with st.session_state.connection.cursor() as cursor:
                            ref = st.session_state.connection.cursor()

                            cursor.callproc('cientista.le_estrela_classificacao', [st.session_state.class_read, ref])

                            with open("le_estrela_class.csv", "w", encoding='utf-8') as outputfile:
                                writer = csv.writer(outputfile, lineterminator="\n")
                                writer.writerows(ref)

                            columns = ['id_estrela', 'nome', 'classificacao', 'massa', 'coordenada_x', 'coordenada_y', 'coordenada_z']

                            result = pd.read_csv('le_estrela_class.csv', names=columns, header=None)

                            st.dataframe(result)

                            os.remove('le_estrela_class.csv')

    # Atualizar
    with st.container(border=True):
        st.subheader('Altere as informações de uma estrela')
        st.text_input('Insira o ID da estrela', key='id_update')
        selected_option_update = st.multiselect(
            'Selecione o atributo que deseja alterar',
            ['Nome', 'Classificação', 'Massa', 'Coordenadas'],
            max_selections=1,
            placeholder='Selecione uma opção'
        )
        if selected_option_update:
            opt_update = selected_option_update[0]
            match opt_update:
                case 'Nome':
                    st.text_input(label='Atributo', placeholder='Insira o nome da estrela', label_visibility='collapsed', key='name_update')
                case 'Coordenadas':
                    sub_col1, sub_col2, sub_col3 = st.columns(3)

                    with sub_col1:
                        st.text_input(label='X', placeholder='Insira a coordenada X', key='x_update')

                    with sub_col2:
                        st.text_input(label='Y', placeholder='Insira a coordenada Y', key='y_update')

                    with sub_col3:
                        st.text_input(label='Z', placeholder='Insira a coordenada Z', key='z_update')
                case 'Massa':
                    st.text_input(label='Atributo', placeholder=f'Insira a massa da estrela', label_visibility='collapsed', key='mass_update')
                case 'Classificação':
                    st.text_input(
                        label='Atributo',
                        placeholder=f'Insira a classificação da estrela',
                        label_visibility='collapsed',
                        key='class_update'
                    )

            if st.button('Atualizar estrela'):
                cursor.callproc('usuario.log_message', [st.session_state.cpi, f'UPDATE ESTRELA {st.session_state.id_update}'])
                match opt_update:
                    case 'Nome':
                        with st.session_state.connection.cursor() as cursor:
                            
                            cursor.callproc(
                                'cientista.atualiza_estrela_nome',
                                [st.session_state.id_update, st.session_state.name_update]
                            )
                            
                        st.text(f'Nome da estrela {st.session_state.id_update} atualizado com sucesso!')
                    case 'Classificação':
                        with st.session_state.connection.cursor() as cursor:
                            cursor.callproc(
                                'cientista.atualiza_estrela_classificacao',
                                [st.session_state.id_update, st.session_state.class_update]
                            )
                            
                        st.text(f'Classificação da estrela {st.session_state.id_update} atualizada com sucesso!')
                    case 'Massa':
                        with st.session_state.connection.cursor() as cursor:
                            try:
                                cursor.callproc(
                                    'cientista.atualiza_estrela_masssa',
                                    [st.session_state.id_update, st.session_state.mass_update]
                                )
                                st.text(f'Massa da estrela {st.session_state.id_update} atualizada com sucesso!')
                            except DatabaseError as e:
                                if 'Massa deve ser maior que 0!' in str(e):
                                    st.text('A massa de uma estrela deve ser maior que 0!')
                            
                    case 'Coordenadas':
                        with st.session_state.connection.cursor() as cursor:
                            try:
                                cursor.callproc(
                                    'cientista.atualiza_estrela_nome',
                                    [
                                        st.session_state.id_update,
                                        st.session_state.x_update,
                                        st.session_state.y_update,
                                        st.session_state.z_update
                                    ]
                                )
                                st.text(f'Coordenadas da estrela {st.session_state.id_update} atualizadas com sucesso!')
                            except DatabaseError as e:
                                if 'Coordenadas conflitantes com outra estrela.' in str(e):
                                    st.text('Nestas coordenadas já está localizada outra estrela!')

    # Remover
    with st.container(border=True):
        st.subheader('Remova uma estrela')
        st.text_input('Insira o ID da estrela', key='id_delete')
        if st.button('Remover estrela'):

            if len(st.session_state.id_delete) > 31:
                st.text(f'ID da estrela deve ter até 31 dígitos.')
            else:
                with st.session_state.connection.cursor() as cursor:
                    cursor.callproc('usuario.log_message', [st.session_state.cpi, f'REMOVE ESTRELA {st.session_state.id_delete}'])
                    cursor.callproc('cientista.remove_estrela', [st.session_state.id_delete])
                st.text('Estrela removida com sucesso!')


# Função que organiza as opções de gerenciamento de comandante
def comandante():
    st.title('Gerencie sua nação e suas dominâncias')

    # Inclui nação em uma federação
    with st.container(border=True):

        st.subheader('Inclua sua nação em uma federação existente/Crie uma federação para sua Nação')
        federacao = st.text_input(label='Nome da federação', placeholder='Insira o nome da federação')
        if st.button('Incluir nação'):
            
            if len(federacao) > 15:
                st.text(f'Nome da Federação deve ter até 15 dígitos.')
            else:
                with st.session_state.connection.cursor() as cursor:
                    try:
                        cursor.callproc('usuario.log_message', [st.session_state.cpi, f'INCLUI NACAO {st.session_state.nacao} NA FEDERACAO {federacao}'])
                        cursor.callproc('comandante.incluir_nacao_federacao', [st.session_state.nacao,federacao])
                        st.text(f'Nacão {st.session_state.nacao} incluída com sucesso na federacao {federacao}!')

                    except DatabaseError as e:
                            if 'NACAO JA POSSUI FEDERACAO' in str(e):
                                st.text('Sua Nação já possui federação, favor remover para fazer a troca.')


    # Remove a Federação Atual
    with st.container(border=True):
        st.subheader('Remova a sua nação da federação atual')
        if st.button('Remover Federação'):
            with st.session_state.connection.cursor() as cursor:
                cursor.callproc('usuario.log_message', [st.session_state.cpi, f'REMOVE FEDERACAO DA NACAO {st.session_state.nacao}'])
                cursor.callproc('comandante.excluir_nacao_federacao', [st.session_state.nacao])
                st.text('Federação removida com sucesso!')

    # Registrar dominância
    with st.container(border=True):
        st.subheader('Registre uma nova dominância')
        planeta = st.text_input(label='Nome do planeta', placeholder='Insira o nome do planeta')
        if st.button('Registrar dominância'):
            if len(planeta) > 15:
                st.text(f'Nome do planeta deve ter até 15 dígitos.')
            else:
                with st.session_state.connection.cursor() as cursor:
                    try:
                        cursor.callproc('usuario.log_message', [st.session_state.cpi, f'NACAO {st.session_state.nacao} DOMINA O PLANETA {planeta}'])
                        cursor.callproc('comandante.registrar_dominancia', [st.session_state.nacao, planeta])
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
        case 'COMANDANTE':
            comandante()
        case 'CIENTISTA':
            cientista()
            
    if st.button('Voltar', type='primary', key='v2'):
        st.switch_page('pages/main_page.py')

if __name__ == '__main__':
    management_page()