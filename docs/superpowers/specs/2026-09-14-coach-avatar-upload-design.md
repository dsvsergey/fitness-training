# Coach avatar upload — design

Date: 2026-09-14
Status: approved, ready for implementation planning

## Problem

A coach editing their profile cannot set an avatar. The camera button on
`ChangeInfoScreen` opens a bottom sheet with three options — "Select from
Gallery", "Open Camera", "Delete Photo" — and all three are dead: each is
declared as `onPressed: () {}` in
`app/lib/presentation/widgets/image_user_widget.dart`.

The feature is missing at all three layers, not merely unwired:

1. **Widget.** `ImageUserWidget` takes no callbacks and is instantiated as
   `const ImageUserWidget()` at `change_info_screen.dart:95`. Even with
   handlers filled in, it has no way to report a result back to the screen.
2. **Client dependencies.** Neither `image_picker` nor `file_picker` is in
   `app/pubspec.yaml`, so no image can be chosen from gallery or camera.
3. **Backend.** The service has no file-upload capability at all — no
   `UploadFile`, no `StaticFiles`, no multipart handling anywhere in
   `service/app`. `image_url` is a plain `String` column
   (`service/app/models/coachs.py:15`).

What already works: the `image_url` string travels end to end — DB column →
`CoachSchema`/`CoachResponse` → `CoachModel` (`wireName: 'image_url'`) →
`CoachEntity` → `UserAvatarWidget`. The only missing piece is something that
accepts bytes, stores them, and returns a URL.

## Decisions

| Question | Decision |
|---|---|
| Scope | Full round trip: image uploaded to the server, visible on every device and in the admin panel. |
| Sources | Gallery and camera. |
| Storage | Server disk, served by `StaticFiles` behind the existing nginx. No S3/MinIO. |
| Timing | Upload fires immediately when a photo is picked, not on "Save changes". |

Rationale for immediate upload: the sheet's "Delete Photo" option is
inherently immediate, so deferring only the upload would make the two halves
of the same menu behave inconsistently. It also avoids holding image bytes in
widget state, and keeps `image_url` authoritative on the server at all times.
The avatar therefore becomes independent of the text fields and their Save
button.

## Backend design (`service/`)

### Storage module — `app/services/avatar_storage.py` (new)

One responsibility: validate an uploaded image, write it to disk, and return
its public URL; plus delete a previously stored file. No DB access, no
request objects — this keeps it directly unit-testable.

Validation rules:

- **Type** is determined by sniffing magic bytes, *not* by the client-supplied
  `Content-Type` header. Accepted: JPEG, PNG, WebP. Anything else is rejected
  with HTTP 400.
- **Size** must not exceed 5 MB. Enforced while reading, so an oversized body
  is not buffered whole.
- **Filename** is generated server-side as `coach_{coach_id}_{uuid4hex}.{ext}`.
  The client-supplied filename is never used — this removes path traversal and
  file-overwrite concerns, and guarantees a distinct URL per upload.

Because each upload gets a fresh filename, the replaced file must be deleted
explicitly or the directory grows without bound. Deletion is best-effort: a
missing or already-removed file must not fail the request.

### Static serving — `service/main.py`

Mount `app.mount("/media", StaticFiles(directory=settings.MEDIA_ROOT), name="media")`
inside `start_application()`, creating the directory at startup if absent.

No nginx change is required: `service/nginx/fitness-api.conf.template` already
proxies `location /` to uvicorn and already sets `client_max_body_size 20M`,
comfortably above the 5 MB cap.

### Endpoints — `app/api/v1/auth/auth.py`

The new routes go beside the existing `/coaches/me/` handlers, because that is
where the app already sends profile updates (`PUT /coaches/me/`, called from
`coach.dart:76`) — not in `app/api/v1/coachs/coachs.py`.

- `POST /coaches/me/avatar/` — accepts `UploadFile`, stores it, deletes the
  previous file, writes the new `image_url`, returns `CoachResponse`.
- `DELETE /coaches/me/avatar/` — removes the file, sets `image_url` to `None`,
  returns `CoachResponse`.

Both reuse the guard their neighbours use: reject with 403 unless
`current_user.startswith("coach:")`, then derive `coach_id` from the JWT
subject. The coach id is never taken from the request body or path, so one
coach cannot overwrite another's avatar.

`python-multipart==0.0.9` is already in `requirements.txt`; no new dependency.

### Configuration

Added to `app/core/config.py` and documented in `.env_src`:

- `MEDIA_ROOT` — default `/app/media`
- `PUBLIC_BASE_URL` — e.g. `http://207.126.161.154:8000`, used to build
  absolute URLs

**Absolute URLs are stored in the DB.** Two reasons: `UserAvatarWidget` renders
via `NetworkImage(url)` (`user_avatar_widget.dart:30`) and cannot resolve a
relative path; and the Google OAuth path already stores an absolute URL in the
same column (`coach_service.py:242`), so this keeps one convention.

The trade-off is explicit: if the public host changes, previously stored URLs
break. Accepted for now, as it matches existing behaviour. A future migration
could rewrite the column if the host ever moves.

Files are written to `service/media/`, which sits inside the existing
`.:/app` bind mount in `docker-compose.yml` and therefore survives container
restarts. `media/` is added to `.gitignore`, and `DEPLOYMENT.md` gains a note
that this directory needs backing up separately from the database.

## Client design (`app/`)

### `ImageUserWidget`

Stops being a `const` placeholder and becomes a presentational widget with an
explicit interface:

- `onSourceSelected(ImageSource)` — gallery or camera
- `onDelete()`
- `hasPhoto` — hides "Delete Photo" when there is nothing to delete

Picking and uploading live outside the widget, so it stays testable and free of
I/O. Two existing defects are fixed here: the bottom sheet is dismissed
(`Navigator.pop(sheetCtx)`) before the action runs — currently it would stay
open over the result — and the delete option is no longer offered when the
coach has no photo.

### Data layer

`uploadAvatar` and `deleteAvatar` are added to `CoachRepository`
(`data/repositories/fitness/coach.dart`) and `CoachUsecase`
(`domain/usecases/fitness/coach_usecase.dart`), matching the existing
abstract-class-plus-`@Singleton`/`@LazySingleton` pattern. Both return the
updated `CoachModel`/`CoachEntity`.

The upload sends `FormData` and **must** pass
`Options(contentType: 'multipart/form-data')`. `DioSettingsBackend` hardcodes
`contentType: 'application/json'` plus a default `Content-Type: application/json`
header in `BaseOptions` (`dio_settings_backend.dart:19-22`); without the
per-request override the multipart body is mislabelled and the upload fails.

### `ChangeInfoScreen`

Holds an `_uploadingAvatar` flag, showing a progress indicator over the avatar
while the request is in flight and ignoring further taps until it settles. On
success it rebuilds `_coach` with the returned `imageUrl`, calls `setState`,
and dispatches `UpdateCoachInfoEvent` so the avatar on `SettingsScreen`
(`settings_screen.dart:41`) updates too. Failures surface as a SnackBar and
leave the previous avatar in place.

`NetworkImage` caching needs no cache-busting: every upload produces a new
filename and therefore a new URL.

### Platform requirements

- `image_picker` added to `pubspec.yaml`.
- `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` added to
  `app/ios/Runner/Info.plist`. Neither key is present today, and on iOS their
  absence is not a warning — the app terminates when the picker opens.
- Android needs no new permission: `image_picker` uses the system picker and
  `ACTION_IMAGE_CAPTURE`, neither of which requires a manifest declaration.

## Testing

**Backend** — `service/tests/test_avatar_upload.py`, following the style of the
existing `tests/test_google_oauth.py`: pytest, no database, no network,
exercising the pure helpers in `avatar_storage.py` against `tmp_path`.

- a valid JPEG/PNG/WebP is stored and its returned URL is well-formed
- a non-image payload is rejected even when `Content-Type` claims `image/png`
  (this is the magic-byte check, and the reason it exists)
- a file over 5 MB is rejected
- replacing an avatar removes the previous file
- deleting an already-absent file does not raise

**Client** — `app/test/image_user_widget_test.dart`, following the existing
`test/settings_program_screen_test.dart` pattern: pumping the widget and
tapping each of the three options invokes the matching callback, and "Delete
Photo" is absent when `hasPhoto` is false.

That client test is the direct regression guard for the reported bug: the
current `onPressed: () {}` implementation would fail it.

## Out of scope

- Trainee avatars — the same mechanism would apply, but this change covers the
  coach profile screen only.
- Server-side image resizing or thumbnail generation; the 5 MB cap is the only
  size control.
- Migrating existing Google OAuth `picture` URLs to locally hosted copies.
