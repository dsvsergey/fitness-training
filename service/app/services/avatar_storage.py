"""Local-filesystem storage for avatar images.

Pure helpers: no database access and no request objects, so they can be
unit-tested directly (see tests/test_avatar_upload.py). The caller is
responsible for persisting the returned URL and for removing the previous one.
"""
import os
import uuid
from pathlib import Path
from typing import Optional

from app.core.config import settings

MAX_AVATAR_BYTES = 5 * 1024 * 1024  # 5 MB
_READ_CHUNK = 64 * 1024

# The client-supplied Content-Type is never trusted: an executable renamed to
# .png would otherwise be written into a directory we serve over HTTP.
_JPEG_MAGIC = b"\xff\xd8\xff"
_PNG_MAGIC = b"\x89PNG\r\n\x1a\n"
_WEBP_PREFIX = b"RIFF"
_WEBP_TAG = b"WEBP"

# Each owner gets its own filename prefix, so a coach and a trainee that
# happen to share an id never overwrite one another, and cleanup can tell
# which avatars are ours.
COACH_PREFIX = "coach_"
TRAINEE_PREFIX = "trainee_"
_FILENAME_PREFIXES = (COACH_PREFIX, TRAINEE_PREFIX)


class AvatarValidationError(ValueError):
    """Raised when an uploaded file is not an acceptable avatar image."""


def detect_extension(data: bytes) -> str:
    """Return the file extension implied by `data`'s magic bytes."""
    if data.startswith(_JPEG_MAGIC):
        return "jpg"
    if data.startswith(_PNG_MAGIC):
        return "png"
    if data[:4] == _WEBP_PREFIX and data[8:12] == _WEBP_TAG:
        return "webp"
    raise AvatarValidationError("Unsupported image format. Use JPEG, PNG or WebP.")


def avatar_dir() -> Path:
    path = Path(settings.MEDIA_ROOT) / "avatars"
    path.mkdir(parents=True, exist_ok=True)
    return path


async def read_upload(upload, limit: int = MAX_AVATAR_BYTES) -> bytes:
    """Read an UploadFile, aborting as soon as it grows past `limit`."""
    chunks = []
    total = 0
    while True:
        chunk = await upload.read(_READ_CHUNK)
        if not chunk:
            break
        total += len(chunk)
        if total > limit:
            raise AvatarValidationError("Image is too large. Maximum size is 5 MB.")
        chunks.append(chunk)
    return b"".join(chunks)


def save_avatar(owner_id: int, data: bytes, prefix: str = COACH_PREFIX) -> str:
    """Validate `data`, write it to the media directory, return its public URL."""
    if not data:
        raise AvatarValidationError("Uploaded file is empty.")
    if len(data) > MAX_AVATAR_BYTES:
        raise AvatarValidationError("Image is too large. Maximum size is 5 MB.")

    extension = detect_extension(data)
    filename = f"{prefix}{owner_id}_{uuid.uuid4().hex}.{extension}"
    (avatar_dir() / filename).write_bytes(data)
    return f"{settings.PUBLIC_BASE_URL.rstrip('/')}/media/avatars/{filename}"


def delete_avatar(image_url: Optional[str]) -> None:
    """Best-effort removal of a previously stored avatar.

    Ignores URLs this module did not write (the Google OAuth `picture` URL and
    Mindbody client photos live in the same columns) and files that are already
    gone — neither should fail the request that triggered the cleanup.
    """
    if not image_url:
        return

    filename = os.path.basename(image_url.split("?")[0])
    if not filename.startswith(_FILENAME_PREFIXES):
        return

    try:
        (avatar_dir() / filename).unlink()
    except OSError:
        pass
