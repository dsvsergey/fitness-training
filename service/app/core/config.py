from distutils.util import strtobool
import logging
import os
from pathlib import Path
from dotenv import load_dotenv
from fastapi_mail import ConnectionConfig


logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).resolve().parent.parent
env_path = BASE_DIR.parent / ".env"
load_dotenv(env_path)

# JWT settings
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-for-jwt")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "11520"))


class Settings:
    PROJECT_TITLE: str = "Fitness backend"
    PROJECT_VERSION: str = "0.0.1"

    def __init__(self):
        # Check if DATABASE_URL is provided directly
        database_url = os.getenv("DATABASE_URL")
        if database_url:
            # Use DATABASE_URL directly, but ensure it uses psycopg2
            if database_url.startswith("postgresql://"):
                self.DATABASE_URL = database_url.replace(
                    "postgresql://", "postgresql+psycopg2://", 1
                )
            else:
                self.DATABASE_URL = database_url
        else:
            # Fallback to individual variables
            self.DB_USERNAME: str = os.getenv("DB_USERNAME")
            self.DB_PASSWORD: str = os.getenv("DB_PASSWORD")
            self.DB_HOST: str = os.getenv("DB_HOST", "localhost")
            self.DB_PORT: str = os.getenv("DB_PORT", "5432")
            self.DB_NAME: str = os.getenv("DB_NAME")
            self.DATABASE_URL: str = (
                f"postgresql+psycopg2://{self.DB_USERNAME}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
            )

        self.SECRET_KEY = os.getenv(
            "SECRET_KEY", "your-super-secret-key-change-in-production"
        )
        self.JWT_SECRET = os.getenv("JWT_SECRET", self.SECRET_KEY)
        self.JWT_ALGORITHM = "HS256"
        self.ACCESS_TOKEN_EXPIRE_MINUTES = int(
            os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "11520")
        )
        self.ACCESS_TOKEN_EXPIRE_MINUTES_LONG = int(
            os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES_LONG", "43200")  # 30 days
        )

        # Google OAuth
        self.GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID", "")
        self.GOOGLE_CLIENT_SECRET = os.getenv("GOOGLE_CLIENT_SECRET", "")
        self.GOOGLE_REDIRECT_URI = os.getenv(
            "GOOGLE_REDIRECT_URI",
            "http://localhost:8000/api/v1/auth/google/callback",
        )

        # Frontend URL (used in Google OAuth redirect and password reset links)
        self.FRONTEND_URL = os.getenv("FRONTEND_URL", "http://localhost:3000")

        # API base URL (used in email verification links — points directly to the API)
        self.API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

        self.ADMIN_EMAIL = os.getenv("ADMIN_EMAIL")

        self.SUPPRESS_SENDING_EMAILS = strtobool(
            os.getenv("SUPPRESS_SENDING_EMAILS", "False")
        )
        self.MAIL_USERNAME = os.getenv("MAIL_USERNAME")
        self.MAIL_PASSWORD = os.getenv("MAIL_PASSWORD")
        self.MAIL_FROM = os.getenv("MAIL_FROM")
        self.MAIL_PORT = int(os.getenv("MAIL_PORT", "587"))
        self.MAIL_SERVER = os.getenv("MAIL_SERVER")
        self.MAIL_FROM_NAME = os.getenv("MAIL_FROM_NAME")
        self.MAIL_STARTTLS = strtobool(os.getenv("MAIL_STARTTLS", "False"))
        self.MAIL_SSL_TLS = strtobool(os.getenv("MAIL_SSL_TLS", "False"))
        self.MAIL_TLS = strtobool(os.getenv("MAIL_TLS", "True"))
        self.MAIL_SSL = strtobool(os.getenv("MAIL_SSL", "False"))
        self.MAIL_USE_CREDENTIALS = strtobool(os.getenv("MAIL_USE_CREDENTIALS", "True"))
        self.MAIL_VALIDATE_CERTS = strtobool(os.getenv("MAIL_VALIDATE_CERTS", "False"))

        self.SECRET = os.getenv("SECRET", "1234")
        self.AUTH0_CLIENT_ID = os.getenv("AUTH0_CLIENT_ID", "fitness-api-01")
        self.AUTH0_CLIENT_SECRET = os.getenv(
            "AUTH0_CLIENT_SECRET", "fitness-api-secret-01"
        )
        self.AUTH0_DOMAIN = os.getenv("AUTH0_DOMAIN", "http://127.0.0.1:8000")

        self.email_conf = ConnectionConfig(
            MAIL_USERNAME=self.MAIL_USERNAME,
            MAIL_PASSWORD=self.MAIL_PASSWORD,
            MAIL_FROM=self.MAIL_FROM,
            MAIL_PORT=self.MAIL_PORT,
            MAIL_SERVER=self.MAIL_SERVER,
            MAIL_FROM_NAME=self.MAIL_FROM_NAME,
            MAIL_SSL_TLS=self.MAIL_SSL_TLS,
            USE_CREDENTIALS=self.MAIL_USE_CREDENTIALS,
            VALIDATE_CERTS=self.MAIL_VALIDATE_CERTS,
            MAIL_STARTTLS=True,
        )

        self.REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")

        self.ADMIN: str = os.getenv("ADMIN", "admin")
        self.PWR: str = os.getenv("PWR", "pwr")

        # API settings
        self.API_V1_STR = "/api/v1"

        # CORS settings
        self.BACKEND_CORS_ORIGINS = [
            "http://localhost",
            "http://localhost:8080",
            "http://localhost:3000",
            "http://localhost:8000",
        ]


# Create global settings instance
settings = Settings()
