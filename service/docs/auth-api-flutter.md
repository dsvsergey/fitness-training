# Authentication API — Flutter Integration Guide

Base URL (staging): `http://207.126.161.154:8000`  
All endpoints: `{base_url}/api/v1/...`

---

## Table of Contents

1. [Overview](#overview)
2. [Token Usage](#token-usage)
3. [Email + Password Registration & Login](#email--password)
4. [Google OAuth](#google-oauth)
5. [Email Verification](#email-verification)
6. [Password Reset](#password-reset)
7. [User Profile](#user-profile)
8. [Error Responses](#error-responses)
9. [Flutter Implementation Notes](#flutter-implementation-notes)

---

## Overview

The API supports two user roles:

| Role | Description |
|------|-------------|
| `trainee` | End user (client of the fitness app) |
| `coach` | Trainer / staff member |

JWT tokens encode the role as a prefix in the `sub` field: `"trainee:42"` or `"coach:7"`.  
All protected endpoints require `Authorization: Bearer <token>` header.

---

## Token Usage

After any successful login/register flow, the API returns:

```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer"
}
```

Store the token securely (e.g. `flutter_secure_storage`) and attach it to every authenticated request:

```
Authorization: Bearer eyJhbGci...
```

Token lifetime: **8 days** (default). No refresh token — user must re-authenticate after expiry.

---

## Email + Password

### Register Trainee

Creates a new trainee account and sends a verification email.  
The account is usable immediately, but `email_verified` will be `false` until the user confirms their email.

```
POST /api/v1/trainees/register/
```

**Request body:**
```json
{
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "password": "secret123"
}
```

**Response `201 Created`:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "email_verified": false,
  "mobile_phone": null,
  "address1": null,
  "city": null,
  "state": null,
  "country": null,
  "weight": null,
  "height": null,
  "created_at": "2026-04-16T12:00:00",
  "updated_at": "2026-04-16T12:00:00"
}
```

**Error `400`** — email already registered:
```json
{ "detail": "A user with this email already exists." }
```

---

### Login (Trainee or Coach)

Universal login endpoint — tries coach first, then trainee.

```
POST /api/v1/login/
```

**Request body:**
```json
{
  "email": "user@example.com",
  "password": "secret123"
}
```

**Response `200 OK`:**
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer",
  "trainee": { ...trainee object... }
}
```

or if coach logged in:
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer",
  "coach": { ...coach object... }
}
```

**Error `401`:**
```json
{ "detail": "Incorrect email or password" }
```

> **Tip:** Check whether the response contains `trainee` or `coach` key to determine which profile screen to show.

---

### Register Coach

```
POST /api/v1/coaches/register/
```

**Request body:**
```json
{
  "email": "coach@example.com",
  "first_name": "Anna",
  "last_name": "Smith",
  "password": "secret123",
  "mobile_phone": "+380501234567"
}
```

**Response `200 OK`:** full coach object.

---

### Login Coach (dedicated)

```
POST /api/v1/coaches/login/
```

**Request body:**
```json
{
  "email": "coach@example.com",
  "password": "secret123"
}
```

**Response `200 OK`:**
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer"
}
```

---

## Google OAuth

The flow uses the standard **Authorization Code** redirect:

```
Flutter app  →  GET /google/authorize  →  open WebView/browser
Google       →  redirect to callback URL with ?code=&state=
Backend      →  exchanges code, creates/finds user, returns JWT
Flutter app  ←  receives JWT (via redirect to FRONTEND_URL or direct JSON)
```

### Step 1 — Get Authorization URL

```
GET /api/v1/google/authorize?role=trainee
```

| Query param | Values | Description |
|-------------|--------|-------------|
| `role` | `trainee` (default), `coach` | Determines what account type to create for new users |

**Response `200 OK`:**
```json
{
  "url": "https://accounts.google.com/o/oauth2/v2/auth?client_id=...&state=..."
}
```

### Step 2 — Open in WebView

Open the returned `url` in a WebView or `url_launcher`. Google shows its consent screen.

### Step 3 — Handle Callback

After the user consents, Google redirects to:
```
http://207.126.161.154:8000/api/v1/google/callback?code=...&state=...
```

The backend exchanges the code and either:

**Option A — FRONTEND_URL configured (production):**  
Redirects to `{FRONTEND_URL}/auth/callback?token=<jwt>&sub=trainee:42`  
→ Intercept this URL in the WebView, extract `token` from query params.

**Option B — FRONTEND_URL not configured (staging/local):**  
Returns JSON directly:
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer"
}
```

> **Current staging behaviour:** returns JSON directly (Option B).  
> To use Option A, set `FRONTEND_URL` in `.env` to your app's deep link scheme, e.g. `fitnessapp://auth`.

### Behaviour for existing users

| Situation | Result |
|-----------|--------|
| Google email matches existing trainee account | Links Google to existing account, returns JWT |
| Google ID already linked | Returns JWT immediately |
| Brand new email | Creates new trainee/coach, `email_verified = true` |

---

## Email Verification

After registration with email/password, a verification link is sent to the user's inbox.

The link format: `{FRONTEND_URL}/verify-email?token=<jwt_token>`

### Deep Link Handling

Configure your Flutter app to handle the deep link and extract the `token` parameter, then call:

```
GET /api/v1/verify-email?token=<token_from_link>
```

**Response `200 OK`:**
```json
{ "message": "Email verified successfully." }
```

**Error `400`** — expired or invalid token:
```json
{ "detail": "Invalid or expired verification token." }
```

> After successful verification, the user's profile will have `"email_verified": true`.  
> Verification token is valid for **48 hours**.  
> The account works before verification — you may show a banner prompting the user to verify.

---

## Password Reset

Two-step flow: request a reset link → confirm new password.

### Step 1 — Request Reset Email

```
POST /api/v1/password-reset/request
```

**Request body:**
```json
{ "email": "user@example.com" }
```

**Response `200 OK`** (always, even if email not found — prevents enumeration):
```json
{
  "message": "If an account with that email exists, a password reset link has been sent."
}
```

The email contains a link: `{FRONTEND_URL}/reset-password?token=<jwt_token>`

---

### Step 2 — Confirm New Password

Handle the deep link, extract `token`, show a "new password" form, then call:

```
POST /api/v1/password-reset/confirm
```

**Request body:**
```json
{
  "token": "<token_from_link>",
  "new_password": "newSecret456"
}
```

**Response `200 OK`:**
```json
{ "message": "Password reset successfully." }
```

**Error `400`** — expired or invalid token:
```json
{ "detail": "Invalid or expired reset token." }
```

> Reset token is valid for **24 hours**.

---

## User Profile

### Get Current Trainee

```
GET /api/v1/trainees/me/
Authorization: Bearer <token>
```

**Response `200 OK`:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "email_verified": true,
  "mobile_phone": "+380501234567",
  "address1": null,
  "city": null,
  "state": null,
  "country": null,
  "gender": null,
  "weight": 75.5,
  "height": 180.0,
  "programs": [],
  "created_at": "2026-04-16T12:00:00",
  "updated_at": "2026-04-16T12:00:00"
}
```

**Error `403`** — token belongs to a coach, not a trainee.

---

### Get Current Coach

```
GET /api/v1/coaches/me/
Authorization: Bearer <token>
```

---

### Change Coach Password

```
PUT /api/v1/coaches/me/password/
Authorization: Bearer <token>
```

**Request body:**
```json
{
  "current_password": "oldPassword",
  "new_password": "newPassword"
}
```

**Response `200 OK`:**
```json
{ "message": "Password updated successfully" }
```

---

## Error Responses

All errors follow FastAPI's standard format:

```json
{ "detail": "Human-readable error message" }
```

| HTTP Code | Meaning |
|-----------|---------|
| `400` | Bad request (validation, duplicate email, invalid token) |
| `401` | Wrong credentials or missing/expired JWT |
| `403` | Authenticated but wrong role (e.g. trainee token on coach endpoint) |
| `404` | Resource not found |
| `422` | Request body validation failed (Pydantic) |
| `500` | Server error |
| `502` | Google OAuth upstream error |
| `503` | Google OAuth not configured on server |

---

## Flutter Implementation Notes

### Recommended Packages

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0   # store JWT
  dio: ^5.0.0                       # HTTP client
  url_launcher: ^6.0.0              # open Google OAuth URL
  webview_flutter: ^4.0.0           # OR use for OAuth WebView
  app_links: ^6.0.0                 # deep link handling (email verify, password reset)
```

---

### Auth Flow Diagram

```
Registration (email/password)
  └─ POST /trainees/register/
       ├─ success → save token → show "check your email" banner
       └─ 400 → show "email already exists"

Login
  └─ POST /login/
       ├─ success → check response for "trainee" or "coach" key
       │            → save token → navigate to home
       └─ 401 → show error

Google OAuth
  └─ GET /google/authorize?role=trainee → get URL
       └─ open URL in WebView/browser
            └─ intercept callback redirect
                 └─ extract token → save → navigate to home

Email Verification (deep link)
  └─ app://verify-email?token=...
       └─ GET /verify-email?token=...
            └─ show success/error

Password Reset (deep link)
  └─ app://reset-password?token=...
       └─ show "new password" form
            └─ POST /password-reset/confirm
                 └─ show success → navigate to login
```

---

### JWT Decoding (to get role & ID without API call)

The JWT payload contains:
```json
{
  "sub": "trainee:42",
  "type": "access_token",
  "exp": 1234567890
}
```

```dart
import 'dart:convert';

Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  final payload = parts[1];
  final normalized = base64Url.normalize(payload);
  return jsonDecode(utf8.decode(base64Url.decode(normalized)));
}

// Usage
final payload = decodeJwtPayload(token);
final sub = payload['sub'] as String;       // "trainee:42"
final role = sub.split(':')[0];             // "trainee"
final userId = int.parse(sub.split(':')[1]); // 42
final exp = payload['exp'] as int;
final isExpired = DateTime.now().millisecondsSinceEpoch ~/ 1000 > exp;
```

---

### Deep Link Configuration

For email verification and password reset to work, configure deep links so your app intercepts URLs like:
- `http://207.126.161.154:3000/verify-email?token=...`
- `http://207.126.161.154:3000/reset-password?token=...`

Or set `FRONTEND_URL` on the server to your custom scheme (e.g. `fitnessapp://`) and handle accordingly.

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="http" android:host="207.126.161.154" android:port="3000"/>
</intent-filter>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array><string>fitnessapp</string></array>
  </dict>
</array>
```
