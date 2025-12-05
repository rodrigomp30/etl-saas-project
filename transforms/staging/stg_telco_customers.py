"""
Staging Model: Telco Customer - light transformations

Handles Clean, rename, type cast — no business logic
"""

import pandas as pd
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


def stg_telco_customers(df: pd.DataFrame) -> pd.DataFrame:

    df['TotalCharges'] = df['TotalCharges'].astype(float)
    df.columns = df.columns.rename(['customerID': 'customer_id'])
