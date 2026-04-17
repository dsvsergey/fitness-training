# Trainee & Coach CRUD API — Flutter Integration Guide

Base URL (staging): `http://207.126.161.154:8000`  
All endpoints: `{base_url}/api/v1/...`

---

## Table of Contents

1. [Role-Based Access](#role-based-access)
2. [Trainee Endpoints](#trainee-endpoints)
3. [Coach Endpoints](#coach-endpoints)
4. [Field Reference](#field-reference)
5. [Error Responses](#error-responses)

---

## Role-Based Access

All endpoints in this document require a valid JWT token in the `Authorization` header:

```
Authorization: Bearer <token>
```

Деякі ендпоїнти доступні **тільки для coach**. Якщо trainee спробує викликати такий ендпоїнт — отримає `403`.

| Action | Trainee token | Coach token |
|--------|:---:|:---:|
| Get list of trainees | ✅ | ✅ |
| Get trainee by ID | ✅ | ✅ |
| Create trainee (admin) | ❌ 403 | ✅ |
| Update trainee | ❌ 403 | ✅ |
| Delete trainee | ❌ 403 | ✅ |
| Get list of coaches | ✅ | ✅ |
| Get coach by ID | ✅ | ✅ |
| Get own profile (`/me/`) | trainee only | coach only |

> Self-registration (`POST /trainees/register/`) не вимагає токена.

---

## Trainee Endpoints

### Get List of Trainees

```
GET /api/v1/trainees/
Authorization: Bearer <token>
```

**Query params:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `skip` | int | `0` | Offset (pagination) |
| `limit` | int | `100` | Max results |
| `q` | string | — | Search query (name/email) |

**Response `200 OK`:**
```json
{
  "total_count": 42,
  "trainees": [
    {
      "id": 1,
      "email": "john@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "mobile_phone": "+380501234567",
      "address1": null,
      "address2": null,
      "city": null,
      "state": null,
      "postal_code": null,
      "country": null,
      "gender": null,
      "notes": null,
      "weight": 75.5,
      "height": 180.0,
      "programs": []
    }
  ]
}
```

**Error `404`** — no trainees found.

---

### Get Trainee by ID

```
GET /api/v1/trainees/{trainee_id}
Authorization: Bearer <token>
```

**Response `200 OK`:** trainee object (same structure as above, plus `email_verified`, `created_at`, `updated_at`).

**Error `404`** — trainee not found.

---

### Create Trainee *(coach only)*

Створення trainee тренером (наприклад, додати клієнта вручну без самореєстрації).

```
POST /api/v1/trainees/
Authorization: Bearer <coach_token>
```

**Request body:**
```json
{
  "email": "client@example.com",
  "first_name": "Ivan",
  "last_name": "Kovalenko",
  "password": "tempPass123",
  "mobile_phone": "+380671234567",
  "address1": "вул. Хрещатик 1",
  "city": "Kyiv",
  "country": "Ukraine",
  "gender": "male",
  "weight": 80.0,
  "height": 175.0
}
```

All fields except `email`, `first_name`, `last_name`, `password` are optional.

**Response `201 Created`:** full trainee object.

**Error `400`** — email already registered.  
**Error `403`** — caller is not a coach.

---

### Update Trainee *(coach only)*

```
PUT /api/v1/trainees/{trainee_id}
Authorization: Bearer <coach_token>
```

**Request body** (all fields optional — send only what needs to change):
```json
{
  "first_name": "Ivan",
  "last_name": "Kovalenko",
  "mobile_phone": "+380671234567",
  "address1": "вул. Хрещатик 1",
  "address2": "кв. 5",
  "city": "Kyiv",
  "state": null,
  "postal_code": "01001",
  "country": "Ukraine",
  "gender": "male",
  "notes": "Prefer morning sessions",
  "weight": 82.5,
  "height": 175.0,
  "email": "newemail@example.com",
  "password": "newPassword123"
}
```

**Response `200 OK`:** updated trainee object.

**Error `403`** — caller is not a coach.  
**Error `404`** — trainee not found.

---

### Delete Trainee *(coach only)*

```
DELETE /api/v1/trainees/{trainee_id}
Authorization: Bearer <coach_token>
```

**Response `200 OK`:**
```json
{ "detail": "Trainee deleted successfully" }
```

**Error `403`** — caller is not a coach.  
**Error `404`** — trainee not found.

---

### Get Own Trainee Profile

```
GET /api/v1/trainees/me/
Authorization: Bearer <trainee_token>
```

**Response `200 OK`:** full trainee object including `email_verified`.

**Error `403`** — token belongs to a coach, not a trainee.

---

## Coach Endpoints

### Get List of Coaches

```
GET /api/v1/coaches/
Authorization: Bearer <token>
```

**Query params:** `skip` (default `0`), `limit` (default `100`).

**Response `200 OK`:**
```json
[
  {
    "id": 1,
    "first_name": "Anna",
    "last_name": "Smith",
    "email": "anna@example.com",
    "mobile_phone": "+380501234567",
    "work_phone": null,
    "address1": null,
    "city": null,
    "state": null,
    "postal_code": null,
    "country": null,
    "gender": null,
    "biography": null,
    "image_url": null,
    "note": null
  }
]
```

**Error `404`** — no coaches found.

---

### Get Coach by ID

```
GET /api/v1/coaches/{coach_id}
Authorization: Bearer <token>
```

**Response `200 OK`:** coach object (same structure as above).

**Error `404`** — coach not found.

---

### Get Own Coach Profile

```
GET /api/v1/coaches/me/
Authorization: Bearer <coach_token>
```

**Response `200 OK`:** full coach object.

**Error `403`** — token belongs to a trainee, not a coach.

---

### Update Own Coach Profile

```
PUT /api/v1/coaches/me/
Authorization: Bearer <coach_token>
```

**Request body** (all fields optional):
```json
{
  "first_name": "Anna",
  "last_name": "Smith",
  "mobile_phone": "+380501234567",
  "work_phone": "+380441234567",
  "address1": "вул. Велика Васильківська 45",
  "city": "Kyiv",
  "country": "Ukraine",
  "gender": "female",
  "biography": "Certified personal trainer with 10 years experience",
  "image_url": "https://example.com/photo.jpg",
  "note": "Specializes in strength training"
}
```

**Response `200 OK`:** updated coach object.

---

### Change Coach Password

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

**Error `400`** — current password is incorrect.

---

## Field Reference

### Trainee Fields

| Field | Type | Create | Update | Notes |
|-------|------|:------:|:------:|-------|
| `email` | string | required | optional | Unique |
| `first_name` | string | required | optional | |
| `last_name` | string | required | optional | |
| `password` | string | required | optional | Stored as bcrypt hash |
| `mobile_phone` | string? | optional | optional | |
| `address1` | string? | optional | optional | |
| `address2` | string? | optional | optional | |
| `city` | string? | optional | optional | |
| `state` | string? | optional | optional | |
| `postal_code` | string? | optional | optional | |
| `country` | string? | optional | optional | |
| `gender` | string? | optional | optional | Free text (`"male"`, `"female"`, etc.) |
| `notes` | string? | optional | optional | Internal notes by coach |
| `weight` | float? | optional | optional | kg |
| `height` | float? | optional | optional | cm |
| `email_verified` | bool | — | — | Read-only. Set via `/verify-email` |

### Coach Fields

| Field | Type | Notes |
|-------|------|-------|
| `email` | string | Set at registration, not updatable via `/me/` |
| `first_name` | string | |
| `last_name` | string | |
| `mobile_phone` | string? | |
| `work_phone` | string? | |
| `address1` | string? | |
| `address2` | string? | |
| `city` | string? | |
| `state` | string? | |
| `postal_code` | string? | |
| `country` | string? | |
| `gender` | string? | |
| `biography` | string? | Displayed on coach profile |
| `image_url` | string? | URL to profile photo |
| `note` | string? | Internal notes |

---

## Error Responses

```json
{ "detail": "Human-readable error message" }
```

| HTTP Code | Meaning |
|-----------|---------|
| `400` | Bad request (duplicate email, wrong current password) |
| `401` | Missing or expired JWT token |
| `403` | Authenticated but wrong role (trainee tried coach-only action) |
| `404` | Resource not found |
| `422` | Request body validation failed (Pydantic) |

---

## Flutter Tips

### Determine role from token

```dart
final payload = decodeJwtPayload(token); // see auth-api-flutter.md
final sub = payload['sub'] as String;    // "coach:7" or "trainee:42"
final isCoach = sub.startsWith('coach:');
```

### Show/hide edit controls based on role

```dart
// Show "Edit profile" button only for coaches
if (isCoach) ...[
  ElevatedButton(
    onPressed: () => _editTrainee(traineeId),
    child: const Text('Edit'),
  ),
]
```

### Pagination example

```dart
Future<TraineeListResponse> fetchTrainees({int skip = 0, int limit = 20, String? q}) async {
  final response = await dio.get(
    '/api/v1/trainees/',
    queryParameters: {
      'skip': skip,
      'limit': limit,
      if (q != null && q.isNotEmpty) 'q': q,
    },
  );
  return TraineeListResponse.fromJson(response.data);
}
```
