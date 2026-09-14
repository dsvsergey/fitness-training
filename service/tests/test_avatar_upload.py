"""Unit tests for coach avatar storage.

Run: pytest tests/test_avatar_upload.py
Requires pytest and pytest-asyncio, which — like pytest itself for the other
test modules here — are not listed in requirements.txt: `pip install pytest
pytest-asyncio`.

No database or network required — these cover the pure helpers in
app/services/avatar_storage.py that validate and place uploaded images.
"""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.core.config import settings  # noqa: E402
from app.services import avatar_storage  # noqa: E402

# Minimal byte sequences carrying each format's magic number. Real image
# payloads are unnecessary: the validator reads only the header.
JPEG = b"\xff\xd8\xff" + b"\x00" * 32
PNG = b"\x89PNG\r\n\x1a\n" + b"\x00" * 32
WEBP = b"RIFF" + b"\x00\x00\x00\x00" + b"WEBP" + b"\x00" * 32
NOT_AN_IMAGE = b"MZ\x90\x00" + b"\x00" * 32


@pytest.fixture(autouse=True)
def media_root(tmp_path, monkeypatch):
    monkeypatch.setattr(settings, "MEDIA_ROOT", str(tmp_path))
    monkeypatch.setattr(settings, "PUBLIC_BASE_URL", "https://api.example.com")
    return tmp_path


class _FakeUpload:
    """Stands in for fastapi.UploadFile — only .read(size) is used."""

    def __init__(self, data: bytes):
        self._data = data
        self._pos = 0

    async def read(self, size: int = -1) -> bytes:
        chunk = self._data[self._pos : self._pos + size]
        self._pos += len(chunk)
        return chunk


@pytest.mark.parametrize(
    "data,extension",
    [(JPEG, "jpg"), (PNG, "png"), (WEBP, "webp")],
)
def test_save_avatar_stores_file_and_returns_absolute_url(data, extension, media_root):
    url = avatar_storage.save_avatar(42, data)

    assert url.startswith("https://api.example.com/media/avatars/coach_42_")
    assert url.endswith(f".{extension}")
    stored = media_root / "avatars" / url.rsplit("/", 1)[1]
    assert stored.read_bytes() == data


def test_save_avatar_rejects_non_image_payload():
    with pytest.raises(avatar_storage.AvatarValidationError):
        avatar_storage.save_avatar(42, NOT_AN_IMAGE)


def test_save_avatar_rejects_empty_payload():
    with pytest.raises(avatar_storage.AvatarValidationError):
        avatar_storage.save_avatar(42, b"")


def test_save_avatar_generates_a_distinct_name_each_time():
    first = avatar_storage.save_avatar(42, PNG)
    second = avatar_storage.save_avatar(42, PNG)

    assert first != second


def test_delete_avatar_removes_a_file_we_wrote(media_root):
    url = avatar_storage.save_avatar(42, PNG)
    stored = media_root / "avatars" / url.rsplit("/", 1)[1]
    assert stored.exists()

    avatar_storage.delete_avatar(url)

    assert not stored.exists()


def test_delete_avatar_ignores_a_missing_file(media_root):
    avatar_storage.delete_avatar(
        "https://api.example.com/media/avatars/coach_42_deadbeef.png"
    )


def test_delete_avatar_ignores_urls_we_did_not_write(media_root):
    # Google OAuth stores its own picture URL in the same column.
    avatar_storage.delete_avatar("https://lh3.googleusercontent.com/a/xyz=s96-c")


def test_delete_avatar_ignores_none():
    avatar_storage.delete_avatar(None)


@pytest.mark.asyncio
async def test_read_upload_returns_the_whole_payload():
    assert await avatar_storage.read_upload(_FakeUpload(PNG)) == PNG


@pytest.mark.asyncio
async def test_read_upload_rejects_oversized_payload():
    oversized = _FakeUpload(
        b"\x89PNG\r\n\x1a\n" + b"\x00" * avatar_storage.MAX_AVATAR_BYTES
    )

    with pytest.raises(avatar_storage.AvatarValidationError):
        await avatar_storage.read_upload(oversized)
