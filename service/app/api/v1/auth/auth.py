from datetime import timedelta
from typing import Any, Union, List
from fastapi import APIRouter, Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
import json
import os

from app.core.config import ACCESS_TOKEN_EXPIRE_MINUTES, settings
from app.core.auth import create_access_token
from app.db.session import get_db
from app.services.trainee_service import TraineeService
from app.services.coach_service import CoachService
from app.schemas.token import Token, LoginRequest, MobileLoginRequest
from app.schemas.coachs import (
    CoachCreateWithPassword,
    CoachResponse,
    CoachLogin,
    CoachUpdate,
    CoachPasswordUpdate,
)
from app.schemas.trainees import TraineeResponse
from app.api.v1.dependencies import get_current_user


router = APIRouter()


@router.get("/health/")
async def health_check():
    """Health check endpoint for debugging server configuration"""
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


# Coach Management Endpoints


@router.post("/coaches/register/", response_model=CoachResponse)
async def register_coach(
    coach_data: CoachCreateWithPassword, db: Session = Depends(get_db)
) -> Any:
    """Register a new coach with local authentication"""
    try:
        coach_service = CoachService(db)
        coach = coach_service.create_coach(coach_data, coach_data.password)
        return coach
    except HTTPException:
        raise
    except Exception as e:
        import logging

        logger = logging.getLogger(__name__)
        logger.error(f"Error creating coach: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create coach",
        )


@router.post("/coaches/login/", response_model=Token)
async def login_coach(coach_login: CoachLogin, db: Session = Depends(get_db)) -> Any:
    """Login coach with local authentication"""
    try:
        coach_service = CoachService(db)
        coach = coach_service.authenticate_coach(
            coach_login.email, coach_login.password
        )

        if not coach:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )

        return {
            "access_token": create_access_token(sub=f"coach:{coach.id}"),
            "token_type": "bearer",
        }
    except HTTPException:
        raise
    except Exception as e:
        import logging

        logger = logging.getLogger(__name__)
        logger.error(f"Error in coach login: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Login failed"
        )


@router.get("/coaches/", response_model=List[CoachResponse])
async def get_coaches(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
) -> Any:
    """Get list of coaches (admin only)"""
    coach_service = CoachService(db)
    coaches = coach_service.get_coaches(skip=skip, limit=limit)
    return coaches


@router.get("/coaches/me/", response_model=CoachResponse)
async def get_current_coach(
    db: Session = Depends(get_db), current_user: str = Depends(get_current_user)
) -> Any:
    """Get current coach profile"""
    # Extract coach ID from token subject
    if not current_user.startswith("coach:"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Coach account required.",
        )

    coach_id = int(current_user.split(":")[1])
    coach_service = CoachService(db)
    coach = coach_service.get_coach(coach_id)

    if not coach:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Coach not found"
        )

    return coach


@router.put("/coaches/me/", response_model=CoachResponse)
async def update_current_coach(
    coach_update: CoachUpdate,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
) -> Any:
    """Update current coach profile"""
    # Extract coach ID from token subject
    if not current_user.startswith("coach:"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Coach account required.",
        )

    coach_id = int(current_user.split(":")[1])
    coach_service = CoachService(db)
    coach = coach_service.update_coach(coach_id, coach_update)

    if not coach:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Coach not found"
        )

    return coach


@router.put("/coaches/me/password/")
async def update_coach_password(
    password_update: CoachPasswordUpdate,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
) -> Any:
    """Update current coach password"""
    # Extract coach ID from token subject
    if not current_user.startswith("coach:"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Coach account required.",
        )

    coach_id = int(current_user.split(":")[1])
    coach_service = CoachService(db)

    # Verify current password
    coach = coach_service.get_coach(coach_id)
    if not coach:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Coach not found"
        )

    from app.core.security import verify_password

    if not verify_password(
        password_update.current_password, coach.user.hashed_password
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Current password is incorrect",
        )

    # Update password
    success = coach_service.update_coach_password(
        coach_id, password_update.new_password
    )
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update password",
        )

    return {"message": "Password updated successfully"}


# Legacy Login Endpoints (with fallback support)


@router.post("/login/simple/", response_model=Token)
async def login_simple(request: Request, db: Session = Depends(get_db)) -> Any:
    """Simple login endpoint that skips MindBody for debugging"""
    try:
        body = await request.body()
        data = json.loads(body)

        # Check if it's mobile format (Username/Password) or web format (email/password)
        if "Username" in data and "Password" in data:
            email = data["Username"]
            password = data["Password"]
        elif "email" in data and "password" in data:
            email = data["email"]
            password = data["password"]
        else:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Invalid data format. Expected either {email, password} or {Username, Password}",
            )

        # Try coach authentication first
        coach_service = CoachService(db)
        coach = coach_service.authenticate_coach(email, password)

        if coach:
            # Coach authentication succeeded
            return {
                "access_token": create_access_token(sub=f"coach:{coach.id}"),
                "token_type": "bearer",
            }

        # Try trainee authentication
        trainee_service = TraineeService(db)
        trainee = trainee_service.authenticate(email=email, password=password)

        if not trainee:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Trainee authentication succeeded
        return {
            "access_token": create_access_token(sub=f"trainee:{trainee.id}"),
            "token_type": "bearer",
        }

    except HTTPException:
        # Re-raise HTTPException as-is
        raise
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid JSON data"
        )
    except Exception as e:
        # Log the actual error for debugging
        import logging

        logger = logging.getLogger(__name__)
        logger.error(f"Unexpected error in simple login: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.post("/login/", response_model=Token)
async def login_json(request: Request, db: Session = Depends(get_db)) -> Any:
    """Unified login endpoint with local authentication"""
    try:
        body = await request.body()
        data = json.loads(body)

        # Check if it's mobile format (Username/Password) or web format (email/password)
        if "Username" in data and "Password" in data:
            email = data["Username"]
            password = data["Password"]
        elif "email" in data and "password" in data:
            email = data["email"]
            password = data["password"]
        else:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Invalid data format. Expected either {email, password} or {Username, Password}",
            )

        # Try local coach authentication first
        coach_service = CoachService(db)
        coach = coach_service.authenticate_coach(email, password)

        if coach:
            # Coach authentication succeeded
            coach_response = CoachResponse.model_validate(coach)
            return {
                "access_token": create_access_token(sub=f"coach:{coach.id}"),
                "token_type": "bearer",
                "coach": coach_response.model_dump(),
            }

        # Try local trainee authentication
        trainee_service = TraineeService(db)
        trainee = trainee_service.authenticate(email=email, password=password)

        if trainee:
            # Trainee authentication succeeded
            trainee_response = TraineeResponse.model_validate(trainee)
            return {
                "access_token": create_access_token(sub=f"trainee:{trainee.id}"),
                "token_type": "bearer",
                "trainee": trainee_response.model_dump(),
            }

        # All authentication methods failed
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    except HTTPException:
        # Re-raise HTTPException as-is
        raise
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Invalid JSON data"
        )
    except Exception as e:
        # Log the actual error for debugging
        import logging

        logger = logging.getLogger(__name__)
        logger.error(f"Unexpected error in login: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.post("/login/web/", response_model=Token)
async def login_web(login_data: LoginRequest, db: Session = Depends(get_db)) -> Any:
    """Login endpoint for web with email/password format"""
    trainee_service = TraineeService(db)
    trainee = trainee_service.authenticate(
        email=login_data.email, password=login_data.password
    )
    if not trainee:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return {
        "access_token": create_access_token(sub=f"trainee:{trainee.id}"),
        "token_type": "bearer",
    }


@router.post("/login/mobile/", response_model=Token)
async def login_mobile(
    login_data: MobileLoginRequest, db: Session = Depends(get_db)
) -> Any:
    """Login endpoint for mobile with Username/Password format"""
    trainee_service = TraineeService(db)
    trainee = trainee_service.authenticate(
        email=login_data.Username, password=login_data.Password
    )
    if not trainee:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return {
        "access_token": create_access_token(sub=f"trainee:{trainee.id}"),
        "token_type": "bearer",
    }


@router.post("/login/form/", response_model=Token)
async def login_form(
    db: Session = Depends(get_db), form_data: OAuth2PasswordRequestForm = Depends()
) -> Any:
    """Login endpoint with form data"""
    trainee_service = TraineeService(db)
    trainee = trainee_service.authenticate(
        email=form_data.username, password=form_data.password
    )
    if not trainee:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return {
        "access_token": create_access_token(sub=f"trainee:{trainee.id}"),
        "token_type": "bearer",
    }


@router.post("/login/access-token", response_model=Token)
async def login_access_token(
    db: Session = Depends(get_db), form_data: OAuth2PasswordRequestForm = Depends()
) -> Any:
    """OAuth2 compatible token login, get an access token for future requests"""
    trainee_service = TraineeService(db)
    trainee = trainee_service.authenticate(
        email=form_data.username, password=form_data.password
    )
    if not trainee:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return {
        "access_token": create_access_token(sub=f"trainee:{trainee.id}"),
        "token_type": "bearer",
    }


@router.post("/login/test-token", response_model=None)
async def test_token(current_user: str = Depends(get_current_user)) -> Any:
    """Test access token"""
    return {"msg": "Token is valid", "user_id": current_user}
