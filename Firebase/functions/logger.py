import logging
from enum import Enum
from datetime import datetime
from typing import Optional

class LogLevel(Enum):
    """Log levels matching the iOS app's UnifiedLogger"""
    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"

class Logger:
    """A simple logging utility for Firebase Functions that matches the iOS app's logging structure"""
    
    @staticmethod
    def _format_message(message: str, context: Optional[str] = None) -> str:
        """Format the log message with timestamp and context"""
        timestamp = datetime.utcnow().isoformat()
        context_info = f"[{context}] " if context else ""
        return f"{timestamp} {context_info}{message}"

    @staticmethod
    def debug(message: str, context: Optional[str] = None) -> None:
        """Log a debug message"""
        logging.debug(Logger._format_message(message, context))

    @staticmethod
    def info(message: str, context: Optional[str] = None) -> None:
        """Log an info message"""
        logging.info(Logger._format_message(message, context))

    @staticmethod
    def warning(message: str, context: Optional[str] = None) -> None:
        """Log a warning message"""
        logging.warning(Logger._format_message(message, context))

    @staticmethod
    def error(message: str, context: Optional[str] = None) -> None:
        """Log an error message"""
        logging.error(Logger._format_message(message, context))

    @staticmethod
    def error_with_exception(error: Exception, context: Optional[str] = None) -> None:
        """Log an error with its full stack trace"""
        logging.error(Logger._format_message(str(error), context), exc_info=True) 