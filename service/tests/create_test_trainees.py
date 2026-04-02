#!/usr/bin/env python3

import os
import sys
from pathlib import Path
from faker import Faker
import random

# Add the app directory to Python path
current_dir = Path(__file__).parent.parent
sys.path.insert(0, str(current_dir))

from app.db.session import SessionLocal
from app.services.trainee_service import TraineeService
from app.schemas.trainees import TraineeCreate


def create_test_trainees(count: int = 20):
    """Create test trainees with realistic data"""

    print(f"👥 Creating {count} Test Trainees")
    print("=" * 50)

    fake = Faker("en_US")  # English names for international customer
    db = SessionLocal()
    trainee_service = TraineeService(db)

    # Fitness goals and interests
    fitness_goals = [
        "Weight loss",
        "Muscle gain",
        "Endurance",
        "Flexibility",
        "Strength training",
        "Cardio fitness",
        "General health",
        "Rehabilitation",
        "Sports training",
        "Stress relief",
    ]

    sports_interests = [
        "Running",
        "Swimming",
        "Cycling",
        "Yoga",
        "Pilates",
        "Basketball",
        "Football",
        "Tennis",
        "Boxing",
        "CrossFit",
    ]

    created_trainees = []

    try:
        for i in range(count):
            # Generate realistic trainee data
            first_name = fake.first_name()
            last_name = fake.last_name()
            email = f"{first_name.lower()}.{last_name.lower()}@test.com"

            trainee_data = TraineeCreate(
                email=email,
                password=f"test{i+1:03d}",  # Move password here
                first_name=first_name,
                last_name=last_name,
                mobile_phone=fake.phone_number()[:15],  # Limit length
                address1=fake.street_address(),
                city=fake.city(),
                state=(
                    fake.state_abbr()
                    if fake.random_element(["US", "CA"]) == "US"
                    else fake.random_element(["ON", "BC", "AB"])
                ),
                postal_code=fake.postcode(),
                country=fake.random_element(["USA", "Canada", "Ukraine"]),
                gender=fake.random_element(["Male", "Female", "Other"]),
                notes=f"Test trainee #{i+1}. Interested in {fake.random_element(sports_interests)}. Goals: {fake.random_element(fitness_goals)}.",
            )

            # Password is now included in trainee_data
            password = f"test{i+1:03d}"  # test001, test002, etc.

            try:
                trainee = trainee_service.create_trainee(trainee_data)
                created_trainees.append(
                    {
                        "id": trainee.id,
                        "email": trainee.email,
                        "name": f"{trainee.first_name} {trainee.last_name}",
                        "password": password,
                    }
                )
                print(f"   ✅ Created: {trainee.email} (ID: {trainee.id})")

            except Exception as e:
                print(f"   ❌ Failed to create {email}: {e}")

    except Exception as e:
        print(f"❌ Error during trainee creation: {e}")
    finally:
        db.close()

    print(f"\n🎉 Created {len(created_trainees)} test trainees!")

    # Save credentials to file for easy access
    if created_trainees:
        save_credentials(created_trainees)

    return created_trainees


def save_credentials(trainees):
    """Save trainee credentials to a file"""

    credentials_file = Path(__file__).parent / "test_trainees_credentials.txt"

    with open(credentials_file, "w") as f:
        f.write("# Test Trainees Credentials\n")
        f.write("# Format: Email | Password | Name\n")
        f.write("=" * 60 + "\n\n")

        for trainee in trainees:
            f.write(f"{trainee['email']} | {trainee['password']} | {trainee['name']}\n")

    print(f"💾 Credentials saved to: {credentials_file}")


def list_trainees():
    """List all existing trainees"""

    print("👥 Existing Trainees")
    print("=" * 40)

    db = SessionLocal()
    trainee_service = TraineeService(db)

    try:
        trainees = trainee_service.get_trainees(skip=0, limit=100)

        if not trainees:
            print("   No trainees found")
            return

        for trainee in trainees:
            print(
                f"   ID: {trainee.id:2d} | {trainee.email:30s} | {trainee.first_name} {trainee.last_name}"
            )

        print(f"\nTotal: {len(trainees)} trainees")

    except Exception as e:
        print(f"❌ Error listing trainees: {e}")
    finally:
        db.close()


def delete_test_trainees():
    """Delete all test trainees (with @test.com emails)"""

    print("🗑️ Deleting Test Trainees")
    print("=" * 40)

    db = SessionLocal()
    trainee_service = TraineeService(db)

    try:
        trainees = trainee_service.get_trainees(skip=0, limit=1000)
        deleted_count = 0

        for trainee in trainees:
            if trainee.email and "@test.com" in trainee.email:
                try:
                    trainee_service.delete_trainee(trainee.id)
                    print(f"   🗑️ Deleted: {trainee.email}")
                    deleted_count += 1
                except Exception as e:
                    print(f"   ❌ Failed to delete {trainee.email}: {e}")

        print(f"\n🎉 Deleted {deleted_count} test trainees!")

    except Exception as e:
        print(f"❌ Error deleting test trainees: {e}")
    finally:
        db.close()


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print(
            "  python tests/create_test_trainees.py create [count]    # Create test trainees"
        )
        print(
            "  python tests/create_test_trainees.py list              # List existing trainees"
        )
        print(
            "  python tests/create_test_trainees.py delete            # Delete test trainees"
        )
        return

    command = sys.argv[1].lower()

    if command == "create":
        count = int(sys.argv[2]) if len(sys.argv) > 2 else 20
        create_test_trainees(count)
    elif command == "list":
        list_trainees()
    elif command == "delete":
        delete_test_trainees()
    else:
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()
