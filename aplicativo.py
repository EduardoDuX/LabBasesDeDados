import oracledb
import json

with open('credenciais.json', 'r') as f:
    cred = json.load(f)
    cs = cred['cs']
    un = cred['un']
    pw = cred['passwd']

with oracledb.connect(user=un, password=pw, dsn=cs) as connection:

    with connection.cursor() as cursor:
        sql = """select sysdate from dual"""
        for r in cursor.execute(sql):
            print(r)