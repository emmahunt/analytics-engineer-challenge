
with page_view as (select * from {{ ref('fact_page_view') }})
, users as (select * from {{ ref('dim_user') }})

, cohort_size as (
    select 
        user_cohort_week
        , segment
        , count(distinct user_id) as cohort_size
    from users
    group by 1, 2
)

select * from cohort_size
