{{ config(
    alias='SAL_PRODUCT',
    schema='HEATHER_SILVER_BUSINESS'
) }}

with erp_products as (

    select
        sha2(to_varchar(partkey), 256) as product_hash_key,
        name as product_name
    from {{ source('erp', 'STG_ERP_PART') }}

),

edi_products as (

    select
        sha2(vend_part_cd, 256) as product_hash_key,
        vend_part_desc as product_name
    from {{ source('vendor_edi', 'STG_EDI_PART') }}

),

matched_pairs as (

    -- Placeholder match rule for the demo: treat two products as the same
    -- real-world item when their names/descriptions are an exact match.
    -- A production version would use fuzzy matching, a manual crosswalk
    -- table, or a stewarded mapping -- this is intentionally simple so the
    -- mechanism is easy to follow live.
    select
        e.product_hash_key as product_hash_key_1,
        d.product_hash_key as product_hash_key_2
    from erp_products e
    inner join edi_products d
        on lower(trim(e.product_name)) = lower(trim(d.product_name))

)

select
    sha2(
        least(product_hash_key_1, product_hash_key_2) ||
        greatest(product_hash_key_1, product_hash_key_2),
        256
    ) as sal_product_hash_key,
    product_hash_key_1,
    product_hash_key_2,
    'DBT_DERIVED' as record_source,
    current_timestamp() as load_date
from matched_pairs