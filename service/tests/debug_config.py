#!/usr/bin/env python3

import sys
from pathlib import Path

# Add the app directory to Python path
current_dir = Path(__file__).parent.parent
sys.path.insert(0, str(current_dir))

from app.core.config import settings
import os


def debug_config():
    """Debug configuration settings"""
    print("🔧 Configuration Debug")
    print("=" * 50)

    print(f"ENV file path: {Path(__file__).parent.parent / '.env'}")
    print(f"ENV file exists: {(Path(__file__).parent.parent / '.env').exists()}")

    print("\n📊 Environment Variables:")
    print(f"DATABASE_URL: {os.getenv('DATABASE_URL')}")
    print(f"DB_HOST: {os.getenv('DB_HOST')}")
    print(f"DB_PORT: {os.getenv('DB_PORT')}")
    print(f"DB_NAME: {os.getenv('DB_NAME')}")
    print(f"DB_USERNAME: {os.getenv('DB_USERNAME')}")
    print(f"DB_PASSWORD: {os.getenv('DB_PASSWORD')}")

    print("\n⚙️ Settings Object:")
    print(f"settings.DATABASE_URL: {settings.DATABASE_URL}")

    if hasattr(settings, "DB_HOST"):
        print(f"settings.DB_HOST: {settings.DB_HOST}")
        print(f"settings.DB_PORT: {settings.DB_PORT}")
        print(f"settings.DB_NAME: {settings.DB_NAME}")
        print(f"settings.DB_USERNAME: {settings.DB_USERNAME}")


if __name__ == "__main__":
    debug_config()
