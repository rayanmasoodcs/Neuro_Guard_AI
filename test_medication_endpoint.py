#!/usr/bin/env python
import requests
import json

# Test get_medications endpoint
BASE_URL = "http://127.0.0.1:5000"

# Assume user_id = 4 (the newly created user from signup)
user_id = 4

try:
    resp = requests.get(f"{BASE_URL}/get_medications/{user_id}")
    print(f"Status: {resp.status_code}")
    print(f"Response: {resp.text}")
except Exception as e:
    print(f"Error: {e}")
