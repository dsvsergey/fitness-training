#!/usr/bin/env python3

import os
import sys
from pathlib import Path
from faker import Faker
import random
from datetime import datetime, timedelta, time as dt_time

# Add the app directory to Python path
current_dir = Path(__file__).parent.parent
sys.path.insert(0, str(current_dir))

from app.db.session import SessionLocal
from app.crud.workout_appointment import create_workout_appointment
from app.schemas.workout_appointment import WorkoutAppointmentSchema
from app.services.trainee_service import TraineeService
from app.services.coach_service import CoachService


def generate_fake_schedule(days_ahead: int = 30, appointments_per_day: int = 8):
    """Generate fake workout schedule for testing"""

    print(f"📅 Generating Fake Workout Schedule")
    print(f"   Days ahead: {days_ahead}")
    print(f"   Appointments per day: {appointments_per_day}")
    print("=" * 60)

    fake = Faker("en_US")  # English for international customer
    db = SessionLocal()

    # Get available trainees and coaches
    trainee_service = TraineeService(db)
    coach_service = CoachService(db)

    trainees = trainee_service.get_trainees(skip=0, limit=1000)
    coaches = coach_service.get_coaches(skip=0, limit=100)

    if not trainees:
        print("❌ No trainees found. Create test trainees first!")
        db.close()
        return

    if not coaches:
        print("❌ No coaches found. Create test coaches first!")
        db.close()
        return

    print(f"👥 Found {len(trainees)} trainees and {len(coaches)} coaches")

    # Workout types and durations
    workout_types = [
        ("Personal Training", 60),
        ("Group Fitness", 45),
        ("Yoga Session", 75),
        ("HIIT Training", 30),
        ("Strength Training", 90),
        ("Cardio Session", 45),
        ("Pilates", 60),
        ("CrossFit", 60),
        ("Swimming Lesson", 45),
        ("Nutrition Consultation", 30),
    ]

    # Time slots during the day
    time_slots = [
        dt_time(6, 0),  # 6:00 AM
        dt_time(7, 30),  # 7:30 AM
        dt_time(9, 0),  # 9:00 AM
        dt_time(10, 30),  # 10:30 AM
        dt_time(12, 0),  # 12:00 PM
        dt_time(14, 0),  # 2:00 PM
        dt_time(15, 30),  # 3:30 PM
        dt_time(17, 0),  # 5:00 PM
        dt_time(18, 30),  # 6:30 PM
        dt_time(20, 0),  # 8:00 PM
    ]

    created_appointments = []

    try:
        for day_offset in range(days_ahead):
            current_date = datetime.now().date() + timedelta(days=day_offset)

            # Skip weekends occasionally
            if current_date.weekday() >= 5 and random.random() < 0.3:
                continue

            daily_appointments = random.randint(
                max(1, appointments_per_day - 3), appointments_per_day + 2
            )

            used_time_slots = set()

            for _ in range(daily_appointments):
                # Select unique time slot
                available_slots = [
                    slot for slot in time_slots if slot not in used_time_slots
                ]
                if not available_slots:
                    break

                appointment_time = random.choice(available_slots)
                used_time_slots.add(appointment_time)

                # Combine date and time
                appointment_datetime = datetime.combine(current_date, appointment_time)

                # Select workout type and duration
                workout_type, duration = random.choice(workout_types)
                end_datetime = appointment_datetime + timedelta(minutes=duration)

                # Select random trainee and coach
                trainee = random.choice(trainees)
                coach = random.choice(coaches)

                # Create appointment
                appointment_data = WorkoutAppointmentSchema(
                    mindbody_id=None,  # No MindBody ID for local test data
                    trainee_id=trainee.id,
                    coach_id=coach.id,
                    duration=duration,
                    status=random.choice(
                        ["Booked", "Completed", "Confirmed", "Cancelled"]
                    ),
                    start_at=appointment_datetime,
                    end_at=end_datetime,
                    notes=fake.sentence(nb_words=random.randint(5, 15)),
                )

                try:
                    appointment = create_workout_appointment(
                        db=db, appointment=appointment_data
                    )
                    created_appointments.append(appointment)

                    print(
                        f"   ✅ {current_date} {appointment_time.strftime('%H:%M')} - {workout_type} - {trainee.first_name} {trainee.last_name}"
                    )

                except Exception as e:
                    print(f"   ❌ Failed to create appointment: {e}")

            if day_offset % 7 == 0:  # Progress update every week
                print(f"   📅 Completed week {day_offset // 7 + 1}")

    except Exception as e:
        print(f"❌ Error generating schedule: {e}")
    finally:
        db.close()

    print(f"\n🎉 Generated {len(created_appointments)} fake appointments!")
    return created_appointments


def clear_fake_appointments():
    """Clear all existing workout appointments"""

    print("🗑️ Clearing All Workout Appointments")
    print("=" * 50)

    db = SessionLocal()

    try:
        from app.crud.workout_appointment import (
            get_all_workout_appointments,
            delete_workout_appointment,
        )

        # Get all appointments
        appointments = get_all_workout_appointments(db, skip=0, limit=10000)

        if not appointments:
            print("   No appointments found to delete")
            return

        deleted_count = 0
        for appointment in appointments:
            try:
                delete_workout_appointment(db, appointment_id=appointment.id)
                deleted_count += 1
            except Exception as e:
                print(f"   ❌ Failed to delete appointment {appointment.id}: {e}")

        print(f"🎉 Deleted {deleted_count} appointments!")

    except Exception as e:
        print(f"❌ Error clearing appointments: {e}")
    finally:
        db.close()


def show_schedule_stats():
    """Show statistics of current schedule"""

    print("📊 Schedule Statistics")
    print("=" * 40)

    db = SessionLocal()

    try:
        from app.crud.workout_appointment import get_all_workout_appointments

        appointments = get_all_workout_appointments(db, skip=0, limit=10000)

        if not appointments:
            print("   No appointments found")
            return

        # Group by status
        status_count = {}
        workout_type_count = {}
        coach_count = {}

        for appointment in appointments:
            # Count by status
            status = appointment.status or "Unknown"
            status_count[status] = status_count.get(status, 0) + 1

            # Count by workout type
            workout_type = appointment.workout_type or "Unknown"
            workout_type_count[workout_type] = (
                workout_type_count.get(workout_type, 0) + 1
            )

            # Count by coach
            coach_id = appointment.coach_id
            coach_count[coach_id] = coach_count.get(coach_id, 0) + 1

        print(f"Total appointments: {len(appointments)}")
        print("\nBy Status:")
        for status, count in sorted(status_count.items()):
            print(f"   {status}: {count}")

        print("\nBy Workout Type:")
        for workout_type, count in sorted(
            workout_type_count.items(), key=lambda x: x[1], reverse=True
        ):
            print(f"   {workout_type}: {count}")

        print(f"\nCoaches involved: {len(coach_count)}")

        # Date range
        dates = [
            appointment.start_time.date()
            for appointment in appointments
            if appointment.start_time
        ]
        if dates:
            min_date = min(dates)
            max_date = max(dates)
            print(f"Date range: {min_date} to {max_date}")

    except Exception as e:
        print(f"❌ Error getting statistics: {e}")
    finally:
        db.close()


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print(
            "  python tests/create_fake_schedule.py generate [days] [per_day]  # Generate fake schedule"
        )
        print(
            "  python tests/create_fake_schedule.py clear                      # Clear all appointments"
        )
        print(
            "  python tests/create_fake_schedule.py stats                      # Show schedule statistics"
        )
        print("\nDefaults: 30 days, 8 appointments per day")
        return

    command = sys.argv[1].lower()

    if command == "generate":
        days = int(sys.argv[2]) if len(sys.argv) > 2 else 30
        per_day = int(sys.argv[3]) if len(sys.argv) > 3 else 8
        generate_fake_schedule(days_ahead=days, appointments_per_day=per_day)
    elif command == "clear":
        clear_fake_appointments()
    elif command == "stats":
        show_schedule_stats()
    else:
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()
