#!/usr/bin/env python3

import requests

# Login first
login_data = {"email": "Dmitriy.mironyuk@gmail.com", "password": "Sonik@9751"}

print("🔐 Logging in...")
login_response = requests.post("http://localhost:8000/api/v1/login/", json=login_data)

if login_response.status_code == 200:
    token = login_response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Login successful!")

    # Test simple endpoint
    print("\n📋 Testing simple test endpoint...")
    try:
        response = requests.get(
            "http://localhost:8000/api/v1/workout-appointments/test/", headers=headers
        )
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Success! Found {data.get('count')} appointments")
            for appt in data.get("appointments", []):
                print(
                    f"  - ID: {appt['id']}, Start: {appt['start_at']}, Status: {appt['status']}"
                )
        else:
            print(f"Response: {response.text}")

    except Exception as e:
        print(f"Error: {e}")

else:
    print(f"❌ Login failed: {login_response.status_code}")
    print(f"Response: {login_response.text}")
