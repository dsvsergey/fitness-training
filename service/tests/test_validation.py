#!/usr/bin/env python3

import requests
import json


def test_current_user_validation():
    print("🔍 Testing get_current_user validation")
    print("=" * 50)

    base_url = "http://localhost:8000"

    # Step 1: Login to get a fresh token
    print("1️⃣ Logging in to get fresh token...")
    login_data = {"Username": "Dmitriy.mironyuk@gmail.com", "Password": "Sonik@9751"}

    try:
        response = requests.post(f"{base_url}/api/v1/login/", json=login_data)
        if response.status_code == 200:
            token_data = response.json()
            token = token_data["access_token"]
            print(f"   ✅ Login success! Token: {token[:50]}...")

            # Step 2: Test protected endpoint
            print("\n2️⃣ Testing protected endpoint...")
            headers = {"Authorization": f"Bearer {token}"}

            # Try the new coaches endpoint from auth.py
            response = requests.get(f"{base_url}/api/v1/coaches/me/", headers=headers)
            print(f"   GET /api/v1/coaches/me/ -> {response.status_code}")
            if response.status_code == 200:
                print(f"   ✅ Success: {response.json()}")
            else:
                print(f"   ❌ Error: {response.text}")

            # Try the legacy coaches endpoint from coachs.py (if accessible)
            response = requests.get(
                f"{base_url}/api/v1/coaches/?skip=0&limit=100", headers=headers
            )
            print(f"   GET /api/v1/coaches/ (legacy) -> {response.status_code}")
            if response.status_code == 200:
                print(f"   ✅ Success: {response.json()}")
            else:
                print(f"   ❌ Error: {response.text}")

        else:
            print(f"   ❌ Login failed: {response.status_code} - {response.text}")

    except Exception as e:
        print(f"   ❌ Request error: {e}")


if __name__ == "__main__":
    test_current_user_validation()
