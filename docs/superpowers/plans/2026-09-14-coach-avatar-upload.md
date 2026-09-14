# Coach Avatar Upload Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a coach set, replace, and remove their profile avatar from the Edit Profile screen, with the image stored on the server and visible on every device.

**Architecture:** The FastAPI service gains its first file-upload capability: a pure storage helper module validates and writes images to a media directory on disk, `StaticFiles` serves that directory, and two new endpoints beside the existing `/coaches/me/` handlers own the coach's avatar. The Flutter app gains `image_picker`, turns the currently-inert `ImageUserWidget` into a callback-driven presentational widget, and uploads immediately on pick via new repository/usecase methods.

**Tech Stack:** FastAPI 0.109 + SQLAlchemy 2.0 + Starlette `StaticFiles` (backend); Flutter + Dio + `image_picker` + forui + built_value (client). `python-multipart==0.0.9` is already present — no new backend dependency.

**Spec:** `docs/superpowers/specs/2026-09-14-coach-avatar-upload-design.md`

## Global Constraints

- Accepted image formats: **JPEG, PNG, WebP only**, determined by **magic bytes**, never by the client-supplied `Content-Type`.
- Maximum upload size: **5 MB** (`MAX_AVATAR_BYTES = 5 * 1024 * 1024`), enforced while reading so an oversized body is never buffered whole.
- Stored filename is always server-generated: `coach_{coach_id}_{uuid4hex}.{ext}`. The client-supplied filename is never used.
- `image_url` holds an **absolute** URL (`{PUBLIC_BASE_URL}/media/avatars/{filename}`) — `UserAvatarWidget` uses `NetworkImage` and cannot resolve relative paths.
- `coach_id` is always derived from the JWT subject (`current_user.split(":")[1]`), never from the request body or path.
- Every new `/coaches/me/` endpoint rejects non-coach subjects with **403** and the message `"Coach account required."`, matching its neighbours.
- Every Dio request that sends `FormData` **must** pass `Options(contentType: 'multipart/form-data')` to override the global `application/json` set in `BaseOptions`.
- Avatar bytes cross the repository boundary as `Uint8List`, not a file path — a path would break Flutter web, where `XFile.path` is a blob URL.

---

### Task 1: Backend media config + avatar storage module

Pure helpers with no database access and no request objects, so they unit-test directly. Config lands here because the module reads it.

**Files:**
- Create: `service/app/services/avatar_storage.py`
- Modify: `service/app/core/config.py` (inside `Settings.__init__`, after the Google OAuth block around line 61)
- Test: `service/tests/test_avatar_upload.py`

**Interfaces:**
- Consumes: `settings` from `app.core.config`
- Produces:
  - `MAX_AVATAR_BYTES: int`
  - `AvatarValidationError(ValueError)`
  - `detect_extension(data: bytes) -> str`
  - `avatar_dir() -> Path`
  - `save_avatar(coach_id: int, data: bytes) -> str` (returns absolute URL)
  - `delete_avatar(image_url: Optional[str]) -> None`
  - `async read_upload(upload, limit: int = MAX_AVATAR_BYTES) -> bytes`
  - `settings.MEDIA_ROOT: str`, `settings.PUBLIC_BASE_URL: str`

- [ ] **Step 1: Add the media settings**

In `service/app/core/config.py`, inside `Settings.__init__`, after the Google OAuth lines:

```python
        # Media storage (coach avatars)
        self.MEDIA_ROOT = os.getenv("MEDIA_ROOT", "/app/media")
        self.PUBLIC_BASE_URL = os.getenv(
            "PUBLIC_BASE_URL", "http://localhost:8000"
        ).rstrip("/")
```

- [ ] **Step 2: Write the failing tests**

Create `service/tests/test_avatar_upload.py`:

```python
"""Unit tests for coach avatar storage.

Run: pytest tests/test_avatar_upload.py
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
    oversized = _FakeUpload(b"\x89PNG\r\n\x1a\n" + b"\x00" * avatar_storage.MAX_AVATAR_BYTES)

    with pytest.raises(avatar_storage.AvatarValidationError):
        await avatar_storage.read_upload(oversized)
```

- [ ] **Step 3: Run the tests to verify they fail**

```bash
cd service && pytest tests/test_avatar_upload.py -v
```

Expected: collection error — `ModuleNotFoundError: No module named 'app.services.avatar_storage'`.

If the async tests instead error with `async def functions are not natively supported`, install the plugin and add it to requirements:

```bash
pip install pytest-asyncio
```

Then add `pytest-asyncio==0.23.5` to `service/requirements.txt` and create `service/pytest.ini`:

```ini
[pytest]
asyncio_mode = auto
```

- [ ] **Step 4: Write the implementation**

Create `service/app/services/avatar_storage.py`:

```python
"""Local-filesystem storage for coach avatar images.

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

_FILENAME_PREFIX = "coach_"


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


def save_avatar(coach_id: int, data: bytes) -> str:
    """Validate `data`, write it to the media directory, return its public URL."""
    if not data:
        raise AvatarValidationError("Uploaded file is empty.")
    if len(data) > MAX_AVATAR_BYTES:
        raise AvatarValidationError("Image is too large. Maximum size is 5 MB.")

    extension = detect_extension(data)
    filename = f"{_FILENAME_PREFIX}{coach_id}_{uuid.uuid4().hex}.{extension}"
    (avatar_dir() / filename).write_bytes(data)
    return f"{settings.PUBLIC_BASE_URL.rstrip('/')}/media/avatars/{filename}"


def delete_avatar(image_url: Optional[str]) -> None:
    """Best-effort removal of a previously stored avatar.

    Ignores URLs this module did not write (the Google OAuth `picture` URL
    lives in the same column) and files that are already gone — neither should
    fail the request that triggered the cleanup.
    """
    if not image_url:
        return

    filename = os.path.basename(image_url.split("?")[0])
    if not filename.startswith(_FILENAME_PREFIX):
        return

    try:
        (avatar_dir() / filename).unlink()
    except OSError:
        pass
```

- [ ] **Step 5: Run the tests to verify they pass**

```bash
cd service && pytest tests/test_avatar_upload.py -v
```

Expected: all tests PASS.

- [ ] **Step 6: Commit**

```bash
git add service/app/services/avatar_storage.py service/app/core/config.py service/tests/test_avatar_upload.py
git add service/requirements.txt service/pytest.ini 2>/dev/null || true
git commit -m "feat(service): add coach avatar storage helpers

Validates uploaded images by magic bytes rather than the client-supplied
Content-Type, caps them at 5 MB while reading, and writes them under a
server-generated filename so a client cannot choose where bytes land."
```

---

### Task 2: Backend avatar endpoints + static serving

**Files:**
- Modify: `service/main.py` (mount inside `start_application()`, around line 84 after `include_starlette(app, engine)`)
- Modify: `service/app/api/v1/auth/auth.py` (imports at lines 1-9; new routes after `update_current_coach`, which ends around line 138)
- Modify: `service/.env_src`, `service/.gitignore`, `service/DEPLOYMENT.md`

**Interfaces:**
- Consumes: `avatar_storage.read_upload`, `avatar_storage.save_avatar`, `avatar_storage.delete_avatar`, `avatar_storage.AvatarValidationError`, `settings.MEDIA_ROOT` (Task 1)
- Produces: `POST /api/v1/coaches/me/avatar/` and `DELETE /api/v1/coaches/me/avatar/`, both returning `CoachResponse`

- [ ] **Step 1: Mount the media directory**

In `service/main.py`, inside `start_application()`, immediately after `include_starlette(app, engine)`:

```python
    # Serve uploaded media (coach avatars). StaticFiles is already imported.
    os.makedirs(settings.MEDIA_ROOT, exist_ok=True)
    app.mount(
        "/media",
        StaticFiles(directory=settings.MEDIA_ROOT),
        name="media",
    )
```

`StaticFiles` is already imported at `main.py:7` but unused, so no new import is needed there. Add `import os` at the top of `main.py` if it is not already present.

No nginx change is required: `service/nginx/fitness-api.conf.template` already proxies `location /` to uvicorn and already sets `client_max_body_size 20M`.

- [ ] **Step 2: Add the imports to `auth.py`**

Change the FastAPI import line (`auth.py:6`) to:

```python
from fastapi import APIRouter, Depends, File, HTTPException, Request, UploadFile, status
```

And add, next to the other `app.` imports:

```python
from app.services import avatar_storage
```

- [ ] **Step 3: Add the two endpoints**

In `service/app/api/v1/auth/auth.py`, directly after `update_current_coach` and before `update_coach_password`:

```python
@router.post("/coaches/me/avatar/", response_model=CoachResponse)
async def upload_current_coach_avatar(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
) -> Any:
    """Store an avatar image for the authenticated coach."""
    if not current_user.startswith("coach:"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Coach account required."
        )
    coach_id = int(current_user.split(":")[1])

    coach_service = CoachService(db)
    coach = coach_service.get_coach(coach_id)
    if not coach:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Coach not found"
        )

    previous_url = coach.image_url
    try:
        data = await avatar_storage.read_upload(file)
        image_url = avatar_storage.save_avatar(coach_id, data)
    except avatar_storage.AvatarValidationError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)
        ) from exc

    updated = coach_service.update_coach(coach_id, CoachUpdate(image_url=image_url))
    # Only once the new URL is committed, so a failed write never leaves the
    # coach with a dangling image_url.
    avatar_storage.delete_avatar(previous_url)
    logger.info(f"Avatar updated for coach {coach_id}")
    return updated


@router.delete("/coaches/me/avatar/", response_model=CoachResponse)
async def delete_current_coach_avatar(
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
) -> Any:
    """Remove the authenticated coach's avatar."""
    if not current_user.startswith("coach:"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Coach account required."
        )
    coach_id = int(current_user.split(":")[1])

    coach_service = CoachService(db)
    coach = coach_service.get_coach(coach_id)
    if not coach:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Coach not found"
        )

    previous_url = coach.image_url
    updated = coach_service.update_coach(coach_id, CoachUpdate(image_url=None))
    avatar_storage.delete_avatar(previous_url)
    logger.info(f"Avatar removed for coach {coach_id}")
    return updated
```

`CoachUpdate(image_url=None)` clears the column because `CoachService.update_coach` uses `coach_data.dict(exclude_unset=True)` (`coach_service.py:100`) — a field passed explicitly counts as set even when its value is `None`.

Confirm `CoachService` is already imported in `auth.py`; if not, add `from app.services.coach_service import CoachService`.

- [ ] **Step 4: Verify the app boots and the routes are registered**

```bash
cd service && python -c "
import main
paths = sorted(r.path for r in main.app.routes if 'avatar' in getattr(r, 'path', ''))
print(paths)
assert paths == ['/api/v1/coaches/me/avatar/', '/api/v1/coaches/me/avatar/'], paths
print('routes OK')
"
```

Expected: both routes listed, `routes OK` printed, no import error.

- [ ] **Step 5: Re-run the Task 1 tests to confirm nothing regressed**

```bash
cd service && pytest tests/test_avatar_upload.py tests/test_google_oauth.py -v
```

Expected: all PASS.

- [ ] **Step 6: Document the configuration**

Add to `service/.env_src`:

```
# Media storage for coach avatars. MEDIA_ROOT is a path inside the container;
# PUBLIC_BASE_URL must be the externally reachable origin, because avatar URLs
# are stored absolute in the database.
MEDIA_ROOT=/app/media
PUBLIC_BASE_URL=http://207.126.161.154:8000
```

Add to `service/.gitignore`:

```
media/
```

Add to `service/DEPLOYMENT.md`, under the deployment steps:

```markdown
### Uploaded media

Coach avatars are written to `MEDIA_ROOT` (`/app/media`, which is
`service/media/` on the host via the `.:/app` bind mount) and served at
`/media/avatars/...`. This directory is **not** covered by the database dump —
back it up separately.

`PUBLIC_BASE_URL` must match the origin clients actually reach, because avatar
URLs are stored absolute. If the host or scheme changes, previously stored
`image_url` values will point at the old origin.
```

- [ ] **Step 7: Commit**

```bash
git add service/main.py service/app/api/v1/auth/auth.py service/.env_src service/.gitignore service/DEPLOYMENT.md
git commit -m "feat(service): add coach avatar upload and delete endpoints

POST/DELETE /coaches/me/avatar/ sit beside the other /coaches/me/ handlers,
deriving the coach id from the JWT subject so one coach cannot overwrite
another's image. Uploaded files are served from a newly mounted /media."
```

---

### Task 3: Make `ImageUserWidget` report the chosen action

This is the direct fix for the reported bug — the three dead `onPressed: () {}` handlers — and the test here is its regression guard.

**Files:**
- Modify: `app/lib/presentation/widgets/image_user_widget.dart`
- Modify: `app/pubspec.yaml`
- Test: `app/test/image_user_widget_test.dart`

**Interfaces:**
- Consumes: `AppSvgs.photo`, `AppSvgs.camera`, `AppSvgs.delete`; `SettingsCamersWidget`; `ImageSource` from `package:image_picker/image_picker.dart`
- Produces: `ImageUserWidget({Key? key, required ValueChanged<ImageSource> onSourceSelected, required VoidCallback onDelete, bool hasPhoto = false})`

- [ ] **Step 1: Add the `image_picker` dependency**

In `app/pubspec.yaml`, under `dependencies:` (alongside `dio: ^5.4.1`):

```yaml
  image_picker: ^1.1.2
```

Then:

```bash
cd app && flutter pub get
```

- [ ] **Step 2: Write the failing test**

Create `app/test/image_user_widget_test.dart`:

```dart
// Regression tests for ImageUserWidget.
//
// The bottom sheet's three options were previously declared as
// `onPressed: () {}` — drawn but inert, so a coach could never set an avatar.
// These tests fail against that implementation.

import 'package:fitness_training/presentation/widgets/image_user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';

Future<void> _pumpWidget(
  WidgetTester tester, {
  required ValueChanged<ImageSource> onSourceSelected,
  required VoidCallback onDelete,
  bool hasPhoto = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => FTheme(
        data: FThemes.zinc.light.touch,
        child: child!,
      ),
      home: Scaffold(
        body: Center(
          child: ImageUserWidget(
            onSourceSelected: onSourceSelected,
            onDelete: onDelete,
            hasPhoto: hasPhoto,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.camera_alt));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('gallery option reports ImageSource.gallery', (tester) async {
    final sources = <ImageSource>[];
    await _pumpWidget(
      tester,
      onSourceSelected: sources.add,
      onDelete: () {},
    );

    await _openSheet(tester);
    await tester.tap(find.text('Select from Gallery'));
    await tester.pumpAndSettle();

    expect(sources, [ImageSource.gallery]);
  });

  testWidgets('camera option reports ImageSource.camera', (tester) async {
    final sources = <ImageSource>[];
    await _pumpWidget(
      tester,
      onSourceSelected: sources.add,
      onDelete: () {},
    );

    await _openSheet(tester);
    await tester.tap(find.text('Open Camera'));
    await tester.pumpAndSettle();

    expect(sources, [ImageSource.camera]);
  });

  testWidgets('delete option invokes onDelete when a photo exists',
      (tester) async {
    var deleted = 0;
    await _pumpWidget(
      tester,
      onSourceSelected: (_) {},
      onDelete: () => deleted++,
      hasPhoto: true,
    );

    await _openSheet(tester);
    await tester.tap(find.text('Delete Photo'));
    await tester.pumpAndSettle();

    expect(deleted, 1);
  });

  testWidgets('delete option is hidden when there is no photo', (tester) async {
    await _pumpWidget(
      tester,
      onSourceSelected: (_) {},
      onDelete: () {},
    );

    await _openSheet(tester);

    expect(find.text('Delete Photo'), findsNothing);
    expect(find.text('Select from Gallery'), findsOneWidget);
  });

  testWidgets('choosing an option dismisses the sheet', (tester) async {
    await _pumpWidget(
      tester,
      onSourceSelected: (_) {},
      onDelete: () {},
    );

    await _openSheet(tester);
    await tester.tap(find.text('Select from Gallery'));
    await tester.pumpAndSettle();

    expect(find.text('Select from Gallery'), findsNothing);
  });
}
```

- [ ] **Step 3: Run the test to verify it fails**

```bash
cd app && flutter test test/image_user_widget_test.dart
```

Expected: compile error — `ImageUserWidget` has no named parameters `onSourceSelected`, `onDelete`, `hasPhoto`.

- [ ] **Step 4: Rewrite the widget**

Replace the whole of `app/lib/presentation/widgets/image_user_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/resources/resources.dart';
import 'settings_camers_widget.dart';

/// The camera badge overlaid on a profile avatar.
///
/// Presentational only: it reports which action the user chose and leaves the
/// picking and uploading to its parent, so it stays free of I/O.
class ImageUserWidget extends StatelessWidget {
  const ImageUserWidget({
    super.key,
    required this.onSourceSelected,
    required this.onDelete,
    this.hasPhoto = false,
  });

  final ValueChanged<ImageSource> onSourceSelected;
  final VoidCallback onDelete;

  /// Controls whether the "Delete Photo" option is offered at all.
  final bool hasPhoto;

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      context: context,
      backgroundColor: context.theme.colors.background,
      builder: (sheetCtx) => Container(
        height: hasPhoto ? 250 : 190,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
          color: context.theme.colors.background,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 7,
              decoration: ShapeDecoration(
                color: context.theme.colors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SettingsCamersWidget(
              image: AppSvgs.photo,
              title: "Select from Gallery",
              onPressed: () {
                Navigator.pop(sheetCtx);
                onSourceSelected(ImageSource.gallery);
              },
            ),
            SettingsCamersWidget(
              image: AppSvgs.camera,
              title: "Open Camera",
              onPressed: () {
                Navigator.pop(sheetCtx);
                onSourceSelected(ImageSource.camera);
              },
            ),
            if (hasPhoto)
              SettingsCamersWidget(
                image: AppSvgs.delete,
                title: "Delete Photo",
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  onDelete();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: context.theme.colors.primary,
      child: Center(
        child: IconButton(
          onPressed: () => _showSheet(context),
          icon: Icon(
            Icons.camera_alt,
            color: context.theme.colors.primaryForeground,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run the test to verify it passes**

```bash
cd app && flutter test test/image_user_widget_test.dart
```

Expected: all 5 tests PASS.

The app will not compile yet — `change_info_screen.dart:95` still constructs `const ImageUserWidget()`. That is fixed in Task 5; `flutter test` on this file alone still passes because it compiles only the widget under test.

- [ ] **Step 6: Commit**

```bash
git add app/lib/presentation/widgets/image_user_widget.dart app/pubspec.yaml app/pubspec.lock app/test/image_user_widget_test.dart
git commit -m "fix(app): make ImageUserWidget report the chosen avatar action

All three bottom-sheet options were empty stubs, so the camera badge on the
profile screen did nothing. The widget now reports the chosen source, hides
Delete Photo when there is no photo, and dismisses the sheet before acting."
```

---

### Task 4: Flutter data layer — upload and delete avatar

**Files:**
- Modify: `app/lib/data/repositories/fitness/coach.dart`
- Modify: `app/lib/domain/usecases/fitness/coach_usecase.dart`
- Test: `app/test/coach_repository_avatar_test.dart`

**Interfaces:**
- Consumes: `DioSettingsBackend.dio`, `CoachModel.fromJson`, `FitnessRepository.onException`
- Produces:
  - `CoachRepository.uploadAvatar(Uint8List bytes, String filename) -> Future<CoachModel>`
  - `CoachRepository.deleteAvatar() -> Future<CoachModel>`
  - `CoachUsecase.uploadAvatar(Uint8List bytes, String filename) -> Future<CoachEntity>`
  - `CoachUsecase.deleteAvatar() -> Future<CoachEntity>`

- [ ] **Step 1: Write the failing test**

Create `app/test/coach_repository_avatar_test.dart`:

```dart
// Verifies the avatar upload request shape.
//
// DioSettingsBackend hardcodes `contentType: 'application/json'` in its
// BaseOptions, so a FormData request that does not override it per call is
// mislabelled and rejected by the server. That override is easy to drop during
// a refactor and invisible in review, hence this test.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fitness_training/core/dio_settings/dio_settings_backend.dart';
import 'package:fitness_training/data/repositories/fitness/coach.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString(
      jsonEncode({'id': 1, 'image_url': 'https://api.example.com/media/a.png'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Builds a backend whose interceptors are stripped: the auth interceptor
/// reaches into GetIt for ApplicationBloc, which is not registered in tests.
(DioSettingsBackend, _CapturingAdapter) _backend() {
  final backend = DioSettingsBackend();
  final adapter = _CapturingAdapter();
  backend.dio.interceptors.clear();
  backend.dio.httpClientAdapter = adapter;
  return (backend, adapter);
}

void main() {
  test('uploadAvatar posts multipart form data to /coaches/me/avatar/',
      () async {
    final (backend, adapter) = _backend();
    final repository = CoachRepositoryImpl(fitness: backend);

    await repository.uploadAvatar(
      Uint8List.fromList([1, 2, 3]),
      'avatar.png',
    );

    expect(adapter.captured!.method, 'POST');
    expect(adapter.captured!.path, '/coaches/me/avatar/');
    expect(adapter.captured!.data, isA<FormData>());
    expect(adapter.captured!.contentType, contains('multipart/form-data'));
  });

  test('uploadAvatar sends the bytes under the "file" field', () async {
    final (backend, adapter) = _backend();
    final repository = CoachRepositoryImpl(fitness: backend);

    await repository.uploadAvatar(
      Uint8List.fromList([1, 2, 3]),
      'avatar.png',
    );

    final form = adapter.captured!.data as FormData;
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.filename, 'avatar.png');
  });

  test('uploadAvatar returns the coach parsed from the response', () async {
    final (backend, _) = _backend();
    final repository = CoachRepositoryImpl(fitness: backend);

    final coach = await repository.uploadAvatar(
      Uint8List.fromList([1, 2, 3]),
      'avatar.png',
    );

    expect(coach.imageUrl, 'https://api.example.com/media/a.png');
  });

  test('deleteAvatar sends DELETE to /coaches/me/avatar/', () async {
    final (backend, adapter) = _backend();
    final repository = CoachRepositoryImpl(fitness: backend);

    await repository.deleteAvatar();

    expect(adapter.captured!.method, 'DELETE');
    expect(adapter.captured!.path, '/coaches/me/avatar/');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd app && flutter test test/coach_repository_avatar_test.dart
```

Expected: compile error — `CoachRepositoryImpl` has no method `uploadAvatar`.

- [ ] **Step 3: Add the repository methods**

In `app/lib/data/repositories/fitness/coach.dart`, add `import 'dart:typed_data';` at the top, then declare on the abstract `CoachRepository`:

```dart
  Future<CoachModel> uploadAvatar(Uint8List bytes, String filename);
  Future<CoachModel> deleteAvatar();
```

And implement in `CoachRepositoryImpl`, after `updateCoach`:

```dart
  @override
  Future<CoachModel> uploadAvatar(Uint8List bytes, String filename) {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });

    return fitness.dio
        .post(
          "/coaches/me/avatar/",
          data: form,
          // BaseOptions pins application/json for every request; without this
          // override the multipart body is mislabelled and the upload fails.
          options: Options(contentType: 'multipart/form-data'),
        )
        .then((value) {
          if (value.data is! Map<String, dynamic>) {
            throw FormatException(
              'Expected Map but got ${value.data.runtimeType}',
            );
          }
          return CoachModel.fromJson(value.data);
        })
        .catchError(onException);
  }

  @override
  Future<CoachModel> deleteAvatar() => fitness.dio
      .delete("/coaches/me/avatar/")
      .then((value) {
        if (value.data is! Map<String, dynamic>) {
          throw FormatException(
            'Expected Map but got ${value.data.runtimeType}',
          );
        }
        return CoachModel.fromJson(value.data);
      })
      .catchError(onException);
```

- [ ] **Step 4: Add the usecase methods**

In `app/lib/domain/usecases/fitness/coach_usecase.dart`, add `import 'dart:typed_data';` at the top, then on the abstract `CoachUsecase`:

```dart
  Future<CoachEntity> uploadAvatar(Uint8List bytes, String filename);
  Future<CoachEntity> deleteAvatar();
```

And in `CoachUsecaseImpl`:

```dart
  @override
  Future<CoachEntity> uploadAvatar(Uint8List bytes, String filename) =>
      _api.uploadAvatar(bytes, filename).then((value) => value.entity);

  @override
  Future<CoachEntity> deleteAvatar() =>
      _api.deleteAvatar().then((value) => value.entity);
```

No `build_runner` run is needed: no new injectable class is introduced, only methods on existing registered types.

- [ ] **Step 5: Run the test to verify it passes**

```bash
cd app && flutter test test/coach_repository_avatar_test.dart
```

Expected: all 4 tests PASS.

- [ ] **Step 6: Commit**

```bash
git add app/lib/data/repositories/fitness/coach.dart app/lib/domain/usecases/fitness/coach_usecase.dart app/test/coach_repository_avatar_test.dart
git commit -m "feat(app): add avatar upload and delete to the coach data layer

Bytes rather than a file path cross the boundary so the call also works on
web, where XFile.path is a blob URL."
```

---

### Task 5: Wire the Edit Profile screen

**Files:**
- Modify: `app/lib/presentation/screens/settings/change_info_screen.dart` (the avatar `Stack` at lines 84-99, plus new state and handlers)
- Modify: `app/ios/Runner/Info.plist`

**Interfaces:**
- Consumes: `ImageUserWidget({onSourceSelected, onDelete, hasPhoto})` (Task 3); `CoachUsecase.uploadAvatar`, `CoachUsecase.deleteAvatar` (Task 4); `ApplicationBloc.UpdateCoachInfoEvent`
- Produces: nothing downstream — this is the final wiring

- [ ] **Step 1: Add the iOS permission strings**

In `app/ios/Runner/Info.plist`, inside the top-level `<dict>`:

```xml
	<key>NSCameraUsageDescription</key>
	<string>Take a photo to use as your profile picture.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Choose a photo from your library to use as your profile picture.</string>
```

Neither key is present today. On iOS their absence is not a warning — the app terminates the moment the picker opens. Android needs no new permission: `image_picker` uses the system picker and `ACTION_IMAGE_CAPTURE`.

- [ ] **Step 2: Add the imports and state**

At the top of `app/lib/presentation/screens/settings/change_info_screen.dart`:

```dart
import 'package:image_picker/image_picker.dart';
```

In `_ChangeInfoScreenState`, beside `_coach`:

```dart
  final _picker = ImagePicker();
  bool _uploadingAvatar = false;
```

- [ ] **Step 3: Add the avatar handlers**

In `_ChangeInfoScreenState`, after `dispose()`:

```dart
  Future<void> _pickAvatar(ImageSource source) async {
    if (_uploadingAvatar) return;

    // Not `final`: assigning inside the try block would leave it only
    // conditionally assigned as far as definite-assignment analysis is
    // concerned, and the analyzer rejects that.
    XFile? picked;
    try {
      picked = await _picker.pickImage(source: source, imageQuality: 85);
    } catch (e) {
      _reportAvatarError(e);
      return;
    }
    if (picked == null) return;

    // Bytes rather than a path: XFile.path is a blob URL on web.
    final bytes = await picked.readAsBytes();
    await _runAvatarRequest(
      () => GetIt.I<CoachUsecase>().uploadAvatar(bytes, picked!.name),
    );
  }

  Future<void> _deleteAvatar() =>
      _runAvatarRequest(() => GetIt.I<CoachUsecase>().deleteAvatar());

  Future<void> _runAvatarRequest(Future<CoachEntity> Function() request) async {
    setState(() => _uploadingAvatar = true);
    try {
      final updated = await request();
      if (!mounted) return;
      setState(() => _coach = _coach.rebuild((b) => b..imageUrl = updated.imageUrl));
      // Keeps the avatar on SettingsScreen in step with this one.
      context.read<ApplicationBloc>().add(UpdateCoachInfoEvent(coach: _coach));
    } catch (e) {
      _reportAvatarError(e);
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  void _reportAvatarError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not update photo: $error')),
    );
  }
```

- [ ] **Step 4: Replace the avatar block**

In `build`, the avatar uses `widget.coach` and so never reflects a new upload. Replace the `Center(child: Stack(...))` block (currently lines 84-99) with:

```dart
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatarWidget(
                    photoUrl: _coach.imageUrl,
                    initials: initials.isEmpty ? '?' : initials,
                    size: 120,
                    textStyle: context.theme.typography.xl2
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (_uploadingAvatar)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.theme.colors.background
                              .withValues(alpha: 0.6),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: ImageUserWidget(
                      hasPhoto: (_coach.imageUrl ?? '').isNotEmpty,
                      onSourceSelected: _pickAvatar,
                      onDelete: _deleteAvatar,
                    ),
                  ),
                ],
              ),
            ),
```

The `initials` local at the top of `build` also reads `widget.coach`; change both occurrences to `_coach` so the fallback initials track edits to the name fields:

```dart
    final initials = [
      if ((_coach.firstName ?? '').isNotEmpty) _coach.firstName![0],
      if ((_coach.lastName ?? '').isNotEmpty) _coach.lastName![0],
    ].join();
```

If `withValues` is unavailable on the installed Flutter version, use `withOpacity(0.6)` instead.

- [ ] **Step 5: Analyze and run the whole suite**

```bash
cd app && flutter analyze && flutter test
```

Expected: no analyzer errors, every test passes — including the two new files and the pre-existing `settings_program_screen_test.dart`, `app_svgs_test.dart`, `app_pngs_test.dart`, `widget_test.dart`.

- [ ] **Step 6: Verify end to end against a running backend**

```bash
cd service && docker compose up -d && docker compose logs -f api
```

Then, in the app, sign in as a coach, open Settings → Edit Profile, tap the camera badge, and check each path:

1. "Select from Gallery" → pick an image → spinner appears, then the new avatar renders.
2. Navigate back to Settings → the avatar there shows the new image too.
3. Re-open Edit Profile → "Delete Photo" is now offered → tap it → initials return.
4. With no photo set, re-open the sheet → "Delete Photo" is absent.
5. Confirm the file landed: `ls service/media/avatars/`.
6. Confirm the replaced file was cleaned up: after a second upload, only one `coach_{id}_*` file remains.

- [ ] **Step 7: Commit**

```bash
git add app/lib/presentation/screens/settings/change_info_screen.dart app/ios/Runner/Info.plist
git commit -m "feat(app): let coaches set and remove their profile avatar

Picking a photo uploads it immediately and refreshes both this screen and the
settings avatar. Adds the iOS camera and photo-library usage strings, without
which the picker terminates the app."
```

---

## Notes for the executor

- **Backend before client.** Tasks 3-5 cannot be verified end to end until Tasks 1-2 are deployed to whatever backend the app points at (`http://207.126.161.154:8000/api/v1/`, hardcoded at `dio_settings_backend.dart:19`).
- **The app does not compile between Tasks 3 and 5.** Task 3 changes `ImageUserWidget`'s constructor while `change_info_screen.dart` still calls `const ImageUserWidget()`. Per-file `flutter test` still passes; `flutter analyze` will report the call site until Task 5 lands. This is expected — do not "fix" it early by guessing Task 5's wiring.
- **Do not trust `Content-Type` anywhere.** The magic-byte check in `detect_extension` is the security boundary for a directory served over HTTP; a test asserts it specifically.
