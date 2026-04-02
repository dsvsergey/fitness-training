#!/usr/bin/env python3

import requests
import json

# Login first
login_data = {"email": "Dmitriy.mironyuk@gmail.com", "password": "Sonik@9751"}

print("🔐 Logging in...")
login_response = requests.post("http://localhost:8000/api/v1/login/", json=login_data)

if login_response.status_code == 200:
    token = login_response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Login successful!")

    # Test simple empty body
    print("\n📋 Testing empty body...")
    try:
        response = requests.post(
            "http://localhost:8000/api/v1/workout-appointments/local/",
            headers=headers,
            json={},
        )
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")

    except Exception as e:
        print(f"Error: {e}")

else:
    print(f"❌ Login failed: {login_response.status_code}")
    print(f"Response: {login_response.text}")
