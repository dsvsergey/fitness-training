# Authentication API — Flutter Integration Guide

Base URL (staging): `http://207.126.161.154:8000`  
All endpoints: `{base_url}/api/v1/...`

---

## ⚠️ Зміни — що потрібно оновити у Flutter додатку

| # | Що змінилось | Було | Стало |
|---|-------------|------|-------|
| 1 | **URL реєстрації** | `POST /api/v1/trainees/register/` | `POST /api/v1/coaches/register/` |
| 2 | **URL профілю поточного користувача** | `GET /api/v1/trainees/me/` | `GET /api/v1/coaches/me/` |
| 3 | **Google OAuth** | `GET /google/authorize?role=trainee` | `GET /google/authorize` (role=coach за замовч.) |
| 4 | **Тип акаунту після реєстрації** | створювався `Trainee` | створюється `Coach + User` |
| 5 | **JWT sub після логіну** | `"trainee:42"` | `"coach:7"` |

> Старі ендпоїнти `/trainees/register/` і `/trainees/me/` тимчасово залишені як deprecated aliases — вони ще працюють, але будуть видалені. Оновіть URL якнайшвидше.

---

## Table of Contents

1. [Overview](#overview)
2. [Token Usage](#token-usage)
3. [Registration & Login (Email + Password)](#registration--login-email--password)
4. [Google OAuth](#google-oauth)
5. [Password Reset](#password-reset)
6. [Coach Profile](#coach-profile)
7. [Trainee & Coach CRUD](#trainee--coach-crud)
8. [Error Responses](#error-responses)
9. [Flutter Implementation Notes](#flutter-implementation-notes)

---

## Overview

Додаток призначений для **тренерів (coach)**, які керують тренуваннями своїх клієнтів (trainee).

| Role | Description |
|------|-------------|
| `coach` | Тренер — основний користувач додатку |
| `trainee` | Клієнт/спортсмен — керується тренером |

При реєстрації завжди створюється **Coach + User** (обліковий запис для автентифікації).

JWT токен кодує роль у полі `sub`: `"coach:7"` або `"trainee:42"`.  
Всі захищені ендпоїнти вимагають заголовок `Authorization: Bearer <token>`.

---

## Token Usage

Після успішного входу або реєстрації API повертає:

```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer"
}
```

Зберігайте токен у захищеному сховищі (`flutter_secure_storage`) та додавайте до кожного запиту:

```
Authorization: Bearer eyJhbGci...
```

Термін дії токену: **8 днів**. Refresh token відсутній — після закінчення терміну користувач повинен увійти знову.

---

## Registration & Login (Email + Password)

### Register Coach

Створює новий обліковий запис тренера (Coach + User). Токен не потрібен.

```
POST /api/v1/coaches/register/
```

> **Deprecated alias:** `POST /api/v1/trainees/register/` — досі працює, але буде видалено. Оновіть URL у Flutter додатку на `/coaches/register/`.

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

Обов'язкові поля: `email`, `first_name`, `last_name`, `password`.  
Всі інші поля опціональні.

**Response `201 Created`:**
```json
{
  "id": 1,
  "email": "coach@example.com",
  "first_name": "Anna",
  "last_name": "Smith",
  "mobile_phone": "+380501234567",
  "work_phone": null,
  "address1": null,
  "address2": null,
  "city": null,
  "state": null,
  "postal_code": null,
  "country": null,
  "gender": null,
  "biography": null,
  "image_url": null,
  "note": null,
  "created_at": "2026-04-17T12:00:00",
  "updated_at": "2026-04-17T12:00:00"
}
```

**Error `400`** — email вже зареєстровано:
```json
{ "detail": "Coach with this email already exists" }
```

> Після реєстрації одразу можна входити — email верифікація для coach не потрібна.

#### Deprecated alias

`POST /api/v1/trainees/register/` — приймає той самий body і повертає той самий результат, але буде видалено. **Замініть URL на `/coaches/register/`.**

---

### Login

Універсальний ендпоїнт — спочатку перевіряє coach, потім trainee.

```
POST /api/v1/login/
```

**Request body:**
```json
{
  "email": "coach@example.com",
  "password": "secret123"
}
```

**Response `200 OK` (coach):**
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer",
  "coach": {
    "id": 1,
    "email": "coach@example.com",
    "first_name": "Anna",
    "last_name": "Smith",
    "mobile_phone": null,
    "biography": null,
    "image_url": null,
    "created_at": "2026-04-17T12:00:00",
    "updated_at": "2026-04-17T12:00:00"
  },
  "trainee": null
}
```

**Response `200 OK` (trainee):**
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer",
  "coach": null,
  "trainee": { ...trainee object... }
}
```

**Error `401`:**
```json
{ "detail": "Incorrect email or password" }
```

> Перевіряйте наявність ключа `coach` або `trainee` у відповіді, щоб визначити тип облікового запису.

---

## Google OAuth

Після Google OAuth автоматично створюється **Coach** (за замовчуванням).

```
Flutter app  →  GET /google/authorize  →  відкрити WebView/браузер
Google       →  redirect з ?code=&state=
Backend      →  обмін кодом, створює/знаходить coach, повертає JWT
Flutter app  ←  отримує JWT
```

### Step 1 — Отримати URL авторизації

```
GET /api/v1/google/authorize
```

Параметр `role` за замовчуванням — `coach`. Передавати не обов'язково.

| Query param | Values | Default |
|-------------|--------|---------|
| `role` | `coach`, `trainee` | `coach` |

**Response `200 OK`:**
```json
{
  "url": "https://accounts.google.com/o/oauth2/v2/auth?client_id=...&state=..."
}
```

### Step 2 — Відкрити у WebView

Відкрийте отриманий `url` у WebView або через `url_launcher`.

### Step 3 — Обробити callback

Після підтвердження Google робить redirect на:
```
http://207.126.161.154:8000/api/v1/google/callback?code=...&state=...
```

Бекенд обмінює код та:

**Option A — FRONTEND_URL налаштований (production):**  
Redirects на `{FRONTEND_URL}/auth/callback?token=<jwt>&sub=coach:7`  
→ Перехопіть цей URL у WebView, витягніть `token` з query params.

**Option B — FRONTEND_URL не налаштований (staging):**  
Повертає JSON:
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer"
}
```

> **Поточний staging:** повертає JSON напряму (Option B).

### Поведінка для існуючих користувачів

| Ситуація | Результат |
|----------|-----------|
| Google email збігається з існуючим coach | Прив'язує Google до акаунту, повертає JWT |
| Google ID вже прив'язаний | Повертає JWT одразу |
| Новий email | Створює нового Coach, `email_verified = true` |

---

## Password Reset

Двокроковий флоу: запит посилання → підтвердження нового пароля.

### Step 1 — Запит листа для скидання

```
POST /api/v1/password-reset/request
```

**Request body:**
```json
{ "email": "coach@example.com" }
```

**Response `200 OK`** (завжди, навіть якщо email не знайдено):
```json
{
  "message": "If an account with that email exists, a password reset link has been sent."
}
```

Лист містить посилання: `{FRONTEND_URL}/reset-password?token=<jwt_token>`

---

### Step 2 — Підтвердження нового пароля

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

**Error `400`** — прострочений або невірний токен:
```json
{ "detail": "Invalid or expired reset token." }
```

> Токен для скидання діє **24 години**.

---

## Coach Profile

### Отримати свій профіль

```
GET /api/v1/coaches/me/
Authorization: Bearer <coach_token>
```

> **Deprecated alias:** `GET /api/v1/trainees/me/` — ще працює, але буде видалено. Замініть на `/coaches/me/`.

**Response `200 OK`:**
```json
{
  "id": 1,
  "email": "coach@example.com",
  "first_name": "Anna",
  "last_name": "Smith",
  "mobile_phone": "+380501234567",
  "work_phone": null,
  "address1": null,
  "city": null,
  "country": null,
  "gender": null,
  "biography": null,
  "image_url": null,
  "note": null,
  "created_at": "2026-04-17T12:00:00",
  "updated_at": "2026-04-17T12:00:00"
}
```

**Error `403`** — токен належить trainee.

---

### Оновити свій профіль

```
PUT /api/v1/coaches/me/
Authorization: Bearer <coach_token>
```

**Request body** (всі поля опціональні):
```json
{
  "first_name": "Anna",
  "last_name": "Smith",
  "mobile_phone": "+380501234567",
  "work_phone": "+380441234567",
  "city": "Kyiv",
  "country": "Ukraine",
  "biography": "Certified trainer with 10 years experience",
  "image_url": "https://example.com/photo.jpg"
}
```

**Response `200 OK`:** оновлений об'єкт coach.

---

### Змінити пароль

```
PUT /api/v1/coaches/me/password/
Authorization: Bearer <coach_token>
```

**Request body:**
```json
{
  "current_password": "oldPassword",
  "new_password": "newPassword123"
}
```

**Response `200 OK`:**
```json
{ "message": "Password updated successfully" }
```

**Error `400`** — поточний пароль невірний.

---

## Trainee & Coach CRUD

Управління профілями клієнтів (trainee) та тренерів — см. окремий документ:  
[trainee-coach-api-flutter.md](trainee-coach-api-flutter.md)

> **Правила доступу:** тільки coach може створювати, редагувати та видаляти trainee.

---

## Error Responses

```json
{ "detail": "Human-readable error message" }
```

| HTTP Code | Значення |
|-----------|---------|
| `400` | Помилка запиту (дублікат email, невірний токен, невірний пароль) |
| `401` | Відсутній або прострочений JWT токен |
| `403` | Авторизований, але неправильна роль |
| `404` | Ресурс не знайдено |
| `422` | Помилка валідації тіла запиту (Pydantic) |
| `500` | Помилка сервера |
| `502` | Помилка Google OAuth (upstream) |
| `503` | Google OAuth не налаштовано на сервері |

---

## Flutter Implementation Notes

### Recommended Packages

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0   # зберігання JWT
  dio: ^5.0.0                       # HTTP клієнт
  url_launcher: ^6.0.0              # відкрити Google OAuth URL
  webview_flutter: ^4.0.0           # WebView для OAuth
  app_links: ^6.0.0                 # deep link (password reset)
```

---

### Auth Flow Diagram

```
Registration (email/password)
  └─ POST /coaches/register/
       ├─ success → save token → navigate to home
       └─ 400 → show "email already exists"

Login
  └─ POST /login/
       ├─ success → check response for "coach" or "trainee" key
       │            → save token → navigate to home
       └─ 401 → show error

Google OAuth (реєстрація або вхід)
  └─ GET /google/authorize  (role=coach за замовчуванням)
       └─ open URL in WebView/browser
            └─ intercept callback redirect
                 └─ extract token → save → navigate to home

Password Reset (deep link)
  └─ app://reset-password?token=...
       └─ show "new password" form
            └─ POST /password-reset/confirm
                 └─ show success → navigate to login
```

---

### JWT Decoding

JWT payload містить:
```json
{
  "sub": "coach:7",
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
final sub = payload['sub'] as String;        // "coach:7"
final role = sub.split(':')[0];              // "coach"
final userId = int.parse(sub.split(':')[1]); // 7
final exp = payload['exp'] as int;
final isExpired = DateTime.now().millisecondsSinceEpoch ~/ 1000 > exp;
```

---

### Deep Link Configuration

Для password reset налаштуйте deep links:
- `http://207.126.161.154:3000/reset-password?token=...`

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
