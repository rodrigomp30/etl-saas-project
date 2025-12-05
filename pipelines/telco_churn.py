"""
Telco Churn Pipeline

Creates a data model for churn analysis to be used in Metabase, based on churn data from Telco.
"""


import logging
import os
from extracts import extract_csv
import pandas as pd

#Configure Logging
logging.basicConfig(
    level=logging.INFO, 
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def main():

    """
    Main entry point for running the extraction pipeline.

    Orchestrates the ETL process and handles all errors centrally.
    """
    # Define file path
    dir_path = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.normpath(
        os.path.join(dir_path,'..', 'data', 'raw', 'WA_Fn-UseC_-Telco-Customer-Churn.csv')
    )


    try:
        df = extract_csv(file_path)
        logger.info('Extraction completed successfully!')
        print(df.head())

    except FileNotFoundError as e:
        logger.error(f'Source file not found: {file_path}')
        raise

    except pd.errors.EmptyDataError as e:
        logger.error(f'Source file is empty: {e}')
        raise

    except pd.errors.ParserError as e:
        logger.error(f'Failed to parse CSV: {e}')
        raise

    except Exception as e:
        logger.error(f'Unexpected error during extraction: {e}')
        raise

if __name__ == '__main__':
    main()
