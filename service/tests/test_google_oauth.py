"""Unit tests for the Google OAuth state + redirect handling.

Run: pytest tests/test_google_oauth.py
No database or network required — these cover the pure helpers in
app/core/oauth.py that decide where the JWT is handed back to.
"""
import sys
from pathlib import Path
from urllib.parse import parse_qs, urlparse

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.core import oauth  # noqa: E402
from app.core.config import settings  # noqa: E402


def test_state_round_trip_carries_role_and_client():
    settings.GOOGLE_CLIENT_ID = "test-client-id"
    url = oauth.get_google_authorize_url(role="coach", client="mobile")

    state = parse_qs(urlparse(url).query)["state"][0]
    assert oauth.verify_google_state(state) == {"role": "coach", "client": "mobile"}


def test_authorize_url_uses_configured_redirect_uri(monkeypatch):
    monkeypatch.setattr(settings, "GOOGLE_REDIRECT_URI", "https://api.example.com/api/v1/google/callback")
    url = oauth.get_google_authorize_url(role="coach", client="web")

    assert parse_qs(urlparse(url).query)["redirect_uri"] == [
        "https://api.example.com/api/v1/google/callback"
    ]


def test_mobile_client_redirects_to_deep_link(monkeypatch):
    monkeypatch.setattr(settings, "GOOGLE_MOBILE_REDIRECT_URI", "fitnesscoach://auth/callback")
    monkeypatch.setattr(settings, "FRONTEND_URL", "https://app.example.com")

    target = oauth.build_success_redirect("mobile", "jwt-123", "coach:7")

    assert target.startswith("fitnesscoach://auth/callback?")
    query = parse_qs(urlparse(target).query)
    assert query == {"token": ["jwt-123"], "sub": ["coach:7"]}


def test_mobile_deep_link_with_existing_query_appends(monkeypatch):
    monkeypatch.setattr(settings, "GOOGLE_MOBILE_REDIRECT_URI", "fitnesscoach://auth/callback?src=google")

    target = oauth.build_success_redirect("mobile", "jwt-123", "coach:7")

    query = parse_qs(urlparse(target).query)
    assert query == {"src": ["google"], "token": ["jwt-123"], "sub": ["coach:7"]}


def test_web_client_redirects_to_frontend(monkeypatch):
    monkeypatch.setattr(settings, "FRONTEND_URL", "https://app.example.com")

    target = oauth.build_success_redirect("web", "jwt-123", "coach:7")

    assert target.startswith("https://app.example.com/auth/callback?")


def test_web_client_without_frontend_returns_none(monkeypatch):
    """Unconfigured FRONTEND_URL -> the callback answers with JSON instead."""
    monkeypatch.setattr(settings, "FRONTEND_URL", "http://localhost:3000")

    assert oauth.build_success_redirect("web", "jwt-123", "coach:7") is None


def test_tampered_state_is_rejected():
    with pytest.raises(ValueError):
        oauth.verify_google_state("not-a-signed-state")
