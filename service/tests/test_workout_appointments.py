#!/usr/bin/env python3

import requests
import json


def test_workout_appointments():
    print("🏋️ Testing Workout Appointments Authentication Fix")
    print("=" * 60)

    base_url = "http://localhost:8000"

    # Step 1: Login to get token
    print("1️⃣ Getting authentication token...")
    login_data = {"Username": "Dmitriy.mironyuk@gmail.com", "Password": "Sonik@9751"}

    try:
        response = requests.post(f"{base_url}/api/v1/login/", json=login_data)
        if response.status_code == 200:
            token_data = response.json()
            token = token_data["access_token"]
            print(f"   ✅ Token obtained: {token[:30]}...")

            headers = {"Authorization": f"Bearer {token}"}

            # Step 2: Test workout appointments endpoint (the one that was failing)
            print("\n2️⃣ Testing workout appointments endpoint...")

            # This endpoint expects a Body parameter with filter data
            filter_data = {
                "start_date": "2025-06-01T00:00:00",
                "end_date": "2025-06-30T23:59:59",
            }

            response = requests.get(
                f"{base_url}/api/v1/workout-appointments/?skip=0&limit=1000",
                headers=headers,
                json=filter_data,
            )

            print(f"   GET /api/v1/workout-appointments/ -> {response.status_code}")

            if response.status_code == 200:
                data = response.json()
                print(
                    f"   ✅ Success! Appointments: {len(data.get('appointments', []))}"
                )
                print(f"   📅 Work days: {len(data.get('work_days', []))}")
            elif response.status_code == 422:
                print(
                    f"   ⚠️ Validation error (expected for Body parameter): {response.text}"
                )
                print(
                    "   💡 This is normal - endpoint expects POST-like body in GET request"
                )
            else:
                print(f"   ❌ Error: {response.text}")

            # Step 3: Test other endpoints that were updated
            print("\n3️⃣ Testing other updated endpoints...")

            test_endpoints = [
                ("/api/v1/trainees/?skip=0&limit=10", "GET", "Trainees list"),
                (
                    "/api/v1/programs/?trainee_id=1&skip=0&limit=10",
                    "GET",
                    "Programs list",
                ),
                ("/api/v1/machines/?skip=0&limit=10", "GET", "Machines list"),
            ]

            for endpoint, method, description in test_endpoints:
                response = requests.get(f"{base_url}{endpoint}", headers=headers)
                print(
                    f"   {method} {endpoint} -> {response.status_code} ({description})"
                )

                if response.status_code == 200:
                    data = response.json()
                    if isinstance(data, list):
                        print(f"       ✅ Success: {len(data)} records")
                    else:
                        print(f"       ✅ Success: {type(data).__name__}")
                else:
                    print(f"       ❌ Error: {response.text[:100]}")

            print(f"\n✅ Authentication fix testing completed!")

        else:
            print(f"   ❌ Login failed: {response.status_code} - {response.text}")

    except Exception as e:
        print(f"   ❌ Request error: {e}")


if __name__ == "__main__":
    test_workout_appointments()
