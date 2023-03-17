with raw_data as (
    select *
    from {{ ref('users') }}
)

, final as (

    -- Change the case of the column names to lowercase
    -- Note that this is not strictly necessary in Snowflake, but other data warehouses (e.g. BigQuery) differentiate between uppercase and lowercase column names
    select
        USER_ID as user_id

        -- Remove the characters at the start and end of the user id string that are repeated in all user ids
        , substr(user_id, 6, 17 as user_id_trimmed
        , CREATED_AT as created_at
        , IS_INTERNAL as is_internal
        , SEGMENT as segment
    from raw_data
)

select * from final
