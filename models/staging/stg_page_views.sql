with raw_data as (
    select *
    from {{ ref('pages_views') }}
)

-- Change column names
, final as (
    select
        name as page_path
        , received_at
        , user_id as user_identifier
    from raw_data

    -- Remove true duplicate page views: the pages at the same exact time, by the same user on the same page
    qualify row_number() over (
        partition by user_id, name, received_at
        order by received_at asc
    ) = 1

)

select * from final
