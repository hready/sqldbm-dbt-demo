{{ config(
    alias='HUB_CUSTOMER',
    schema='HEATHER_SILVER_RAW'
) }}

select
    sha2(to_varchar(custkey), 256) as customer_hash_key,
    custkey,
    source_system as record_source,
    load_timestamp as load_date
from {{ source('erp', 'STG_ERP_CUSTOMER') }}