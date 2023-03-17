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

        -- Remove the characters at the end of the user_id that are repeated in all values
        , substr(user_id, 10, 27) as user_id_trimmed
    from raw_data
)

select * from final
