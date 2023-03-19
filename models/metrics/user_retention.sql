with dim_user as (select * from {{ ref('dim_user') }})
, fact_page_view as (select * from {{ ref('fact_page_view') }})
, fact_page_view as (select * from {{ ref('fact_page_view') }})

, date_spine as (
    {{ dbt_utils.date_spine(
        datepart="week",
        start_date="cast('2022-10-08' as date)",
        end_date="cast('2022-12-14' as date)"
    )
    }}
)

, lapsed_users as (
    select
        lapsed_date
        , user_id
        , 1 as lapsed_user_count
    from dim_user
    where lapsed_date is not null
)

, active_users as (
    select
        received_at
        , user_identifier
        , count(distinct page_view_id) as number_of_page_views
    from fact_page_view
    group by 1, 2
)

, joined as (
    select 
        date_spine.date_week
        , dim_user.user_cohort_week
        , count_if(dim_user.user_cohort_week = date_spine.date_week) as new_users
        , sum(lapsed_users.lapsed_user_count) as lapsed_users
        , count_if(active_users.number_of_page_views is not null) as active_users
    from date_spine
    cross join dim_user
    left join lapsed_users
        on date_trunc(week, lapsed_users.lapsed_date)::date = date_spine.date_week
        and dim_user.user_id = lapsed_users.user_id
    left join active_users
        on date_spine.date_week = date_trunc(week, active_users.received_at)::date
        and dim_user.user_identifier = active_users.user_identifier
    group by 1, 2
)

, final as (
    select 
        date_week
        , user_cohort_week
        , new_users
        , lapsed_users
        , active_users
        , active_users - lapsed_users as retained_users
        , (active_users - lapsed_users) / active_users as retention_rate
    from joined
)

select * from final
