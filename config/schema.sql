-- ============================================
-- SaaS Analytics Database Schema
-- ============================================
-- This schema models a B2B SaaS company's data warehouse
-- covering customers, subscriptions, usage, and revenue

-- ============================================
-- RAW LAYER (Landing Zone)
-- Data arrives here exactly as extracted from sources
-- ============================================

-- Raw customer data from CRM/API
CREATE TABLE IF NOT EXISTS raw_customers (
    id SERIAL PRIMARY KEY,
    external_id VARCHAR(100),           -- ID from source system
    company_name VARCHAR(255),
    email VARCHAR(255),
    industry VARCHAR(100),
    company_size VARCHAR(50),           -- e.g., '1-10', '11-50', '51-200'
    country VARCHAR(100),
    signup_date VARCHAR(50),            -- Kept as string initially (may need cleaning)
    source VARCHAR(100),                -- Where customer came from
    raw_payload JSONB,                  -- Full original JSON (for debugging)
    extracted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)            -- Track which file/API this came from
);

-- Raw subscription events
CREATE TABLE IF NOT EXISTS raw_subscriptions (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(100),
    event_type VARCHAR(50),             -- 'signup', 'upgrade', 'downgrade', 'churn', 'reactivation'
    plan_name VARCHAR(100),
    plan_tier VARCHAR(50),              -- 'free', 'starter', 'pro', 'enterprise'
    mrr_amount DECIMAL(12,2),           -- Monthly recurring revenue
    currency VARCHAR(10),
    event_date VARCHAR(50),             -- Kept as string (needs cleaning)
    billing_cycle VARCHAR(20),          -- 'monthly', 'annual'
    raw_payload JSONB,
    extracted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

-- Raw product usage events
CREATE TABLE IF NOT EXISTS raw_product_usage (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(100),
    event_name VARCHAR(100),            -- e.g., 'feature_used', 'api_call', 'login'
    event_category VARCHAR(100),        -- e.g., 'engagement', 'activation', 'core_action'
    event_count INTEGER,
    event_date VARCHAR(50),
    product_area VARCHAR(100),          -- Which part of product
    raw_payload JSONB,
    extracted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

-- Raw payment transactions
CREATE TABLE IF NOT EXISTS raw_transactions (
    id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(100),
    customer_id VARCHAR(100),
    amount DECIMAL(12,2),
    currency VARCHAR(10),
    status VARCHAR(50),                 -- 'succeeded', 'failed', 'refunded'
    payment_method VARCHAR(50),
    transaction_date VARCHAR(50),
    raw_payload JSONB,
    extracted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);


-- ============================================
-- CLEAN LAYER (Transformed Data)
-- Data that has been validated and cleaned
-- ============================================

-- Cleaned customer dimension
CREATE TABLE IF NOT EXISTS dim_customers (
    customer_id VARCHAR(100) PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    industry VARCHAR(100),
    company_size_bucket VARCHAR(50),
    employee_count_min INTEGER,
    employee_count_max INTEGER,
    country_code VARCHAR(3),
    country_name VARCHAR(100),
    region VARCHAR(50),                 -- 'NA', 'EMEA', 'APAC', 'LATAM'
    signup_date DATE NOT NULL,
    signup_month DATE,                  -- First day of signup month
    signup_quarter VARCHAR(10),         -- e.g., '2024-Q1'
    acquisition_source VARCHAR(100),
    customer_segment VARCHAR(50),       -- 'smb', 'mid_market', 'enterprise'
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cleaned subscription facts
CREATE TABLE IF NOT EXISTS fact_subscriptions (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(100) REFERENCES dim_customers(customer_id),
    event_type VARCHAR(50) NOT NULL,
    event_date DATE NOT NULL,
    event_month DATE,
    plan_name VARCHAR(100),
    plan_tier VARCHAR(50),
    mrr_amount_usd DECIMAL(12,2),       -- Normalized to USD
    mrr_change_usd DECIMAL(12,2),       -- Difference from previous MRR
    arr_amount_usd DECIMAL(12,2),       -- Annual recurring revenue
    billing_cycle VARCHAR(20),
    is_expansion BOOLEAN,               -- Was this an upgrade?
    is_contraction BOOLEAN,             -- Was this a downgrade?
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cleaned usage metrics (aggregated daily)
CREATE TABLE IF NOT EXISTS fact_daily_usage (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(100) REFERENCES dim_customers(customer_id),
    usage_date DATE NOT NULL,
    total_events INTEGER,
    unique_features_used INTEGER,
    core_actions_count INTEGER,         -- Key activation metrics
    api_calls_count INTEGER,
    active_users_count INTEGER,
    session_count INTEGER,
    engagement_score DECIMAL(5,2),      -- Calculated metric
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(customer_id, usage_date)
);

-- Cleaned revenue facts
CREATE TABLE IF NOT EXISTS fact_revenue (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(100) REFERENCES dim_customers(customer_id),
    transaction_id VARCHAR(100) UNIQUE,
    transaction_date DATE NOT NULL,
    transaction_month DATE,
    amount_original DECIMAL(12,2),
    currency_original VARCHAR(10),
    amount_usd DECIMAL(12,2),           -- Normalized to USD
    exchange_rate DECIMAL(10,6),
    transaction_type VARCHAR(50),       -- 'payment', 'refund', 'credit'
    payment_method VARCHAR(50),
    is_successful BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================
-- ANALYTICS LAYER (Business Metrics)
-- Pre-calculated metrics for dashboards
-- ============================================

-- Monthly cohort metrics
CREATE TABLE IF NOT EXISTS metrics_monthly_cohort (
    id SERIAL PRIMARY KEY,
    cohort_month DATE NOT NULL,         -- Month customers signed up
    metric_month DATE NOT NULL,         -- Month being measured
    months_since_signup INTEGER,        -- 0, 1, 2, 3...
    cohort_size INTEGER,                -- Customers in cohort
    active_customers INTEGER,           -- Still active this month
    churned_customers INTEGER,
    total_mrr_usd DECIMAL(14,2),
    avg_mrr_per_customer DECIMAL(12,2),
    retention_rate DECIMAL(5,2),
    revenue_retention_rate DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(cohort_month, metric_month)
);

-- Monthly company metrics (for executive dashboards)
CREATE TABLE IF NOT EXISTS metrics_monthly_summary (
    id SERIAL PRIMARY KEY,
    metric_month DATE UNIQUE NOT NULL,
    total_customers INTEGER,
    new_customers INTEGER,
    churned_customers INTEGER,
    net_customer_change INTEGER,
    total_mrr_usd DECIMAL(14,2),
    new_mrr_usd DECIMAL(14,2),
    expansion_mrr_usd DECIMAL(14,2),
    contraction_mrr_usd DECIMAL(14,2),
    churned_mrr_usd DECIMAL(14,2),
    net_mrr_change_usd DECIMAL(14,2),
    gross_revenue_usd DECIMAL(14,2),
    avg_revenue_per_customer DECIMAL(12,2),
    customer_churn_rate DECIMAL(5,2),
    revenue_churn_rate DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================
-- INDEXES (for query performance)
-- ============================================

CREATE INDEX IF NOT EXISTS idx_raw_customers_external_id ON raw_customers(external_id);
CREATE INDEX IF NOT EXISTS idx_raw_subscriptions_customer ON raw_subscriptions(customer_id);
CREATE INDEX IF NOT EXISTS idx_raw_usage_customer_date ON raw_product_usage(customer_id, event_date);
CREATE INDEX IF NOT EXISTS idx_fact_subs_customer ON fact_subscriptions(customer_id);
CREATE INDEX IF NOT EXISTS idx_fact_subs_date ON fact_subscriptions(event_date);
CREATE INDEX IF NOT EXISTS idx_fact_usage_date ON fact_daily_usage(usage_date);
CREATE INDEX IF NOT EXISTS idx_fact_revenue_date ON fact_revenue(transaction_date);
CREATE INDEX IF NOT EXISTS idx_dim_customers_segment ON dim_customers(customer_segment);
CREATE INDEX IF NOT EXISTS idx_dim_customers_signup ON dim_customers(signup_date);

