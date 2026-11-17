from python_backend.auth.app import get_medical_history, db_config
from python_backend.auth.app import app

with app.app_context():
    try:
        resp = get_medical_history('3')
        print('Response:', resp)
    except Exception as e:
        import traceback
        traceback.print_exc()
        print('Exception:', e)
