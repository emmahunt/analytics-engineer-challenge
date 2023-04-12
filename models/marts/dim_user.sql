with stg_users as (select * from {{ ref('stg_users') }})

, final as (
    select
        user_id
        , created_at
        , date_trunc(week, created_at)::date as user_cohort_week
        , age
        , country_name as country
    from stg_users
)

select * from final
