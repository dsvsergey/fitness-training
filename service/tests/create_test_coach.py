#!/usr/bin/env python3
"""
Script to create a test coach for local authentication testing
"""

import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.db.session import SessionLocal
from app.services.coach_service import CoachService
from app.schemas.coachs import CoachCreate


def create_test_coach():
    """Create a test coach for testing"""
    db = SessionLocal()

    try:
        coach_service = CoachService(db)

        # Test coach data
        coach_data = CoachCreate(
            email="Dmitriy.mironyuk@gmail.com",
            first_name="Dmitriy",
            last_name="Mironyuk",
            mobile_phone="+1234567890",
            city="Test City",
            country="Ukraine",
            biography="Test coach for local authentication",
        )

        password = "Sonik@9751"

        # Check if coach already exists
        existing_coach = coach_service.get_coach_by_email(coach_data.email)
        if existing_coach:
            print(f"Coach with email {coach_data.email} already exists!")
            print(f"Coach ID: {existing_coach.id}")
            print(f"Name: {existing_coach.first_name} {existing_coach.last_name}")
            return existing_coach

        # Create new coach
        coach = coach_service.create_coach(coach_data, password)

        print("✅ Test coach created successfully!")
        print(f"Coach ID: {coach.id}")
        print(f"Email: {coach.email}")
        print(f"Name: {coach.first_name} {coach.last_name}")
        print(f"Password: {password}")
        print("\nYou can now test login with:")
        print(f"Email: {coach.email}")
        print(f"Password: {password}")

        return coach

    except Exception as e:
        print(f"❌ Error creating test coach: {str(e)}")
        db.rollback()
        return None
    finally:
        db.close()


def list_coaches():
    """List all coaches"""
    db = SessionLocal()

    try:
        coach_service = CoachService(db)
        coaches = coach_service.get_coaches()

        if not coaches:
            print("No coaches found.")
            return

        print(f"\n📋 Found {len(coaches)} coaches:")
        print("-" * 60)
        for coach in coaches:
            print(f"ID: {coach.id}")
            print(f"Email: {coach.email}")
            print(f"Name: {coach.first_name} {coach.last_name}")
            print(f"Created: {coach.created_at}")
            print(f"Has User: {'Yes' if coach.user else 'No'}")
            print("-" * 60)

    except Exception as e:
        print(f"❌ Error listing coaches: {str(e)}")
    finally:
        db.close()


def test_authentication():
    """Test coach authentication"""
    db = SessionLocal()

    try:
        coach_service = CoachService(db)

        email = "Dmitriy.mironyuk@gmail.com"
        password = "Sonik@9751"

        print(f"\n🔐 Testing authentication for {email}...")

        coach = coach_service.authenticate_coach(email, password)

        if coach:
            print("✅ Authentication successful!")
            print(f"Coach ID: {coach.id}")
            print(f"Name: {coach.first_name} {coach.last_name}")
        else:
            print("❌ Authentication failed!")

    except Exception as e:
        print(f"❌ Error testing authentication: {str(e)}")
    finally:
        db.close()


if __name__ == "__main__":
    print("🏋️ Fitness Coach Management Tool")
    print("=" * 40)

    if len(sys.argv) > 1:
        command = sys.argv[1].lower()

        if command == "create":
            create_test_coach()
        elif command == "list":
            list_coaches()
        elif command == "test":
            test_authentication()
        else:
            print(f"Unknown command: {command}")
    else:
        # Default: create test coach
        create_test_coach()
        list_coaches()
        test_authentication()

    print("\n✅ Done!")
