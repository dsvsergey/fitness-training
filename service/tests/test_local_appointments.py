#!/usr/bin/env python3

import sys
import requests
import json
from pathlib import Path

# Add the app directory to Python path
current_dir = Path(__file__).parent.parent
sys.path.insert(0, str(current_dir))


def test_local_appointments_endpoint():
    """Test the new local appointments endpoint"""

    print("🧪 Testing Local Workout Appointments Endpoint")
    print("=" * 60)

    # Test data
    base_url = "http://localhost:8000"

    # First, login to get token
    login_data = {"email": "Dmitriy.mironyuk@gmail.com", "password": "Sonik@9751"}

    try:
        # Login
        print("🔐 Logging in...")
        login_response = requests.post(f"{base_url}/api/v1/login/", json=login_data)

        if login_response.status_code != 200:
            print(f"❌ Login failed: {login_response.status_code}")
            print(f"Response: {login_response.text}")
            return False

        token = login_response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        print("✅ Login successful!")

        # Test cases
        test_cases = [
            {"name": "All appointments (no filter)", "filter": {}},
            {
                "name": "Appointments for today",
                "filter": {"start_date": "2025-06-11", "end_date": "2025-06-11"},
            },
            {
                "name": "Appointments for specific coaches",
                "filter": {
                    "coach_ids": [1, 2, 3],
                    "start_date": "2025-06-10",
                    "end_date": "2025-06-25",
                },
            },
            {
                "name": "Completed appointments only",
                "filter": {
                    "status": "Completed",
                    "start_date": "2025-06-10",
                    "end_date": "2025-06-25",
                },
            },
        ]

        for test_case in test_cases:
            print(f"\n📋 Test: {test_case['name']}")
            print("-" * 40)

            try:
                response = requests.post(
                    f"{base_url}/api/v1/workout-appointments/local/",
                    headers=headers,
                    json=test_case["filter"],
                )

                if response.status_code == 200:
                    data = response.json()
                    appointments = data.get("appointments", [])
                    work_days = data.get("work_days", [])

                    print(f"✅ Success: {len(appointments)} appointments found")
                    print(f"📅 Work days: {len(work_days)}")

                    # Show first few appointments
                    for i, appointment in enumerate(appointments[:3]):
                        coach_name = appointment.get("coach", {}).get(
                            "first_name", "Unknown"
                        )
                        trainee_name = appointment.get("trainee", {}).get(
                            "first_name", "Unknown"
                        )
                        start_time = appointment.get("start_at", "Unknown")
                        status = appointment.get("status", "Unknown")

                        print(
                            f"   {i+1}. {start_time} - {coach_name} with {trainee_name} ({status})"
                        )

                    if len(appointments) > 3:
                        print(f"   ... and {len(appointments) - 3} more")

                else:
                    print(f"❌ Error: {response.status_code}")
                    print(f"Response: {response.text[:200]}...")

            except Exception as e:
                print(f"❌ Request failed: {e}")

        print(f"\n🎉 Local appointments endpoint testing completed!")
        return True

    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False


def test_filter_examples():
    """Show example filter requests"""

    print("\n📚 Example Filter Requests")
    print("=" * 50)

    examples = [
        {
            "description": "Get all appointments for next week",
            "filter": {"start_date": "2025-06-16", "end_date": "2025-06-22"},
        },
        {
            "description": "Get appointments for specific coach",
            "filter": {
                "coach_ids": [1],
                "start_date": "2025-06-10",
                "end_date": "2025-06-20",
            },
        },
        {
            "description": "Get booked appointments only",
            "filter": {"status": "Booked", "start_date": "2025-06-10"},
        },
        {
            "description": "Get appointments for specific trainees",
            "filter": {"trainee_ids": [26, 27, 28], "start_date": "2025-06-10"},
        },
    ]

    for example in examples:
        print(f"\n📋 {example['description']}")
        print("POST /api/v1/workout-appointments/local/")
        print("Headers: Authorization: Bearer <token>")
        print("Body:")
        print(json.dumps(example["filter"], indent=2))


if __name__ == "__main__":
    print("🚀 Starting Local Appointments Test")

    if len(sys.argv) > 1 and sys.argv[1] == "examples":
        test_filter_examples()
    else:
        success = test_local_appointments_endpoint()
        sys.exit(0 if success else 1)
