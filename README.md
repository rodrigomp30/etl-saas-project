# ETL SaaS Analytics Project

A professional ETL (Extract, Transform, Load) pipeline project simulating real-world data engineering workflows at a B2B SaaS company.

## Project Overview

This project builds data pipelines that:
- **Extract** data from multiple sources (CSV files, REST APIs, PostgreSQL databases)
- **Transform** raw data through cleaning, validation, and business logic
- **Load** processed data into a PostgreSQL data warehouse

## Business Context

You're a data analyst at a SaaS payments company. Your pipelines support:
- **Product Analytics**: User engagement, feature adoption, activation rates
- **Revenue Analytics**: MRR, churn, LTV calculations
- **Marketing Analytics**: Campaign attribution, conversion funnels

## Project Structure

```
etl-saas-project/
├── config/              # Database connections, API keys, settings
├── extracts/            # Data extraction modules (CSV, API, DB)
├── transforms/          # Data cleaning and transformation logic
├── loads/               # Data loading modules
├── pipelines/           # Orchestrated ETL workflows
├── data/
│   ├── raw/             # Raw downloaded/extracted data
│   └── processed/       # Cleaned, transformed data
└── tests/               # Unit tests for pipeline components
```

## Tech Stack

- **Python 3.10+**
- **pandas** - Data manipulation
- **SQLAlchemy** - Database ORM
- **psycopg2** - PostgreSQL adapter
- **requests** - API calls
- **python-dotenv** - Environment variables

## Setup

1. Clone the repository
2. Create virtual environment: `python -m venv venv`
3. Activate: `source venv/bin/activate`
4. Install dependencies: `pip install -r requirements.txt`
5. Copy `.env.example` to `.env` and add your credentials
6. Run database migrations

## Data Sources

### Primary Dataset: SaaS Customer Subscription Data
- Customer information and segments
- Subscription events (signups, upgrades, downgrades, churn)
- Product usage metrics
- Payment transactions

### APIs
- Currency exchange rates (for international revenue)
- Enrichment data (company information)

## Author

Rodrigo Muniz - Data Analyst

