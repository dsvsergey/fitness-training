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

    # Test updated endpoint with local coach IDs
    print("\n📋 Testing updated /api/v1/workout-appointments/ with local coach IDs...")

    filter_data = {
        "start_date": "2025-06-10",
        "end_date": "2025-06-17",
        "coach_ids": [10],  # Local coach ID instead of mindbody_id
    }

    try:
        response = requests.post(
            "http://localhost:8000/api/v1/workout-appointments/",
            headers=headers,
            json=filter_data,
        )
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Success! Found {len(data.get('appointments', []))} appointments")
            print(f"📅 Work days: {len(data.get('work_days', []))}")

            # Show first appointment if available
            if data.get("appointments"):
                first_appointment = data["appointments"][0]
                print(f"\n📝 First appointment:")
                print(f"   - ID: {first_appointment.get('id')}")
                print(
                    f"   - Coach: {first_appointment.get('coach', {}).get('full_name', 'N/A')}"
                )
                print(
                    f"   - Trainee: {first_appointment.get('trainee', {}).get('full_name', 'N/A')}"
                )
                print(f"   - Start: {first_appointment.get('start_at')}")
                print(f"   - Status: {first_appointment.get('status')}")
        else:
            print(f"❌ Error: {response.text}")

    except Exception as e:
        print(f"❌ Exception: {e}")

else:
    print(f"❌ Login failed: {login_response.text}")
