with weekly_activity as (select * from {{ ref('int_weekly_active_users') }})
, cohort_size as (select * from {{ ref('int_cohort_sizes') }})

-- Generate a row for each week
, weeks_since_first_active_spine as (
    select seq4() as weeks_since_first_active
    from table(generator(rowcount => 8))
)

, unioned as (
    select 
        user_cohort_week::string as user_cohort_week
        , weeks_since_first_active
        , segment
        , sum(active_during_period) as number_of_active_users_during_period
        , null as cohort_size
    from weekly_activity
    group by 1, 2, 3

    union all
    
    select 
        cohort_size.user_cohort_week::string as user_cohort_week
        , weeks_since_first_active_spine.weeks_since_first_active
        , cohort_size.segment
        , null as number_of_active_users_during_period
        , cohort_size.cohort_size
    from cohort_size
    cross join weeks_since_first_active_spine

)
 
select * from unioned
