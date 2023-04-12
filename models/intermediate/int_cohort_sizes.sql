with users as (select * from {{ ref('dim_user') }})

, cohort_size as (
    select 
        user_cohort_week
        , country
        , age
        , count(distinct user_id) as cohort_size
    from users

    -- Limit cohort to only the users that we've managed to join between the data sets
    where user_identifier is not null
    group by 1, 2, 3
)

select * from cohort_size
