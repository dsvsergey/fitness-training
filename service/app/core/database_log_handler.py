import logging
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.log import Log


class DatabaseLogHandler(logging.Handler):
    def __init__(self):
        logging.Handler.__init__(self)

    def emit(self, record):
        log_entry = self.format(record)
        self.save_log_to_db(record.levelname, log_entry, record.name)

    def save_log_to_db(self, level, message, logger_name):
        db: Session = SessionLocal()
        db_log = Log(level=level, message=message, logger_name=logger_name)
        db.add(db_log)
        db.commit()
        db.close()
