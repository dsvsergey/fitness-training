import logging
import os
from typing import Any, List
from urllib.parse import urlencode

from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.responses import RedirectResponse
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.core.auth import create_access_token
from app.core.config import settings
from app.core.oauth import exchange_google_code, get_google_authorize_url, get_google_user_info, verify_google_state
from app.db.session import get_db
from app.schemas.coachs import (
    CoachCreateWithPassword,
    CoachLogin,
    CoachPasswordUpdate,
    CoachResponse,
    CoachUpdate,
)
from app.schemas.token import (
    GoogleAuthorizeResponse,
    LoginRequest,
    MobileLoginRequest,
    PasswordResetConfirm,
    PasswordResetRequest,
    Token,
)
from app.schemas.trainees import TraineeRegister, TraineeResponse
from app.api.v1.dependencies import get_current_user
from app.services.coach_service import CoachService
from app.services.trainee_service import TraineeService

logger = logging.getLogger(__name__)

router = APIRouter()


# ---------------------------------------------------------------------------
# Health
# ---------------------------------------------------------------------------


@router.get("/health/")
async def health_check():
    return {
        "status": "ok",
        "db_host": (
            settings.DATABASE_URL.split("@")[1].split("/")[0]
            if "@" in settings.DATABASE_URL
            else "unknown"
        ),
        "environment": os.getenv("ENVIRONMENT", "unknown"),
        "python_version": os.sys.version.split()[0],
    }


# ---------------------------------------------------------------------------
# Coach — registration & login
# ---------------------------------------------------------------------------


@router.post("/coaches/register/", response_model=CoachResponse)
async def register_coach(
    coach_data: CoachCreateWithPassword, db: Session = Depends(get_db)
) -> Any:
    """Register a new coach with email + password."""
    coach_service = CoachService(db)
    try:
        coach = coach_service.create_coach(coach_data, coach_data.password)
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error creating coach: %s", e)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to create coach")
    return coach


@router.post("/coaches/login/", response_model=Token)
async def login_coach(coach_login: CoachLogin, db: Session = Depends(get_db)) -> Any:
    """Login coach with email + password."""
    coach_service = CoachService(db)
    coach = coach_service.authenticate_coach(coach_login.email, coach_login.password)
    if not coach:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return {"access_token": create_access_token(sub=f"coach:{coach.id}"), "token_type": "bearer"}


@router.get("/coaches/", response_model=List[CoachResponse])
async def get_coaches(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
) -> Any:
    """List coaches (authenticated)."""
    return CoachService(db).get_coaches(skip=skip, limit=limit)


@router.get("/coaches/me/", response_model=CoachResponse)
async def get_current_coach(
    db: Session = Depends(get_db), current_user: str = Depends(get_current_user)
) -> Any:
    """Get authenticated coach profile."""
    if not current_user.startswith("coach:"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Coach account required.")
    coach_id = int(current_user.split(":")[1])
    coach = CoachService(db).get_coach(coach_id)
    if not coach:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Coach not found")
    return coach


@router.put("/coaches/me/", response_model=CoachResponse)
async def update_current_coach(
    coach_update: CoachUpdate,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
) -> Any:
    if not current_user.startswith("coach:"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Coach account required.")
    coach_id = int(current_user.split(":")[1])
    coach = CoachService(db).update_coach(coach_id, coach_update)
    if not coach:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Coach not found")
    return coach


@router.put("/coaches/me/password/")
async def update_coach_password(
    password_update: CoachPasswordUpdate,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
) -> Any:
    if not current_user.startswith("coach:"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Coach account required.")
    coach_id = int(current_user.split(":")[1])
    coach_service = CoachService(db)
    coach = coach_service.get_coach(coach_id)
    if not coach:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Coach not found")

    from app.core.security import verify_password

    if not verify_password(password_update.current_password, coach.user.hashed_password):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Current password is incorrect")

    if not coach_service.update_coach_password(coach_id, password_update.new_password):
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to update password")
    return {"message": "Password updated successfully"}


# ---------------------------------------------------------------------------
# Trainee — registration & login
# ---------------------------------------------------------------------------


@router.post("/trainees/register/", response_model=TraineeResponse, status_code=status.HTTP_201_CREATED)
async def register_trainee(data: TraineeRegister, db: Session = Depends(get_db)) -> Any:
    """Register a new trainee. Sends a verification email."""
    trainee_service = TraineeService(db)
    return await trainee_service.register_trainee(data)


@router.get("/trainees/me/", response_model=TraineeResponse)
async def get_current_trainee(
    db: Session = Depends(get_db), current_user: str = Depends(get_current_user)
) -> Any:
    """Get authenticated trainee profile."""
    if not current_user.startswith("trainee:"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Trainee account required.")
    trainee_id = int(current_user.split(":")[1])
    trainee = TraineeService(db).get_trainee(trainee_id)
    if not trainee:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainee not found")
    return trainee


# ---------------------------------------------------------------------------
# Email verification
# ---------------------------------------------------------------------------


@router.get("/verify-email")
async def verify_email(token: str, db: Session = Depends(get_db)) -> Any:
    """Verify email address using the token sent in the verification email."""
    TraineeService(db).verify_email(token)
    return {"message": "Email verified successfully."}


# ---------------------------------------------------------------------------
# Password reset (works for both coaches and trainees)
# ---------------------------------------------------------------------------


@router.post("/password-reset/request")
async def password_reset_request(body: PasswordResetRequest, db: Session = Depends(get_db)) -> Any:
    """Request a password reset link by email.

    Always returns 200 to prevent email enumeration.
    """
    trainee_service = TraineeService(db)
    coach_service = CoachService(db)

    # Try trainee first, then coach
    await trainee_service.request_password_reset(body.email)
    await coach_service.request_password_reset(body.email)

    return {"message": "If an account with that email exists, a password reset link has been sent."}


@router.post("/password-reset/confirm")
async def password_reset_confirm(body: PasswordResetConfirm, db: Session = Depends(get_db)) -> Any:
    """Reset password using the token from the reset email."""
    from app.core.auth import jwt_decode

    try:
        payload = jwt_decode(body.token)
    except Exception:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired reset token.")

    sub: str = payload.get("sub", "")

    if sub.startswith("trainee:"):
        TraineeService(db).reset_password(body.token, body.new_password)
    elif sub.startswith("coach:"):
        CoachService(db).reset_password(body.token, body.new_password)
    else:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid reset token.")

    return {"message": "Password reset successfully."}


# ---------------------------------------------------------------------------
# Google OAuth
# ---------------------------------------------------------------------------


@router.get("/google/authorize", response_model=GoogleAuthorizeResponse)
async def google_authorize(role: str = "trainee") -> Any:
    """Return the Google OAuth authorization URL.

    Pass `role=trainee` (default) or `role=coach` to determine what type of
    account to create when the user signs in for the first time.
    """
    if role not in ("trainee", "coach"):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="role must be 'trainee' or 'coach'")
    if not settings.GOOGLE_CLIENT_ID:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Google OAuth is not configured")
    return {"url": get_google_authorize_url(role=role)}


@router.get("/google/callback")
async def google_callback(code: str, state: str, db: Session = Depends(get_db)) -> Any:
    """Handle Google OAuth callback.

    Exchanges the authorization code for tokens, fetches the user's profile,
    and returns (or redirects with) a JWT access token.
    """
    # Verify state to prevent CSRF
    try:
        state_data = verify_google_state(state)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

    role: str = state_data.get("role", "trainee")

    # Exchange code for Google access token
    try:
        token_data = await exchange_google_code(code)
    except Exception as e:
        logger.error("Google token exchange failed: %s", e)
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Failed to exchange Google authorization code")

    access_token: str = token_data.get("access_token", "")

    # Fetch user profile from Google
    try:
        google_user = await get_google_user_info(access_token)
    except Exception as e:
        logger.error("Google userinfo fetch failed: %s", e)
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Failed to fetch Google user info")

    if role == "coach":
        coach = CoachService(db).get_or_create_from_google(google_user)
        jwt = create_access_token(sub=f"coach:{coach.id}")
        user_sub = f"coach:{coach.id}"
    else:
        trainee = TraineeService(db).get_or_create_from_google(google_user)
        jwt = create_access_token(sub=f"trainee:{trainee.id}")
        user_sub = f"trainee:{trainee.id}"

    # If FRONTEND_URL is configured, redirect back with token
    if settings.FRONTEND_URL and settings.FRONTEND_URL != "http://localhost:3000":
        redirect_url = f"{settings.FRONTEND_URL}/auth/callback?{urlencode({'token': jwt, 'sub': user_sub})}"
        return RedirectResponse(url=redirect_url)

    return {"access_token": jwt, "token_type": "bearer"}


# ---------------------------------------------------------------------------
# Legacy login endpoints
# ---------------------------------------------------------------------------


@router.post("/login/simple/", response_model=Token)
async def login_simple(request: Request, db: Session = Depends(get_db)) -> Any:
    import json

    try:
        body = await request.body()
        data = json.loads(body)
        if "Username" in data and "Password" in data:
            email, password = data["Username"], data["Password"]
        elif "email" in data and "password" in data:
            email, password = data["email"], data["password"]
        else:
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid data format")

        coach = CoachService(db).authenticate_coach(email, password)
        if coach:
            return {"access_token": create_access_token(sub=f"coach:{coach.id}"), "token_type": "bearer"}

        trainee = TraineeService(db).authenticate(email=email, password=password)
        if not trainee:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return {"access_token": create_access_token(sub=f"trainee:{trainee.id}"), "token_type": "bearer"}

    except HTTPException:
        raise
    except json.JSONDecodeError:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid JSON")
    except Exception as e:
        logger.error("Unexpected error in simple login: %s", e)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.post("/login/", response_model=Token)
async def login_json(request: Request, db: Session = Depends(get_db)) -> Any:
    import json

    try:
        body = await request.body()
        data = json.loads(body)
        if "Username" in data and "Password" in data:
            email, password = data["Username"], data["Password"]
        elif "email" in data and "password" in data:
            email, password = data["email"], data["password"]
        else:
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid data format")

        coach_service = CoachService(db)
        coach = coach_service.authenticate_coach(email, password)
        if coach:
            return {
                "access_token": create_access_token(sub=f"coach:{coach.id}"),
                "token_type": "bearer",
                "coach": CoachResponse.model_validate(coach).model_dump(),
            }

        trainee_service = TraineeService(db)
        trainee = trainee_service.authenticate(email=email, password=password)
        if trainee:
            return {
                "access_token": create_access_token(sub=f"trainee:{trainee.id}"),
                "token_type": "bearer",
                "trainee": TraineeResponse.model_validate(trainee).model_dump(),
            }

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    except HTTPException:
        raise
    except json.JSONDecodeError:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid JSON")
    except Exception as e:
        logger.error("Unexpected error in login: %s", e)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.post("/login/web/", response_model=Token)
async def login_web(login_data: LoginRequest, db: Session = Depends(get_db)) -> Any:
    trainee = TraineeService(db).authenticate(email=login_data.email, password=login_data.password)
    if not trainee:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return {"access_token": create_access_token(sub=f"trainee:{trainee.id}"), "token_type": "bearer"}


@router.post("/login/mobile/", response_model=Token)
async def login_mobile(login_data: MobileLoginRequest, db: Session = Depends(get_db)) -> Any:
    trainee = TraineeService(db).authenticate(email=login_data.Username, password=login_data.Password)
    if not trainee:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return {"access_token": create_access_token(sub=f"trainee:{trainee.id}"), "token_type": "bearer"}


@router.post("/login/form/", response_model=Token)
async def login_form(db: Session = Depends(get_db), form_data: OAuth2PasswordRequestForm = Depends()) -> Any:
    trainee = TraineeService(db).authenticate(email=form_data.username, password=form_data.password)
    if not trainee:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return {"access_token": create_access_token(sub=f"trainee:{trainee.id}"), "token_type": "bearer"}


@router.post("/login/access-token", response_model=Token)
async def login_access_token(db: Session = Depends(get_db), form_data: OAuth2PasswordRequestForm = Depends()) -> Any:
    trainee = TraineeService(db).authenticate(email=form_data.username, password=form_data.password)
    if not trainee:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return {"access_token": create_access_token(sub=f"trainee:{trainee.id}"), "token_type": "bearer"}


@router.post("/login/test-token")
async def test_token(current_user: str = Depends(get_current_user)) -> Any:
    return {"msg": "Token is valid", "user_id": current_user}
