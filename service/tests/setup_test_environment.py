#!/usr/bin/env python3

"""
Master script for setting up test environment for customer testing.

This script will:
1. Create test trainees
2. Generate fake workout schedule
3. Provide status overview

MindBody synchronization is disabled in celery_worker.py for testing.
"""

import os
import sys
from pathlib import Path

# Add the app directory to Python path
current_dir = Path(__file__).parent.parent
sys.path.insert(0, str(current_dir))

from create_test_trainees import (
    create_test_trainees,
    list_trainees,
    delete_test_trainees,
)
from create_fake_schedule import (
    generate_fake_schedule,
    show_schedule_stats,
    clear_fake_appointments,
)


def setup_complete_test_environment():
    """Set up complete test environment for customer demo"""

    print("🎯 Setting Up Complete Test Environment")
    print("=" * 60)
    print("This will create test data for customer demonstration")
    print("MindBody sync is DISABLED - using local data only")
    print("=" * 60)

    try:
        # Step 1: Create test trainees
        print("\n📋 STEP 1: Creating Test Trainees")
        print("-" * 40)
        trainees = create_test_trainees(count=25)

        if not trainees:
            print("❌ Failed to create trainees. Aborting setup.")
            return False

        # Step 2: Generate fake schedule
        print("\n📅 STEP 2: Generating Fake Schedule")
        print("-" * 40)
        appointments = generate_fake_schedule(days_ahead=14, appointments_per_day=6)

        if not appointments:
            print("❌ Failed to create schedule. Environment partially set up.")
            return False

        # Step 3: Show overview
        print("\n📊 STEP 3: Environment Overview")
        print("-" * 40)
        show_test_environment_status()

        print("\n🎉 TEST ENVIRONMENT READY!")
        print("=" * 60)
        print("✅ Customer can now test the application with realistic data")
        print("✅ MindBody sync is disabled - no external dependencies")
        print("✅ Authentication works with local coaches and trainees")
        print("\nNext steps:")
        print("  • Start the server: uvicorn app.main:app --reload")
        print("  • Use test credentials from tests/test_trainees_credentials.txt")
        print("  • Coach login: Dmitriy.mironyuk@gmail.com / Sonik@9751")

        return True

    except Exception as e:
        print(f"❌ Error setting up test environment: {e}")
        return False


def show_test_environment_status():
    """Show current status of test environment"""

    print("📊 Test Environment Status")
    print("=" * 50)

    # Show trainees count
    print("\n👥 Trainees:")
    list_trainees()

    # Show schedule stats
    print("\n📅 Schedule:")
    show_schedule_stats()

    # Show coaches
    print("\n👨‍💼 Coaches:")
    try:
        from app.db.session import SessionLocal
        from app.services.coach_service import CoachService

        db = SessionLocal()
        coach_service = CoachService(db)
        coaches = coach_service.get_coaches(skip=0, limit=100)

        if coaches:
            for coach in coaches:
                print(
                    f"   ID: {coach.id:2d} | {coach.email:30s} | {coach.first_name} {coach.last_name}"
                )
            print(f"Total: {len(coaches)} coaches")
        else:
            print("   No coaches found")

        db.close()

    except Exception as e:
        print(f"   ❌ Error getting coaches: {e}")

    # Show MindBody sync status
    print("\n🔄 MindBody Sync Status:")
    print("   ⏸️ DISABLED (celery_worker.py tasks commented out)")
    print("   ✅ Local authentication only")
    print("   ✅ No external API dependencies")


def reset_test_environment():
    """Reset test environment by deleting all test data"""

    print("🔄 Resetting Test Environment")
    print("=" * 50)

    try:
        # Delete test trainees
        print("\n🗑️ Deleting test trainees...")
        delete_test_trainees()

        # Clear appointments
        print("\n🗑️ Clearing appointments...")
        clear_fake_appointments()

        print("\n✅ Test environment reset complete!")

    except Exception as e:
        print(f"❌ Error resetting environment: {e}")


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print(
            "  python tests/setup_test_environment.py setup     # Set up complete test environment"
        )
        print(
            "  python tests/setup_test_environment.py status    # Show current status"
        )
        print(
            "  python tests/setup_test_environment.py reset     # Reset/clear all test data"
        )
        print(
            "\nFor customer testing, use 'setup' to create a complete demo environment."
        )
        return

    command = sys.argv[1].lower()

    if command == "setup":
        setup_complete_test_environment()
    elif command == "status":
        show_test_environment_status()
    elif command == "reset":
        reset_test_environment()
    else:
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()
