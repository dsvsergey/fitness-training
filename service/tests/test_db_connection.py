#!/usr/bin/env python3

import sys
from pathlib import Path

# Add the app directory to Python path
current_dir = Path(__file__).parent.parent
sys.path.insert(0, str(current_dir))

from app.db.session import SessionLocal
from sqlalchemy import text


def test_db_connection():
    """Test database connection"""
    try:
        print("🔗 Testing database connection...")
        db = SessionLocal()
        result = db.execute(text("SELECT 1 as test")).fetchone()
        print(f"✅ Database connection successful! Test result: {result}")
        db.close()
        return True
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False


if __name__ == "__main__":
    success = test_db_connection()
    sys.exit(0 if success else 1)
