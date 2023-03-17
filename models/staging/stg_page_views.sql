with raw_data as (
    select *
    from {{ ref('pages_views') }}
)

, final as (
    
    -- Change column names and cases
    select
        NAME as page_path
        , RECEIVED_AT as received_at
        , USER_ID as user_id
    from raw_data
)

select * from final
