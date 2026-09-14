"""Unit tests for trainee avatar storage.

Run: pytest tests/test_trainee_avatar.py
Same requirements as tests/test_avatar_upload.py: `pip install pytest
pytest-asyncio`, no database or network.

Coach avatars are covered by tests/test_avatar_upload.py. These cover what
sharing app/services/avatar_storage.py between the two owners has to get
right: each owner's files carry their own prefix, and cleanup recognises
both without ever touching a URL we did not write.
"""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.core.config import settings  # noqa: E402
from app.models.trainees import Trainee  # noqa: E402
from app.services import avatar_storage  # noqa: E402
from app.services.trainee_service import TraineeService  # noqa: E402

PNG = b"\x89PNG\r\n\x1a\n" + b"\x00" * 32
JPEG = b"\xff\xd8\xff" + b"\x00" * 32
NOT_AN_IMAGE = b"MZ\x90\x00" + b"\x00" * 32


@pytest.fixture(autouse=True)
def media_root(tmp_path, monkeypatch):
    monkeypatch.setattr(settings, "MEDIA_ROOT", str(tmp_path))
    monkeypatch.setattr(settings, "PUBLIC_BASE_URL", "https://api.example.com")
    return tmp_path


def _save_trainee(trainee_id, data):
    return avatar_storage.save_avatar(
        trainee_id, data, prefix=avatar_storage.TRAINEE_PREFIX
    )


@pytest.mark.parametrize("data,extension", [(JPEG, "jpg"), (PNG, "png")])
def test_save_avatar_stores_trainee_file_and_returns_absolute_url(
    data, extension, media_root
):
    url = _save_trainee(7, data)

    assert url.startswith("https://api.example.com/media/avatars/trainee_7_")
    assert url.endswith(f".{extension}")
    stored = media_root / "avatars" / url.rsplit("/", 1)[1]
    assert stored.read_bytes() == data


def test_save_avatar_still_defaults_to_the_coach_prefix():
    assert avatar_storage.save_avatar(7, PNG).rsplit("/", 1)[1].startswith("coach_")


def test_a_trainee_and_a_coach_with_the_same_id_do_not_collide(media_root):
    trainee_url = _save_trainee(7, PNG)
    coach_url = avatar_storage.save_avatar(7, PNG)

    assert trainee_url != coach_url
    assert (media_root / "avatars" / trainee_url.rsplit("/", 1)[1]).exists()
    assert (media_root / "avatars" / coach_url.rsplit("/", 1)[1]).exists()


def test_save_avatar_rejects_non_image_payload():
    with pytest.raises(avatar_storage.AvatarValidationError):
        _save_trainee(7, NOT_AN_IMAGE)


def test_save_avatar_rejects_empty_payload():
    with pytest.raises(avatar_storage.AvatarValidationError):
        _save_trainee(7, b"")


def test_delete_avatar_removes_a_trainee_file_we_wrote(media_root):
    url = _save_trainee(7, PNG)
    stored = media_root / "avatars" / url.rsplit("/", 1)[1]
    assert stored.exists()

    avatar_storage.delete_avatar(url)

    assert not stored.exists()


def test_deleting_a_trainee_avatar_leaves_the_coach_avatar_alone(media_root):
    trainee_url = _save_trainee(7, PNG)
    coach_url = avatar_storage.save_avatar(7, PNG)

    avatar_storage.delete_avatar(trainee_url)

    assert (media_root / "avatars" / coach_url.rsplit("/", 1)[1]).exists()


def test_delete_avatar_ignores_a_missing_trainee_file(media_root):
    avatar_storage.delete_avatar(
        "https://api.example.com/media/avatars/trainee_7_deadbeef.png"
    )


def test_delete_avatar_still_ignores_urls_we_did_not_write(media_root):
    # A Mindbody client photo can land in the same column.
    avatar_storage.delete_avatar("https://clients.mindbodyonline.com/photo/7.jpg")


# ---------------------------------------------------------------------------
# Deleting a trainee must take its avatar file with it, or the media directory
# accumulates files nothing can ever reference again.
# ---------------------------------------------------------------------------


class _FakeQuery:
    def __init__(self, result):
        self._result = result

    def filter(self, *args, **kwargs):
        return self

    def first(self):
        return self._result


class _FakeSession:
    """Just enough Session for get_trainee/delete_trainee."""

    def __init__(self, trainee):
        self._trainee = trainee
        self.deleted = []
        self.commits = 0

    def query(self, model):
        return _FakeQuery(self._trainee)

    def delete(self, obj):
        self.deleted.append(obj)

    def commit(self):
        self.commits += 1


def test_deleting_a_trainee_removes_its_avatar_file(media_root):
    url = _save_trainee(7, PNG)
    stored = media_root / "avatars" / url.rsplit("/", 1)[1]
    trainee = Trainee(id=7, photo_url=url)
    session = _FakeSession(trainee)

    assert TraineeService(db=session).delete_trainee(7) is True

    assert session.deleted == [trainee]
    assert not stored.exists()


def test_deleting_a_trainee_without_an_avatar_still_succeeds():
    session = _FakeSession(Trainee(id=7, photo_url=None))

    assert TraineeService(db=session).delete_trainee(7) is True


def test_deleting_a_missing_trainee_touches_nothing(media_root):
    url = _save_trainee(7, PNG)
    stored = media_root / "avatars" / url.rsplit("/", 1)[1]
    session = _FakeSession(None)

    assert TraineeService(db=session).delete_trainee(7) is False

    assert session.deleted == []
    assert stored.exists()
