with users as (select * from {{ ref('dim_user') }})

, cohort_size as (
    select 
        user_cohort_week
        , country
        , age
        , count(distinct user_id) as cohort_size
    from users
    where user_id is not null
    group by 1, 2, 3
)

select * from cohort_size
