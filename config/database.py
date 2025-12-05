"""
Database Configuration Module

This module handles database connections for the ETL pipeline.
In a real work environment, credentials come from environment variables
or a secrets manager - NEVER hardcoded.
"""

import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import logging

# Load environment variables from .env file
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def get_database_url() -> str:
    """
    Build database URL from environment variables.
    
    Returns:
        PostgreSQL connection string
    """
    host = os.getenv('DB_HOST', 'localhost')
    port = os.getenv('DB_PORT', '5433')
    database = os.getenv('DB_NAME', 'saas_analytics')
    user = os.getenv('DB_USER', 'postgres')
    password = os.getenv('DB_PASSWORD', '')
    
    return f"postgresql://{user}:{password}@{host}:{port}/{database}"


def get_engine():
    """
    Create and return a SQLAlchemy engine.
    
    Returns:
        SQLAlchemy Engine object
    """
    try:
        url = get_database_url()
        engine = create_engine(url)
        logger.info("Database engine created successfully")
        return engine
    except Exception as e:
        logger.error(f"Failed to create database engine: {e}")
        raise


def get_session():
    """
    Create and return a database session.
    
    Returns:
        SQLAlchemy Session object
    """
    engine = get_engine()
    Session = sessionmaker(bind=engine)
    return Session()


def test_connection():
    """
    Test the database connection.
    
    Returns:
        bool: True if connection successful, False otherwise
    """
    try:
        engine = get_engine()
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
        logger.info("Database connection test successful")
        return True
    except Exception as e:
        logger.error(f"Database connection test failed: {e}")
        return False

