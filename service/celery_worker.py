import logging
from celery import Celery

from app.core.config import settings
from app.core.database_log_handler import DatabaseLogHandler


db_handler = DatabaseLogHandler()
db_handler.setLevel(logging.INFO)
db_handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[db_handler, logging.StreamHandler()],
)

logger = logging.getLogger(__name__)


celery_app = Celery(
    "worker",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
)


celery_app.conf.update(
    result_expires=3600,
)


if __name__ == "__main__":
    celery_app.start()
