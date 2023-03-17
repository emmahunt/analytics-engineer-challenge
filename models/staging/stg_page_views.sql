with raw_data as (
    select *
    from {{ ref('pages_views') }}
)

-- Change column names
, final as (
    select
        name as page_path
        , received_at
        , user_id
    from raw_data
)

select * from final
