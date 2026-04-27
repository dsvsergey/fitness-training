import logging
from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session
from starlette import status
from typing import Optional
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError

from app.core.config import settings  # Use settings instead of individual imports
from app.db.session import get_db
from app.models.users import User
from app.services.trainee_service import TraineeService
from app.services.coach_service import CoachService
from app.schemas.token import TokenPayload


logger = logging.getLogger(__name__)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login/access-token")


def current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """Get current user by JWT token in Authorization header. If token expired, 401"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    if not token:
        raise credentials_exception
    user = db.query(User).filter(User.token == token).first()
    if not user:
        raise credentials_exception
    return user


def is_admin(user: User = Depends(current_user)):
    if not user.is_admin and not user.is_moderator:
        raise HTTPException(status_code=403, detail="You are not moderator")
    return user


async def get_current_coach(
    db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)
) -> str:
    """Require the token to belong to a coach. Raises 403 otherwise."""
    subject = await get_current_user(db=db, token=token)
    if not subject.startswith("coach:"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only coaches can perform this action",
        )
    return subject


async def get_current_user(
    db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)
) -> str:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(
            token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM]
        )
        user_subject: Optional[str] = payload.get("sub")
        if user_subject is None:
            raise credentials_exception

        # Handle new token format with prefixes (coach:123, trainee:456)
        if ":" in user_subject:
            user_type, user_id_str = user_subject.split(":", 1)
            user_id = int(user_id_str)

            if user_type == "coach":
                coach_service = CoachService(db)
                coach = coach_service.get_coach(user_id)
                if coach is None:
                    raise credentials_exception
                return user_subject  # Return full subject (coach:123)

            elif user_type == "trainee":
                trainee_service = TraineeService(db)
                trainee = trainee_service.get_trainee(trainee_id=user_id)
                if trainee is None:
                    raise credentials_exception
                return user_subject  # Return full subject (trainee:456)

            else:
                raise credentials_exception

        else:
            # Legacy format - assume it's a trainee ID
            trainee_service = TraineeService(db)
            user = trainee_service.get_trainee(trainee_id=int(user_subject))
            if user is None:
                raise credentials_exception
            return f"trainee:{user.id}"  # Convert to new format

    except (JWTError, ValueError, AttributeError):
        raise credentials_exception
