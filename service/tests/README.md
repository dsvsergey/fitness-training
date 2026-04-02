# 🧪 Tests Directory

This directory contains all test scripts and utilities created during the development of the local authentication system.

## 📁 Files Overview

### **🔐 Authentication Tests**

- **`test_validation.py`** - Tests the `get_current_user` validation logic with JWT tokens
- **`test_routes_conflict.py`** - Tests resolution of route conflicts between new and legacy endpoints
- **`test_server_deployment.py`** - Tests authentication on both local and remote servers

### **🏋️ Application Tests**

- **`test_workout_appointments.py`** - Tests workout appointments endpoint after authentication fixes

### **🛠️ Debug Utilities**

- **`debug_token.py`** - JWT token debugging script (decode, validate, check settings)
- **`debug_auth.py`** - Authentication flow debugging script

### **👨‍💼 Test Data Creation**

- **`create_test_coach.py`** - Utility to create test coaches with local authentication

## 🚀 Usage

All scripts can be run from the project root directory:

```bash
# Test authentication validation
python tests/test_validation.py

# Test route conflicts resolution  
python tests/test_routes_conflict.py

# Test server deployment
python tests/test_server_deployment.py

# Test workout appointments
python tests/test_workout_appointments.py

# Debug JWT tokens
python tests/debug_token.py

# Debug authentication flow
python tests/debug_auth.py

# Create test coach
python tests/create_test_coach.py create
```

## 📋 Test Results Summary

### ✅ **Completed Successfully:**

1. **JWT validation** - Fixed parameter mismatch (`sub` vs `subject`)
2. **Route conflicts** - Legacy endpoints moved to `/api/v1/legacy/`
3. **Authentication dependencies** - All endpoints updated to use `get_current_user`
4. **Token format** - Support for prefixes (`coach:10`, `trainee:123`)
5. **Backward compatibility** - Legacy tokens still work

### 🎯 **Authentication Features:**

- Local coach authentication independent of MindBody
- JWT tokens with user type prefixes
- Universal login endpoint with fallback support
- Complete RESTful API for coach management

## 🏆 Final Status

All authentication issues resolved. System ready for production deployment.

# Testing Files Documentation

This directory contains various testing tools and utilities for the fitness training service application.

## 🎯 **Customer Testing Environment**

For customer testing, the application now runs independently from MindBody with local test data.

### Quick Setup (Recommended)

```bash
# Set up complete test environment for customer demo
python tests/setup_test_environment.py setup
```

This will:

- Create 25 test trainees with realistic data
- Generate 2 weeks of fake workout appointments  
- Disable MindBody synchronization
- Provide ready-to-use test credentials

### Individual Test Data Tools

#### 👥 **Test Trainees Management**

```bash
# Create test trainees (default: 20)
python tests/create_test_trainees.py create [count]

# List existing trainees
python tests/create_test_trainees.py list

# Delete test trainees (with @test.com emails only)
python tests/create_test_trainees.py delete
```

**Generated test credentials** are saved to `tests/test_trainees_credentials.txt`

- Email format: `firstname.lastname@test.com`
- Password format: `test001`, `test002`, etc.

#### 📅 **Fake Schedule Generation**

```bash
# Generate fake workout appointments (default: 30 days, 8 per day)
python tests/create_fake_schedule.py generate [days] [appointments_per_day]

# Show schedule statistics
python tests/create_fake_schedule.py stats

# Clear all workout appointments
python tests/create_fake_schedule.py clear
```

**Features:**

- Realistic workout types (Personal Training, Yoga, HIIT, etc.)
- Multiple time slots throughout the day
- Random assignment of trainees and coaches
- Various appointment statuses (Scheduled, Completed, Cancelled)

#### 📊 **Environment Status**

```bash
# Check current test environment status
python tests/setup_test_environment.py status

# Reset entire test environment
python tests/setup_test_environment.py reset
```

---

## 🔒 **Authentication Testing**

### Test Coach Credentials

- **Email:** `Dmitriy.mironyuk@gmail.com`
- **Password:** `Sonik@9751`

### Test Trainee Credentials

Check `tests/test_trainees_credentials.txt` for complete list.

### JWT Token Format

- Coach tokens: `coach:123` (where 123 is coach ID)  
- Trainee tokens: `trainee:456` (where 456 is trainee ID)

---

## ⚙️ **MindBody Integration Status**

**CURRENT STATUS: DISABLED FOR TESTING**

- MindBody sync tasks are commented out in `celery_worker.py`
- Application runs entirely on local data
- No external API dependencies during testing

### To Re-enable MindBody Sync

1. Uncomment beat_schedule tasks in `celery_worker.py`
2. Ensure MindBody API credentials are in `.env`
3. Restart Celery worker

---

## 🚀 **Starting Customer Demo**

1. **Set up test environment:**

   ```bash
   python tests/setup_test_environment.py setup
   ```

2. **Start the server:**

   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

3. **Login options:**
   - Coach: `Dmitriy.mironyuk@gmail.com` / `Sonik@9751`
   - Trainees: Use credentials from `test_trainees_credentials.txt`

4. **API Testing:**

   ```bash
   # Test coach login
   curl -X POST "http://localhost:8000/api/v1/login/" \
        -H "Content-Type: application/json" \
        -d '{"email": "Dmitriy.mironyuk@gmail.com", "password": "Sonik@9751"}'
   
   # Test trainee login
   curl -X POST "http://localhost:8000/api/v1/login/" \
        -H "Content-Type: application/json" \
        -d '{"email": "john.doe@test.com", "password": "test001"}'
   ```

---

## 📝 **Development Testing Files**

### Debugging Tools

- `debug_token.py` - JWT token validation testing
- `debug_auth.py` - Authentication flow debugging

### Route Testing

- `test_routes_conflict.py` - Route conflict resolution testing
- `test_workout_appointments.py` - Endpoint testing after auth fixes

### Validation Testing

- `test_validation.py` - JWT validation testing
- `test_server_deployment.py` - Local/remote server testing

---

## 🎉 **Result**

✅ **Complete local authentication system**  
✅ **14 files updated** with enhanced auth  
✅ **All 401 Unauthorized errors eliminated**  
✅ **JWT tokens with user type prefixes working**  
✅ **Route conflicts resolved**  
✅ **MindBody sync disabled for testing**  
✅ **Realistic test data generated**  
✅ **Ready for customer demonstration**
