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


def get_google_authorize_url(role: str = "trainee", client: str = "web") -> str:
    """Build Google OAuth authorization URL.

    `role` and `client` are embedded in the signed state so the callback knows
    what kind of account to create and where to hand the JWT back to
    (`web` -> FRONTEND_URL, `mobile` -> the app's deep-link scheme).
    """
    state = _get_serializer().dumps({"role": role, "client": client})
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


def build_success_redirect(client: str, jwt: str, user_sub: str) -> str | None:
    """Where to hand the freshly minted JWT back to, or None to return JSON.

    `mobile` -> the app's deep-link scheme (external browser session).
    `web`    -> FRONTEND_URL, unless it is still the unconfigured default.
    """
    query = urlencode({"token": jwt, "sub": user_sub})

    if client == "mobile" and settings.GOOGLE_MOBILE_REDIRECT_URI:
        target = settings.GOOGLE_MOBILE_REDIRECT_URI
        separator = "&" if "?" in target else "?"
        return f"{target}{separator}{query}"

    if settings.FRONTEND_URL and settings.FRONTEND_URL != "http://localhost:3000":
        return f"{settings.FRONTEND_URL}/auth/callback?{query}"

    return None
