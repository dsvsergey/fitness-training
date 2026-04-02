#!/usr/bin/env python3

import requests
import json


def test_route_resolution():
    print("🛣️ Testing Route Conflict Resolution")
    print("=" * 60)

    base_url = "http://localhost:8000"

    # Step 1: Login to get a fresh token
    print("1️⃣ Getting authentication token...")
    login_data = {"Username": "Dmitriy.mironyuk@gmail.com", "Password": "Sonik@9751"}

    try:
        response = requests.post(f"{base_url}/api/v1/login/", json=login_data)
        if response.status_code == 200:
            token_data = response.json()
            token = token_data["access_token"]
            print(f"   ✅ Token obtained: {token[:30]}...")

            headers = {"Authorization": f"Bearer {token}"}

            # Step 2: Test NEW endpoints (should have priority)
            print("\n2️⃣ Testing NEW coach endpoints (from auth.py)...")

            endpoints_new = [
                ("/api/v1/coaches/", "GET", "List coaches (new)"),
                ("/api/v1/coaches/me/", "GET", "Get current coach profile"),
                (
                    "/api/v1/coaches/register/",
                    "POST",
                    "Register new coach (will fail - test only)",
                ),
            ]

            for endpoint, method, description in endpoints_new:
                if method == "GET":
                    response = requests.get(f"{base_url}{endpoint}", headers=headers)
                    print(
                        f"   {method} {endpoint} -> {response.status_code} ({description})"
                    )
                    if response.status_code == 200:
                        data = response.json()
                        if isinstance(data, list):
                            print(f"       ✅ Success: Found {len(data)} records")
                        else:
                            print(f"       ✅ Success: {list(data.keys())}")
                    else:
                        print(f"       ❌ Error: {response.text[:100]}")

            # Step 3: Test LEGACY endpoints (should work under /legacy prefix)
            print("\n3️⃣ Testing LEGACY coach endpoints (from coachs.py)...")

            endpoints_legacy = [
                ("/api/v1/legacy/coaches/", "GET", "List coaches (legacy)"),
                ("/api/v1/legacy/coaches/10", "GET", "Get specific coach (legacy)"),
            ]

            for endpoint, method, description in endpoints_legacy:
                if method == "GET":
                    response = requests.get(f"{base_url}{endpoint}", headers=headers)
                    print(
                        f"   {method} {endpoint} -> {response.status_code} ({description})"
                    )
                    if response.status_code == 200:
                        data = response.json()
                        if isinstance(data, list):
                            print(f"       ✅ Success: Found {len(data)} records")
                        else:
                            print(f"       ✅ Success: {list(data.keys())}")
                    else:
                        print(f"       ❌ Error: {response.text[:100]}")

            # Step 4: Verify no conflicts
            print("\n4️⃣ Verification summary...")

            # Test both endpoints return expected results
            new_response = requests.get(f"{base_url}/api/v1/coaches/", headers=headers)
            legacy_response = requests.get(
                f"{base_url}/api/v1/legacy/coaches/", headers=headers
            )

            if new_response.status_code == 200 and legacy_response.status_code == 200:
                print("   ✅ Both endpoints accessible without conflicts")

                new_data = new_response.json()
                legacy_data = legacy_response.json()

                if len(new_data) == len(legacy_data):
                    print("   ✅ Both endpoints return same data (good consistency)")
                else:
                    print(
                        f"   ⚠️ Different data: New={len(new_data)}, Legacy={len(legacy_data)}"
                    )
            else:
                print(
                    f"   ❌ Conflict detected: New={new_response.status_code}, Legacy={legacy_response.status_code}"
                )

        else:
            print(f"   ❌ Login failed: {response.status_code} - {response.text}")

    except Exception as e:
        print(f"   ❌ Request error: {e}")


if __name__ == "__main__":
    test_route_resolution()
