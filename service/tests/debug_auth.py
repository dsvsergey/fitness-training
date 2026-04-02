#!/usr/bin/env python3

import os
import sys
from pathlib import Path

# Add the app directory to Python path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))


def test_auth():
    print("🔐 Authentication Debug")
    print("=" * 50)

    # Test token creation and validation
    from jose import jwt
    from app.core.config import settings
    from app.core.auth import create_access_token
    from app.db.session import SessionLocal
    from app.services.coach_service import CoachService

    # Create DB session
    db = SessionLocal()

    try:
        # Get coach
        coach_service = CoachService(db)
        coach = coach_service.get_coach(10)

        if coach:
            print(f"✅ Coach found: {coach.email} (ID: {coach.id})")

            # Create token
            token = create_access_token(sub=f"coach:{coach.id}")
            print(f"🎟️ Generated token: {token[:50]}...")

            # Test token decode
            try:
                payload = jwt.decode(
                    token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM]
                )
                print(f"✅ Token decode success: {payload.get('sub')}")

                # Test get_current_user logic
                user_subject = payload.get("sub")
                if ":" in user_subject:
                    user_type, user_id_str = user_subject.split(":", 1)
                    user_id = int(user_id_str)

                    if user_type == "coach":
                        test_coach = coach_service.get_coach(user_id)
                        if test_coach:
                            print(
                                f"✅ Auth validation would succeed: coach:{test_coach.id}"
                            )
                        else:
                            print(f"❌ Coach not found in validation: {user_id}")

            except Exception as e:
                print(f"❌ Token validation error: {e}")

        else:
            print(f"❌ Coach not found with ID 10")

    except Exception as e:
        print(f"❌ Database error: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    test_auth()
