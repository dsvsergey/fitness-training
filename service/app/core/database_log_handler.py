import logging
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.log import Log


class DatabaseLogHandler(logging.Handler):
    def __init__(self):
        logging.Handler.__init__(self)

    def emit(self, record):
        # Never let logging errors propagate into request handlers
        try:
            log_entry = self.format(record)
            self._save(record.levelname, log_entry, record.name)
        except Exception:
            pass  # silently drop — DB may be unavailable

    def _save(self, level: str, message: str, logger_name: str) -> None:
        db: Session = SessionLocal()
        try:
            db.add(Log(level=level, message=message, logger_name=logger_name))
            db.commit()
        except Exception:
            db.rollback()
            raise
        finally:
            db.close()
