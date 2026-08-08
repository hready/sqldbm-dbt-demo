{{ config(
    alias='SAT_CUSTOMER_ERP',
    schema='HEATHER_SILVER_RAW'
) }}

select
    sha2(to_varchar(custkey), 256) as customer_hash_key,
    load_timestamp as load_date,
    sha2(concat_ws('|', name, address, phone, to_varchar(acctbal), mktsegment, comment), 256) as hash_diff,
    name,
    address,
    phone,
    acctbal,
    mktsegment,
    comment,
    source_system as record_source
from {{ source('erp', 'STG_ERP_CUSTOMER') }}