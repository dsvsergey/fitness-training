#!/usr/bin/env python3

import requests
import json


def test_server_deployment():
    print("🌐 Testing Server Deployment")
    print("=" * 50)

    # Test both local and remote servers
    servers = [
        ("localhost", "http://localhost:8000"),
        ("remote", "http://78.138.17.28:8000"),
    ]

    for server_name, base_url in servers:
        print(f"\n🖥️ Testing {server_name.upper()} server: {base_url}")
        print("-" * 40)

        try:
            # Step 1: Health check
            print("1️⃣ Health check...")
            response = requests.get(f"{base_url}/api/v1/health/", timeout=10)
            print(f"   GET /api/v1/health/ -> {response.status_code}")

            if response.status_code == 200:
                health_data = response.json()
                print(f"   ✅ Server online! Status: {health_data.get('status')}")
                print(
                    f"   📊 MindBody configured: {health_data.get('mindbody_configured')}"
                )
                print(f"   🗄️ DB host: {health_data.get('db_host')}")
            else:
                print(f"   ❌ Health check failed: {response.text}")
                continue

            # Step 2: Test login
            print("\n2️⃣ Testing authentication...")
            login_data = {
                "Username": "Dmitriy.mironyuk@gmail.com",
                "Password": "Sonik@9751",
            }

            response = requests.post(
                f"{base_url}/api/v1/login/", json=login_data, timeout=10
            )
            print(f"   POST /api/v1/login/ -> {response.status_code}")

            if response.status_code == 200:
                token_data = response.json()
                token = token_data["access_token"]
                print(f"   ✅ Login success! Token: {token[:30]}...")

                # Step 3: Test protected endpoints
                print("\n3️⃣ Testing protected endpoints...")
                headers = {"Authorization": f"Bearer {token}"}

                test_endpoints = [
                    ("/api/v1/coaches/me/", "GET", "Current coach profile"),
                    ("/api/v1/coaches/", "GET", "List all coaches"),
                    ("/api/v1/legacy/coaches/", "GET", "Legacy coach list"),
                ]

                for endpoint, method, description in test_endpoints:
                    response = requests.get(
                        f"{base_url}{endpoint}", headers=headers, timeout=10
                    )
                    print(
                        f"   {method} {endpoint} -> {response.status_code} ({description})"
                    )

                    if response.status_code == 200:
                        data = response.json()
                        if isinstance(data, list):
                            print(f"       ✅ Success: {len(data)} records")
                        else:
                            print(f"       ✅ Success: Profile loaded")
                    else:
                        print(f"       ❌ Error: {response.text[:100]}")

                print(f"\n✅ {server_name.upper()} server test COMPLETED")

            else:
                print(f"   ❌ Login failed: {response.status_code} - {response.text}")

        except requests.exceptions.ConnectionError:
            print(f"   ❌ Cannot connect to {server_name} server")
        except requests.exceptions.Timeout:
            print(f"   ❌ Timeout connecting to {server_name} server")
        except Exception as e:
            print(f"   ❌ Error testing {server_name} server: {e}")

    print(f"\n🏁 Server deployment testing completed!")


if __name__ == "__main__":
    test_server_deployment()
