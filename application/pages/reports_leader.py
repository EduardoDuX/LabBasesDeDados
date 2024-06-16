# Função geral que organiza a página
import streamlit as st
import os
import csv
import pandas as pd
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

# Função geral que organiza a página
def reports_leader():
    st.set_page_config(
    page_title="Gerenciamento",
    layout="wide",
    initial_sidebar_state="collapsed",
    )

    if st.button('Voltar', type='primary', key='v5'):
        st.switch_page('pages/main_page.py')

    lider()

    if st.button('Voltar', type='primary', key='v6'):
        st.switch_page('pages/main_page.py')

if __name__ == '__main__':
    reports_leader()