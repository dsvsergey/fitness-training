import bcrypt as _bcrypt

# passlib 1.7.4 reads bcrypt.__about__.__version__ which was removed in bcrypt 4.x
if not hasattr(_bcrypt, "__about__"):
    _bcrypt.__about__ = type("about", (), {"__version__": _bcrypt.__version__})()

from passlib.context import CryptContext

PWD_CONTEXT = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return PWD_CONTEXT.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return PWD_CONTEXT.hash(password)
