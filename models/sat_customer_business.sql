{{ config(
    alias='SAT_CUSTOMER_BUSINESS',
    schema='HEATHER_SILVER_BUSINESS'
) }}

with latest_customer_attrs as (

    -- Pull the most recent descriptive row per customer from the Raw Vault
    -- satellite -- this is "current state" for each customer.
    select
        customer_hash_key,
        acctbal,
        mktsegment
    from {{ source('erp', 'STG_ERP_CUSTOMER') }}
    -- Note: for the demo this reads straight from the ERP source rather
    -- than ref()'ing SAT_CUSTOMER_ERP, since that model isn't built as a
    -- table dbt can query yet -- swap to {{ ref('sat_customer_erp') }}
    -- once it's actually materialized.

),

derived as (

    select
        sha2(to_varchar(customer_hash_key), 256) as customer_hash_key,
        case
            when acctbal >= 5000 then 'HIGH_VALUE'
            when acctbal >= 1000 then 'STANDARD'
            else 'AT_RISK'
        end as customer_tier
    from latest_customer_attrs

)

select
    customer_hash_key,
    current_timestamp() as load_date,
    sha2(customer_tier, 256) as hash_diff,
    customer_tier,
    'DBT_DERIVED' as record_source
from derived