#!/usr/bin/env python3

import sys
import os
from pathlib import Path

# Add the project root to Python path
current_dir = Path(__file__).parent.parent
sys.path.insert(0, str(current_dir))

try:
    from app.db.session import get_db
    from app.crud.workout_appointment import get_local_filter_workout_appointments
    from app.schemas.workout_appointment import LocalAppointmentFilterRequest

    print("✅ All imports successful!")

    # Test database connection
    print("\n🔗 Testing database connection...")
    db_session = next(get_db())
    print(f"✅ Database session created: {type(db_session)}")

    # Test basic query
    print("\n📊 Testing basic function...")
    filter_request = LocalAppointmentFilterRequest()

    try:
        appointments = get_local_filter_workout_appointments(
            db=db_session, current_user="test", skip=0, limit=10, filter=filter_request
        )
        print(
            f"✅ Function executed successfully! Found {len(appointments)} appointments"
        )

        # Show details if any appointments found
        for i, appointment in enumerate(appointments[:3]):
            print(
                f"   {i+1}. ID: {appointment.id}, Start: {appointment.start_at}, Status: {appointment.status}"
            )

    except Exception as e:
        print(f"❌ Function failed: {e}")
        import traceback

        traceback.print_exc()

    finally:
        db_session.close()
        print("\n✅ Database session closed")

except ImportError as e:
    print(f"❌ Import error: {e}")
    import traceback

    traceback.print_exc()
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback

    traceback.print_exc()
