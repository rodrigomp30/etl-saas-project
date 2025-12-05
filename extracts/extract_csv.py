"""
CSV Extract Module

Handles extraction of raw data from CSV files into pandas Dataframes.
"""

import pandas as pd
import logging

#Configure Logging
logging.basicConfig(
    level=logging.INFO, 
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def extract_csv(file_path: str) -> pd.DataFrame:

    """
    Extract data from a CSV file into a pandas DataFrame.

    Args:
        file_path: Path to the CSV file to be loaded.
    Returns:
        pd.DataFrame: DataFrame containing the CSV data.
    Raises:
        FileNotFoundError: If the specified file path does not exist.
        pd.errors.EmptyDataError: If the CSV file is empty.
        pd.errors.ParserError: If the CSV is malformed.
    """
    
    logger.info(f'Extracting data from: {file_path}')

    df = pd.read_csv(file_path)

    logger.info(f'Successfully extracted {len(df):,} rows and {len(df.columns)} columns')
    return df