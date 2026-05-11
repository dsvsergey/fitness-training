#!/usr/bin/env python3

import os
import sys
from pathlib import Path

# Add the app directory to Python path
current_dir = Path(__file__).parent
app_dir = current_dir / "app"
sys.path.insert(0, str(current_dir))

from jose import jwt
from app.core.config import settings


def debug_token():
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzX3Rva2VuIiwiZXhwIjoxNzUwMjc0ODU0LCJpYXQiOjE3NDk1ODM2NTQsInN1YiI6ImNvYWNoOjEwIiwianRpIjoiMjAyNS0wNi0xMCAyMjoyNzozNC4zNDIzODAifQ.jpfxdhMbPzXFvIHjzXZx2l-wbWJFFRMGSasjnhPyYL4"

    print("🔍 Token Debug Information")
    print("=" * 50)

    # Decode without verification
    print("📝 Token payload (no verification):")
    try:
        payload_unverified = jwt.get_unverified_claims(token)
        print(f"   Payload: {payload_unverified}")
        print(f"   Subject: {payload_unverified.get('sub')}")
    except Exception as e:
        print(f"   Error decoding unverified: {e}")

    # Check JWT settings
    print(f"\n🔑 JWT Settings:")
    print(f"   JWT_SECRET: {settings.JWT_SECRET[:10]}...")
    print(f"   JWT_ALGORITHM: {settings.JWT_ALGORITHM}")

    # Try to decode with verification
    print(f"\n✅ Token verification:")
    try:
        payload_verified = jwt.decode(
            token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM]
        )
        print(f"   ✅ Valid! Payload: {payload_verified}")
    except jwt.ExpiredSignatureError:
        print(f"   ❌ Token expired")
    except jwt.JWTError as e:
        print(f"   ❌ JWT Error: {e}")
    except Exception as e:
        print(f"   ❌ Other error: {e}")


if __name__ == "__main__":
    debug_token()
