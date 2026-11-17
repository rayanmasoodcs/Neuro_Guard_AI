from python_backend.auth.db_fallback import get_connection
conn = get_connection({'host':'127.0.0.1'})
print('conn type:', type(conn), getattr(conn, '_conn', None))
cur = conn.cursor()
q = "INSERT INTO medications (user_id, medicine_name, dose, description, frequency, timing, take_with) VALUES (%s, %s, %s, %s, %s, %s, %s)"
print('SQL before:', q)
try:
    cur.execute(q, (1,'Aspirin','100mg','desc','Once','Morning',''))
    conn.commit()
    print('Insert OK')
except Exception as e:
    print('Error:', e)
finally:
    try: cur.close()
    except: pass
    try: conn.close()
    except: pass
