with raw_data as (
    select *
    from {{ ref('users') }}
)

, final as (
    select
        user_id
        , created_at
        , is_internal
        , segment
    from raw_data
)

select * from final
