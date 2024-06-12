import streamlit as st

def reports_page():
    if st.button('Voltar'):
        st.switch_page('pages/main_page.py')

if __name__ == '__main__':
    reports_page()