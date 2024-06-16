import streamlit as st
import pandas as pd
import csv 
import os
from oracledb import Cursor
from pandas import DataFrame

# Função auxiliar que retorna os relatórios em um DataFrame
def get_report(columns: list[str], filename: str, cursor: Cursor) -> DataFrame:
    with open(filename, 'w', encoding='utf-8') as outputfile:
        writer = csv.writer(outputfile, lineterminator='\n')
        writer.writerows(cursor)

    result = pd.read_csv(filename, names=columns, header=None)

    os.remove(filename)

    return result

# Função que gera os relatórios de líder
def lider():
    st.title('Gere relatórios para a sua facção')

    with st.container(border=True):
        st.subheader('Aqui você pode gerar relatórios para as comunidades de sua facção. Escolha um filtro para o relatório')
        selected_option_ldr = st.multiselect('Filtro para o relatório', ['Sem filtros', 'Nação', 'Espécie', 'Planeta', 'Sistema'], max_selections=1, placeholder='Selecione uma opção')

        if selected_option_ldr:
            opt_ldr = selected_option_ldr[0]

            match opt_ldr:
                case 'Sem filtros':
                    st.session_state['filter_ldr'] = ''
                    column_name = 'Total comunidades'
                case 'Nação':
                    st.session_state['filter_ldr'] = 'NACAO'
                    column_name = 'Nação'
                case 'Espécie':
                    st.session_state['filter_ldr'] = 'ESPECIE'
                    column_name = 'Espécie'
                case 'Planeta':
                    st.session_state['filter_ldr'] = 'PLANETA'
                    column_name = 'Planeta'
                case 'Sistema':
                    st.session_state['filter_ldr'] = 'SISTEMA'
                    column_name = 'Sistema'
            
            if st.button('Gerar relatório', key='r1'):
                with st.sesion_state.connection.cursor() as cursor:
                    ref = st.session_state.connection.cursor()

                    cursor.callproc('lider_faccao.relatorio_comunidade', [st.session_state.nacao, st.session_state.filter_ldr, ref])

                    columns = [column_name, 'Quantidade de comunidades']

                    df = get_report(columns, 'relatorio_comunidades.csv', ref)
                    
                    st.dataframe(df)

# Função que gera os relatórios de oficial
def oficial():
    st.title('Gere relatórios para a sua nação')
    
    with st.container(border=True):
        st.subheader('Aqui você pode gerar relatórios para as habitações de sua nação. Escolha um filtro para o relatório')
        selected_option_ofc = st.multiselect('Filtro para o relatório', ['Sem filtros', 'Facção', 'Espécie', 'Planeta', 'Sistema'], max_selections=1, placeholder='Selecione uma opção')

        if selected_option_ofc:
            opt_ofc = selected_option_ofc[0]

            match opt_ofc:
                case 'Sem filtros':
                    st.session_state['filter_ofc'] = ''
                    column_name = 'Total comunidades'
                case 'Facção':
                    st.session_state['filter_ofc'] = 'FACCAO'
                    column_name = 'Facção'
                case 'Espécie':
                    st.session_state['filter_ofc'] = 'ESPECIE'
                    column_name = 'Espécie'
                case 'Planeta':
                    st.session_state['filter_ofc'] = 'PLANETA'
                    column_name = 'Planeta'
                case 'Sistema':
                    st.session_state['filter_ofc'] = 'SISTEMA'
                    column_name = 'Sistema'
            
            if st.button('Gerar relatório', key='r2'):
                    with st.session_state.connection.cursor() as cursor:                    
                        ref = st.session_state.connection.cursor()

                        cursor.callproc('oficial.relatorio_habitacao', [st.session_state.nacao, st.session_state.filter_ofc, ref])

                        columns = [column_name, 'Quantidade de habitantes']
                        
                        df = get_report(columns, 'relatorio_habitacoes.csv', ref)
                        
                        st.dataframe(df)

# Função que gera os relatórios de cientista
def cientista():
    st.title('Gere relatórios sobre estrelas, planetas e sistemas')
    
    # Relatório de estrela
    with st.container(border=True):
        st.subheader('Aqui você pode gerar um relatório sobre alguma estrela')
        id_estrela = st.text_input(label='Estrela', placeholder='Insira o ID da estrela')

        if st.button('Gerar relatório', key='r3'):
            with st.session_state.connection.cursor() as cursor:
                ref = st.session_state.connection.cursor()

                cursor.callproc('cientista.report_estrela', [id_estrela, ref])

                cols_estrela = ['Estrela', 'Coord. X', 'Coord. Y', 'Coord. Z', 'Nome', 'Classificação', 'Massa']

                df_estrela = get_report(cols_estrela, 'relatorio_estrela', ref)

                st.dataframe(df_estrela)

    # Relatório de planeta
    with st.container(border=True):
        st.subheader('Aqui você pode gerar um relatório sobre algum planeta')
        id_planeta = st.text_input(label='Planeta', placeholder='Insira o ID do planeta')

        if st.button('Gerar relatório', key='r4'):
            with st.session_state.connection.cursor() as cursor:
                ref = st.session_state.connection.cursor()

                cursor.callproc('cientista.report_planeta', [id_planeta, ref])

                cols_plan = ['Planeta', 'Massa', 'Raio', 'Clasificação']

                df_planeta = get_report(cols_plan, 'relatorio_planeta.csv', ref)

                st.dataframe(df_planeta)

    # Relatório de sistema
    with st.container(border=True):
        st.subheader('Aqui você pode gerar um relatório sobre algum sistema')
        id_sistema = st.text_input(label='Estrela', placeholder='Insira o ID da estrela cujo sistema deseja gerar o relatório')

        if st.button('Gerar relatório', key='r5'):
            with st.session_state.connection.cursor() as cursor:
                ref = st.session_state.connection.cursor()

                cursor.callproc('cientista.report_sistema', [id_sistema, ref])

                cols_sistema = ['Estrela', 'Sistema']

                df_sistema = get_report(cols_sistema, 'relatorio_sistema.csv', ref)

                st.dataframe(df_sistema)


# Função que gera relatórios de comandante
def comandante():
    st.title('Gere relatórios sobre planetas e obtenha informações estratégicas')

    with st.container(border=True):
        st.subheader('Aqui você pode gerar relatórios para as dominâncias de todas as nações e para planetas estratégicos.')

        with st.session_state.connection.cursor() as cursor:
            dom_atual = st.session_state.connection.cursor()
            ultima_dom = st.session_state.connection.cursor()
            planetas = st.session_state.connection.cursor()
            infos_estrat = st.session_state.connection.cursor()

            coll_type = st.session_state.connection.gettype('COMANDANTE.PLANETAS_EXPANSAO')
            planetas_exp = coll_type.newobject()

            # Obtendo os relatórios
            cursor.callproc('comandante.relatorio_comandante', [st.session_state.nacao,
                                                                dom_atual,
                                                                ultima_dom,
                                                                planetas,
                                                                infos_estrat,
                                                                planetas_exp])
            
            # Armazenando os relatórios em dataframes
            cols_dom_atual = ['Dominâncias atuais']
            df_dom_atual = get_report(cols_dom_atual, 'relatorio_dom_atuais.csv', dom_atual)

            cols_ultima_dom = ['Data de início da última dominância', 'Data de fim da última dominância']
            df_ultima_dom = get_report(cols_ultima_dom, 'relatorio_ultima_dom.csv', ultima_dom)

            cols_planetas = ['Planeta', 
                             'Quantidade de comunidades', 
                             'Quantidade de espécies', 
                             'Quantidade de habitações',
                             'Quantidade de facções',
                             'Facção majoritária',
                             'Quantidade de esp. originárias']
            df_planetas = get_report(cols_planetas, 'relatorio_planetas.csv', planetas)

            cols_infos_estrat = ['Nação', 
                                 'Quantidade de planetas', 
                                 'Federação', 
                                 'Quantidade de facções', 
                                 'Quantidade de líderes']
            df_infos_estrat = get_report(cols_infos_estrat, 'relatorio_infos_estrat.csv', infos_estrat)

            # Armazenando o resultado do relatório de planetas para expansão -> 
            # seu resultado está em uma collection            
            with open('planeta_collection.csv', 'w', encoding='utf-8') as outputfile:
                spamwriter = csv.writer(outputfile, lineterminator="\n")
                # Acessando os valores da collection individualmente
                ix = planetas_exp.first()
                while ix is not None:
                    spamwriter.writerow([planetas_exp.getelement(ix).ID_ASTRO, planetas_exp.getelement(ix).CLASSIFICACAO, planetas_exp.getelement(ix).DISTANCIA_NACAO])
                    ix = planetas_exp.next(ix)

            cols_plan_expansao = ['Planeta', 'Classificação', 'Distância']

            df_plan_expansao = pd.read_csv('planeta_collection.csv', names=cols_plan_expansao, header=None)

            os.remove('planeta_collection.csv')

            # Exibindo os relatórios
            with st.container(border=True):
                st.text('Informações sobre as dominâncias')
                st.dataframe(df_dom_atual)
                st.dataframe(df_ultima_dom)

            with st.container(border=True):
                st.text('Informações sobre planetas')
                st.dataframe(df_planetas)

            with st.container(border=True):
                st.text('Informações extratégicas')
                st.dataframe(df_infos_estrat)

            with st.container(border=True):
                st.text('Informações de possíveis planetas pra expansão')
                st.dataframe(df_plan_expansao)

# Função geral que organiza a página
def reports_page():
    st.set_page_config(
    page_title="Gerenciamento",
    layout="wide",
    initial_sidebar_state="collapsed",
    )

    if st.button('Voltar', type='primary', key='v3'):
        st.switch_page('pages/main_page.py')

    match st.session_state.user_type:
        case 'LIDER':
            lider()
        case 'COMANDANTE':
            comandante()
        case 'CIENTISTA':
            cientista()
        case 'OFICIAL':
            oficial()

    if st.button('Voltar', type='primary', key='v4'):
        st.switch_page('pages/main_page.py')

if __name__ == '__main__':
    reports_page()