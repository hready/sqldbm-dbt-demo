{{ config(
    alias='LNK_ORDER',
    schema='HEATHER_SILVER_RAW'
) }}

select
    sha2(to_varchar(orderkey) || to_varchar(custkey), 256) as lnk_order_hash_key,
    sha2(to_varchar(orderkey), 256) as order_hash_key,
    sha2(to_varchar(custkey), 256) as customer_hash_key,
    source_system as record_source,
    load_timestamp as load_date
from {{ source('erp', 'STG_ERP_ORDERS') }}