"""Google OAuth2 helpers using httpx and itsdangerous for state signing."""
from urllib.parse import urlencode

import httpx
from itsdangerous import BadSignature, SignatureExpired, URLSafeTimedSerializer

from app.core.config import settings

GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo"


def _get_serializer() -> URLSafeTimedSerializer:
    return URLSafeTimedSerializer(settings.SECRET_KEY)


def get_google_authorize_url(role: str = "trainee") -> str:
    """Build Google OAuth authorization URL. `role` is embedded in state."""
    state = _get_serializer().dumps({"role": role})
    params = {
        "client_id": settings.GOOGLE_CLIENT_ID,
        "redirect_uri": settings.GOOGLE_REDIRECT_URI,
        "response_type": "code",
        "scope": "openid email profile",
        "state": state,
        "access_type": "offline",
        "prompt": "select_account",
    }
    return f"{GOOGLE_AUTH_URL}?{urlencode(params)}"


def verify_google_state(state: str, max_age: int = 600) -> dict:
    """Verify signed state from Google callback. Returns payload dict.

    Raises ValueError on expired or tampered state.
    """
    try:
        return _get_serializer().loads(state, max_age=max_age)
    except SignatureExpired:
        raise ValueError("OAuth state expired. Please try again.")
    except BadSignature:
        raise ValueError("Invalid OAuth state. Please try again.")


async def exchange_google_code(code: str) -> dict:
    """Exchange authorization code for Google tokens."""
    async with httpx.AsyncClient() as client:
        response = await client.post(
            GOOGLE_TOKEN_URL,
            data={
                "code": code,
                "client_id": settings.GOOGLE_CLIENT_ID,
                "client_secret": settings.GOOGLE_CLIENT_SECRET,
                "redirect_uri": settings.GOOGLE_REDIRECT_URI,
                "grant_type": "authorization_code",
            },
        )
        response.raise_for_status()
        return response.json()


async def get_google_user_info(access_token: str) -> dict:
    """Fetch user profile from Google userinfo endpoint."""
    async with httpx.AsyncClient() as client:
        response = await client.get(
            GOOGLE_USERINFO_URL,
            headers={"Authorization": f"Bearer {access_token}"},
        )
        response.raise_for_status()
        return response.json()
